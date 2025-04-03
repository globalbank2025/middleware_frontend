import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';

import {
  VatCollectionService,
  ServiceIncomeGl,
  AccountStatusBalanceResponse,
  VatCollectionTransactionDto
} from '../../services/vat-collection.service';
import { InvoiceStateService } from '../../services/invoice-state.service';

@Component({
  selector: 'app-vat-collection',
  templateUrl: './vat-collection.component.html',
  styleUrls: ['./vat-collection.component.css']
})
export class VatCollectionComponent implements OnInit {
  vatForm: FormGroup;
  customerName: string | null = null;
  errorMsg: string | null = null;
  loading = false;
  isPayDisabled = true;

  // Static bank info
  bankInfo = {
    bankName: 'Global Bank Ethiopia',
    tinNo: '0000006379',
    vatRegNo: '68784',
    vatRegDate: 'March 10, 2007',
    address: 'Kirkos Woreda 07 H.No — Addis Ababa, Ethiopia',
    tel: '251-11-551-11-56',
    logoUrl: 'assets/images/boa-logo.png'
  };

  // Service Income GL from backend
  serviceIncomeGlOptions: ServiceIncomeGl[] = [];

  constructor(
    private fb: FormBuilder,
    private vatService: VatCollectionService,
    private invoiceState: InvoiceStateService,
    private router: Router,
    private toastr: ToastrService
  ) {
    // The new "otherGlCode" field will hold the 7-digit code when "Other" is selected.
    // We add a pattern validator for 7 digits.
    this.vatForm = this.fb.group({
      accountNumber: ['', [Validators.required]],
      customerName: [''],
      customerVatRegistrationNo: [''],
      customerTinNo: [''],
      customerTelephone: [''],
      transferAmount: [null, [Validators.required]],
      serviceIncomeGl: ['', [Validators.required]],
      // Service charge can be typed by user only if "other" is selected, read-only otherwise.
      serviceCharge: [null],
      vatOnServiceCharge: [null],
      totalAmount: [null],
      // Extra field to accept a 7-digit code for the "Other" scenario
      otherGlCode: ['', [Validators.pattern(/^\d{7}$/)]]
    });
  }

  ngOnInit(): void {
    // Fetch GL options from service
    this.vatService.getServiceIncomeGl().subscribe({
      next: (data: ServiceIncomeGl[]) => (this.serviceIncomeGlOptions = data),
      error: (err) => console.error('Failed to load Service Income GL options', err)
    });

    // Listen for changes on principal or GL selection
    this.vatForm.get('transferAmount')?.valueChanges.subscribe(() => this.updateComputedValues());
    this.vatForm.get('serviceIncomeGl')?.valueChanges.subscribe(() => this.updateComputedValues());

    // If "Other" is selected, recalc on serviceCharge changes
    this.vatForm.get('serviceCharge')?.valueChanges.subscribe(() => {
      if (this.vatForm.get('serviceIncomeGl')?.value === 'other') {
        this.updateComputedValues();
      }
    });
  }

  // For convenience, get the selected GL object from the array
  get selectedGL(): ServiceIncomeGl | undefined {
    const selectedId = this.vatForm.get('serviceIncomeGl')?.value;
    return this.serviceIncomeGlOptions.find(gl => gl.id === selectedId);
  }

