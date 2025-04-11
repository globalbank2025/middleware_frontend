import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import { ToastrService } from 'ngx-toastr';
import { TransactionDetailDialogComponent } from '../transaction-detail-dialog/transaction-detail-dialog.component';
import { ReconciliationTransaction, ReconciliationTransactionService } from 'src/app/services/reconciliation-transaction.service';

@Component({
  selector: 'app-reconciliation-transaction-list',
  templateUrl: './reconciliation-transaction-list.component.html',
  styleUrls: ['./reconciliation-transaction-list.component.css']
})
export class ReconciliationTransactionListComponent implements OnInit {
  displayedColumns: string[] = [
    'issuerBank',
    'acquirerBank',
    'transactionAmount',
    'transactionDateTime',
    'transactionDescription',
    'actions'
  ];
  dataSource = new MatTableDataSource<ReconciliationTransaction>([]);
  searchKey = '';
  selectedFile: File | null = null;

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(
    private transactionService: ReconciliationTransactionService,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) { }

  ngOnInit(): void {
    this.loadTransactions();
  }

  loadTransactions(): void {
    this.transactionService.getAll().subscribe({
      next: (response) => {
        if (response.success) {
          this.dataSource.data = response.data;
          setTimeout(() => {
            this.dataSource.paginator = this.paginator;
            this.dataSource.sort = this.sort;
          });
        } else {
          this.toastr.error(response.message, 'Error');
        }
      },
      error: (err) => {
        this.toastr.error(err.error?.message || 'Error loading transactions', 'Error');
      }
    });
  }

  applyFilter(): void {
    this.dataSource.filter = this.searchKey.trim().toLowerCase();
  }

  clearSearch(): void {
    this.searchKey = '';
    this.applyFilter();
  }

  openDetailDialog(transaction: ReconciliationTransaction): void {
    this.dialog.open(TransactionDetailDialogComponent, {
      width: '800px',
      data: transaction
    });
  }

  onFileSelected(event: any): void {
    const file: File = event.target.files[0];
    if (file) {
      this.selectedFile = file;
    }
  }

  uploadFile(): void {
    if (!this.selectedFile) {
      this.toastr.error('No file selected', 'Error');
      return;
    }
    this.transactionService.uploadExcel(this.selectedFile).subscribe({
      next: (response) => {
        if (response.success) {
          this.toastr.success(response.message, 'Success');
          this.loadTransactions();
        } else {
          this.toastr.error(response.message, 'Error');
        }
      },
      error: (err) => {
        this.toastr.error(err.error?.message || 'Upload failed', 'Error');
      }
    });
  }

  deleteAll(): void {
    if (confirm('Are you sure you want to delete all transactions?')) {
      this.transactionService.deleteAll().subscribe({
        next: (response) => {
          if (response.success) {
            this.toastr.success(response.message, 'Success');
            this.loadTransactions();
          } else {
            this.toastr.error(response.message, 'Error');
          }
        },
        error: (err) => {
          this.toastr.error(err.error?.message || 'Delete failed', 'Error');
        }
      });
    }
  }
}
