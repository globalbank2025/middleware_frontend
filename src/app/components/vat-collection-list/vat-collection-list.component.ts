import { Component, OnInit, ViewChild } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { VatCollectionService, VatCollectionTransactionDto } from '../../services/vat-collection.service';
import { ToastrService } from 'ngx-toastr';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import { InvoiceStateService } from '../../services/invoice-state.service';

@Component({
  selector: 'app-vat-collection-list',
  templateUrl: './vat-collection-list.component.html',
  styleUrls: ['./vat-collection-list.component.css']
})
export class VatCollectionListComponent implements OnInit {
  displayedColumns: string[] = [
    'accountNumber',
    'serviceIncomeGl',
    'transferAmount',
    'serviceCharge',
    'vatOnServiceCharge',
    'totalAmount',
    'status',
    'serviceChargeRef',
    'vatRef',
    'createdAt',
    'actions'
  ];

  dataSource = new MatTableDataSource<VatCollectionTransactionDto>([]);
  loading = false;
  errorMsg: string | null = null;
  currentStatus: string = 'PENDING';

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;

  constructor(
    private vatService: VatCollectionService,
    private toastr: ToastrService,
    private router: Router,
    private invoiceState: InvoiceStateService, // <-- Inject our InvoiceStateService
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe((params: ParamMap) => {
      const status = params.get('status');
      this.currentStatus = status ? status : 'PENDING';
      this.fetchTransactions();
    });
  }

  fetchTransactions(): void {
    this.loading = true;
    this.vatService.getVatCollectionsByStatus(this.currentStatus).subscribe({
      next: (res) => {
        this.dataSource.data = res;
        // Optional: ensure numeric sorting for numeric fields.
        this.dataSource.sortingDataAccessor = (item, property) => {
          switch (property) {
            case 'transferAmount':
            case 'serviceCharge':
            case 'vatOnServiceCharge':
            case 'totalAmount':
              return Number((item as any)[property]) || 0;
            default:
              return (item as any)[property];
          }
        };
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
        this.loading = false;
      },
      error: (err) => {
        console.error('Fetch error', err);
        this.errorMsg = `Failed to load ${this.currentStatus} VAT transactions.`;
        this.loading = false;
      }
    });
  }

  applyFilter(filterValue: string): void {
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  // Approve existing transaction THEN redirect to the invoice page
  onApprove(row: VatCollectionTransactionDto): void {
    if (!row.id) return;

    // 1) Send the approve request to the backend
    this.vatService.approveVatCollection(row.id).subscribe({
      next: () => {
        // 2) On success, show a quick success toast
        this.toastr.success('Transaction approved successfully.', 'Approved');

        // 3) If you already have all invoice data in `row`, adapt as needed:
        const invoiceData = {
          customerName: row.customerName,
          accountNumber: row.accountNumber,
          customerVatRegistrationNo: row.customerVatRegistrationNo,
          customerTinNo: row.customerTinNo,
          customerTelephone: row.customerTelephone,
          principalAmount: row.principalAmount, // Use principalAmount from the record
          serviceCharge: row.serviceCharge,
          vatOnServiceCharge: row.vatOnServiceCharge,
          totalAmount: row.totalAmount,
          bankInfo: {
            bankName: 'Global Bank Ethiopia',
            tinNo: '0000006379',
            vatRegNo: '68784',
            vatRegDate: 'March 10, 2007',
            address: 'Kirkos Woreda 07 H.No — Addis Ababa, Ethiopia',
            tel: '251-11-551-11-56'
          }
        };
        

        // 4) Store this invoice data in the InvoiceStateService
        this.invoiceState.setInvoiceData(invoiceData);

        // 5) Finally, redirect to the invoice page
        this.router.navigate(['/invoice']);
      },
      error: (err) => {
        let errorMessage = 'An error occurred';
        if (err.error) {
          // parse error if your API sends JSON
          if (typeof err.error === 'object' && err.error.error) {
            errorMessage = err.error.error;
          } else if (typeof err.error === 'string') {
            try {
              const parsed = JSON.parse(err.error);
              errorMessage = parsed.error || err.error;
            } catch (e) {
              errorMessage = err.error;
            }
          }
        }
        this.toastr.error(errorMessage, 'Error');
        console.error(err);
      }
    });
  }

  onDelete(row: VatCollectionTransactionDto): void {
    if (!row.id) return;
    if (!confirm(`Are you sure you want to reject/delete transaction #${row.id}?`)) {
      return;
    }
    this.vatService.deleteVatCollection(row.id).subscribe({
      next: () => {
        this.toastr.success('Transaction deleted.', 'Deleted');
        this.fetchTransactions();
      },
      error: (err) => {
        console.error('Error fetching transaction logs:', err);
        const errorMessage = err.error?.error || 'An unexpected error occurred.';
        this.toastr.error(errorMessage, 'Error');
      }
    });
  }

  // The dropdown calls either `approve` or `reject`
  onSelectAction(action: string, row: VatCollectionTransactionDto): void {
    if (action === 'approve') {
      this.onApprove(row);
    } else if (action === 'reject') {
      this.onReject(row);
    }
  }

  onReject(row: VatCollectionTransactionDto): void {
    if (!row.id) return;
    if (!confirm(`Are you sure you want to reject transaction #${row.id}?`)) {
      return;
    }
    this.vatService.rejectVatCollection(row.id).subscribe({
      next: (res) => {
        this.toastr.success(res.message || `Transaction #${row.id} rejected.`, 'Rejected');
        this.fetchTransactions();
      },
      error: (err) => {
        console.error('Error rejecting transaction:', err);
        let errorMessage = 'An error occurred while rejecting the transaction.';
        if (err.error) {
          if (typeof err.error === 'object' && err.error.error) {
            errorMessage = err.error.error;
          } else if (typeof err.error === 'string') {
            try {
              const parsed = JSON.parse(err.error);
              errorMessage = parsed.error || err.error;
            } catch (e) {
              errorMessage = err.error;
            }
          }
        }
        this.toastr.error(errorMessage, 'Error');
      }
    });
  }
}