  /**
   * Main logic to compute the serviceCharge, vatOnServiceCharge, and totalAmount.
   * If "Other" is selected, we let the user input the serviceCharge; otherwise, it is auto-computed.
   */
  private updateComputedValues(): void {
    const principal = this.vatForm.get('transferAmount')?.value;
    if (!principal) {
      // If no principal, clear out fields
      this.vatForm.patchValue({
        serviceCharge: null,
        vatOnServiceCharge: null,
        totalAmount: null
      }, { emitEvent: false });
      return;
    }

    const principalAmount = Number(principal);
    const selectedGlId = this.vatForm.get('serviceIncomeGl')?.value;
    let serviceCharge = 0;
    let vatOnServiceCharge = 0;

    if (selectedGlId === 'other') {
      // Let the user type any serviceCharge. We do not overwrite it.
      serviceCharge = Number(this.vatForm.get('serviceCharge')?.value) || 0;
      vatOnServiceCharge = serviceCharge * 0.15;
    } else {
      // A known GL is selected (Flat or Rate). Compute automatically.
      const selectedGl = this.serviceIncomeGlOptions.find(gl => gl.id === selectedGlId);
      if (selectedGl) {
        if (selectedGl.calculationType === 'Flat') {
          serviceCharge = selectedGl.flatPrice || 0;
          vatOnServiceCharge = serviceCharge * 0.15;
        } else if (selectedGl.calculationType === 'Rate') {
          const rateNum = Number(selectedGl.rate || 0);
          serviceCharge = principalAmount * (rateNum / 100);
          vatOnServiceCharge = serviceCharge * 0.15;
        }
      }
      // Patch the automatically computed service charge
      this.vatForm.patchValue({ serviceCharge }, { emitEvent: false });
    }

    const totalAmount = principalAmount + serviceCharge + vatOnServiceCharge;
    this.vatForm.patchValue({
      vatOnServiceCharge,
      totalAmount
    }, { emitEvent: false });
  }

  /**
   * When user focuses on Customer Name, we query the account info from the service.
   */
  onCustomerNameFocus(): void {
    const acc = (this.vatForm.get('accountNumber')?.value || '').trim();
    if (!acc) {
      this.errorMsg = 'Please enter Account Number first.';
      return;
    }
    if (acc.length < 3) {
      this.errorMsg = 'Account number is too short.';
      return;
    }

    this.errorMsg = null;
    this.loading = true;
    const brn = acc.substring(0, 3);

    this.vatService.queryAccountStatusBalance(brn, acc).subscribe({
      next: (res: AccountStatusBalanceResponse) => {
        this.loading = false;
        this.customerName = res.customerName;
        this.vatForm.patchValue({ customerName: res.customerName });
      },
      error: (err) => {
        this.loading = false;
        this.customerName = null;
        if (err.error && err.error.error) {
          this.errorMsg = err.error.error;
        } else if (typeof err.error === 'string') {
          this.errorMsg = err.error;
        } else {
          this.errorMsg = 'Unknown error occurred.';
        }
      }
    });
  }

  /**
   * Validate button checks if account is restricted/frozen, 
   * and if the balance covers serviceCharge + VAT. 
   * Also enforces the 7-digit otherGlCode if "Other" is selected.
   */
  onValidate(): void {
    if (this.vatForm.invalid) {
      this.errorMsg =
        'Please fill required fields (Account Number, Service Income GL, Transfer Amount, etc.) before validating.';
      this.isPayDisabled = true;
      return;
    }

    // If "Other" is selected, enforce 7-digit code requirement.
    const glSelect = this.vatForm.get('serviceIncomeGl')?.value;
    if (glSelect === 'other') {
      const otherCode = this.vatForm.get('otherGlCode')?.value || '';
      const patternTest = /^\d{7}$/.test(otherCode);
      if (!patternTest) {
        this.errorMsg = 'Please enter a valid 7-digit GL code for "Other".';
        this.isPayDisabled = true;
        return;
      }
    }

    const acc = this.vatForm.get('accountNumber')?.value;
    if (!acc) {
      this.errorMsg = 'Account number required.';
      this.isPayDisabled = true;
      return;
    }

    this.errorMsg = null;
    this.loading = true;
    const brn = acc.substring(0, 3);

    this.vatService.queryAccountStatusBalance(brn, acc).subscribe({
      next: (res: AccountStatusBalanceResponse) => {
        this.loading = false;
        if (res.frozen === 'Y' || res.acStatNoDr === 'Y' || res.acStatNoCr === 'Y') {
          this.toastr.error('This Account is Frozen or No Debit/Credit.', 'Account Restricted');
          this.errorMsg = 'Account is restricted.';
          this.isPayDisabled = true;
          return;
        }

        const sc = Number(this.vatForm.get('serviceCharge')?.value) || 0;
        const vatSC = Number(this.vatForm.get('vatOnServiceCharge')?.value) || 0;
        const requiredForCharges = sc + vatSC;
        const availBal = Number(res.availableBalance || 0);

        if (requiredForCharges > availBal) {
          this.toastr.error('Insufficient balance to cover Service Charge + VAT.', 'Balance Error');
          this.errorMsg = 'Insufficient balance.';
          this.isPayDisabled = true;
          return;
        }

        this.toastr.success('Validation successful! You can now Pay.');
        this.errorMsg = null;
        this.isPayDisabled = false;
      },
      error: (err) => {
        this.loading = false;
        this.isPayDisabled = true;
        if (err.error && err.error.error) {
          this.errorMsg = err.error.error;
        } else if (typeof err.error === 'string') {
          this.errorMsg = err.error;
        } else {
          this.errorMsg = 'Unknown error occurred.';
        }
      }
    });
  }

