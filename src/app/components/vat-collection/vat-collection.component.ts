import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
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

  bankInfo = {
    bankName: 'Global Bank Ethiopia',
    tinNo: '0000006379',
    vatRegNo: '68784',
    vatRegDate: 'March 10, 2007',
    address: 'Kirkos Woreda 07 H.No — Addis Ababa, Ethiopia',
    tel: '251-11-551-11-56',
    logoUrl: 'assets/images/boa-logo.png'
  };

  serviceIncomeGlOptions: ServiceIncomeGl[] = [];

  constructor(
    private fb: FormBuilder,
    private vatService: VatCollectionService,
    private invoiceState: InvoiceStateService,
    private router: Router,
    private toastr: ToastrService
  ) {
    this.vatForm = this.fb.group({
      accountNumber: ['', [Validators.required]],
      customerName: [''],
      customerVatRegistrationNo: [''],
      customerTinNo: [''],
      customerTelephone: [''],
      transferAmount: [null, [Validators.required]],
      serviceIncomeGl: ['', [Validators.required]],
      serviceCharge: [{ value: null, disabled: true }],
      vatOnServiceCharge: [{ value: null, disabled: true }],
      totalAmount: [{ value: null, disabled: true }]
    });
  }

  ngOnInit(): void {
    this.vatService.getServiceIncomeGl().subscribe({
      next: (data: ServiceIncomeGl[]) => (this.serviceIncomeGlOptions = data),
      error: (err) => console.error('Failed to load Service Income GL options', err)
    });

    this.vatForm.get('transferAmount')?.valueChanges.subscribe(() => {
      this.updateComputedValues();
    });
    this.vatForm.get('serviceIncomeGl')?.valueChanges.subscribe(() => {
      this.updateComputedValues();
    });
  }

  // Getter to retrieve the selected GL object
  get selectedGL(): ServiceIncomeGl | undefined {
    const selectedCode = this.vatForm.get('serviceIncomeGl')?.value;
    return this.serviceIncomeGlOptions.find(gl => gl.glCode === selectedCode);
  }

  private updateComputedValues(): void {
    const principal = this.vatForm.get('transferAmount')?.value;
    if (!principal) {
      this.vatForm.patchValue({
        serviceCharge: null,
        vatOnServiceCharge: null,
        totalAmount: null
      }, { emitEvent: false });
      return;
    }
    const principalAmount = Number(principal);
    const selectedGlCode = this.vatForm.get('serviceIncomeGl')?.value;
    let serviceCharge: number | null = null;
    const selectedGl = this.serviceIncomeGlOptions.find(gl => gl.glCode === selectedGlCode);
    if (selectedGl) {
      if (selectedGl.calculationType === 'Flat') {
        serviceCharge = selectedGl.flatPrice || 0;
      } else if (selectedGl.calculationType === 'Rate') {
        const rateNum = Number(selectedGl.rate || 0);
        serviceCharge = principalAmount * (rateNum / 100);
      }
    }
    const vatOnServiceCharge = serviceCharge !== null ? serviceCharge * 0.15 : null;
    const totalAmount = serviceCharge !== null && vatOnServiceCharge !== null
      ? principalAmount + serviceCharge + vatOnServiceCharge
      : null;
    this.vatForm.patchValue({
      serviceCharge,
      vatOnServiceCharge,
      totalAmount
    }, { emitEvent: false });
  }

  onCustomerNameFocus(): void {
    const acc = this.vatForm.get('accountNumber')?.value?.trim();
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

  onValidate(): void {
    if (this.vatForm.invalid) {
      this.errorMsg =
        'Please fill required fields (Account Number, Service Income GL, Transfer Amount, etc.) before validating.';
      this.isPayDisabled = true;
      return;
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
        const serviceCharge = Number(this.vatForm.get('serviceCharge')?.value) || 0;
        const vatOnServiceCharge = Number(this.vatForm.get('vatOnServiceCharge')?.value) || 0;
        const requiredForCharges = serviceCharge + vatOnServiceCharge;
        const availableBalanceNum = Number(res.availableBalance || 0);
        if (requiredForCharges > availableBalanceNum) {
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

  onPay(): void {
    // Validate the form first.
    if (this.vatForm.invalid) {
      this.errorMsg = 'Please fill all required fields properly.';
      return;
    }
    if (this.isPayDisabled) {
      return;
    }
    
    // Retrieve the loginResponse from local storage to extract branchCode.
    const loginResponse = localStorage.getItem('loginResponse');
    let branchCode = 0;
    if (loginResponse) {
      try {
        const parsedResponse = JSON.parse(loginResponse);
        branchCode = Number(parsedResponse.user.branchCode) || 0;
      } catch (error) {
        console.error('Error parsing loginResponse from localStorage:', error);
      }
    }
    
    // Build the transaction DTO using form values.
    const dto: VatCollectionTransactionDto = {
      branchCode: branchCode,
      accountNumber: this.vatForm.get('accountNumber')?.value,
      customerVatRegistrationNo: this.vatForm.get('customerVatRegistrationNo')?.value,
      customerTinNo: this.vatForm.get('customerTinNo')?.value,
      customerTelephone: this.vatForm.get('customerTelephone')?.value,
      principalAmount: this.vatForm.get('transferAmount')?.value,
      serviceIncomeGl: this.vatForm.get('serviceIncomeGl')?.value,
      serviceCharge: this.vatForm.get('serviceCharge')?.value,
      vatOnServiceCharge: this.vatForm.get('vatOnServiceCharge')?.value,
      totalAmount: this.vatForm.get('totalAmount')?.value,
      transferAmount: 0,
      customerName: this.vatForm.get('customerName')?.value
    };
  
    // Call the backend service to create the VAT collection transaction.
    this.vatService.createVatCollectionTransaction(dto).subscribe({
      next: () => {
        this.toastr.success('Transaction saved as pending.', 'Success');
        this.vatForm.reset();
        this.customerName = null;
        this.errorMsg = null;
        this.isPayDisabled = true;
      },
      error: (err) => {
        // Attempt to extract a detailed error message from the backend response.
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