  /**
   * Pay button: build the DTO, including the user-specified otherGlCode if "Other" is selected,
   * and call createVatCollectionTransaction.
   */
  onPay(): void {
    if (this.vatForm.invalid) {
      this.errorMsg = 'Please fill all required fields properly.';
      return;
    }
    if (this.isPayDisabled) {
      return;
    }

    // Grab branch code from local storage (as an example).
    let branchCode = 0;
    const loginResponse = localStorage.getItem('loginResponse');
    if (loginResponse) {
      try {
        const parsed = JSON.parse(loginResponse);
        branchCode = Number(parsed.user.branchCode) || 0;
      } catch (error) {
        console.error('Error parsing loginResponse from localStorage:', error);
      }
    }

    const selectedGlId = this.vatForm.get('serviceIncomeGl')?.value;
    const selectedGl = this.serviceIncomeGlOptions.find(gl => gl.id === selectedGlId);

    let glCodeValue = '';
    if (selectedGlId === 'other') {
      // If "Other" is selected, we use the user-specified 7-digit code.
      glCodeValue = this.vatForm.get('otherGlCode')?.value || '';
    } else {
      // If a known GL is selected, use its code.
      glCodeValue = selectedGl ? selectedGl.glCode : '';
    }

    const dto: VatCollectionTransactionDto = {
      branchCode,
      accountNumber: this.vatForm.get('accountNumber')?.value,
      customerVatRegistrationNo: this.vatForm.get('customerVatRegistrationNo')?.value,
      customerTinNo: this.vatForm.get('customerTinNo')?.value,
      customerTelephone: this.vatForm.get('customerTelephone')?.value,
      principalAmount: this.vatForm.get('transferAmount')?.value,
      serviceIncomeGl: glCodeValue,
      serviceCharge: this.vatForm.get('serviceCharge')?.value,
      vatOnServiceCharge: this.vatForm.get('vatOnServiceCharge')?.value,
      totalAmount: this.vatForm.get('totalAmount')?.value,
      transferAmount: 0,
      customerName: this.vatForm.get('customerName')?.value
    };

    this.vatService.createVatCollectionTransaction(dto).subscribe({
      next: () => {
        this.toastr.success('Transaction saved as pending.', 'Success');
        this.vatForm.reset();
        this.customerName = null;
        this.errorMsg = null;
        this.isPayDisabled = true;
      },
      error: (err) => {
        let errorMessage = 'Failed to save transaction.';
        if (err && err.error) {
          if (typeof err.error === 'string') {
            errorMessage = err.error;
          } else if (err.error.error) {
            errorMessage = err.error.error;
          } else if (err.error.message) {
            errorMessage = err.error.message;
          }
        }
        this.toastr.error(errorMessage, 'Error');
        console.error('Error saving transaction:', err);
      }
    });
  }
}
