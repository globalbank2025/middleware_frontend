import { Component, OnInit, ViewChild } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import {
  TransactionLog,
  TransactionLogService
} from 'src/app/services/transaction-log.service';
import { JsonPayloadDialogComponent } from '../json-payload-dialog/json-payload-dialog.component';

@Component({
  selector: 'app-transaction-log-list',
  templateUrl: './transaction-log-list.component.html',
  styleUrls: ['./transaction-log-list.component.css']
})
export class TransactionLogListComponent implements OnInit {
  displayedColumns: string[] = [
    'customerAccount',
    'customerName',
    'transactionAmount',
    'approvedBy',
    'approvedAt',
    'transactionReference',
    'actions'
  ];

  dataSource = new MatTableDataSource<TransactionLog>([]);
  searchKey = '';

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(
    private transactionLogService: TransactionLogService,
    private dialog: MatDialog
  ) {}

  ngOnInit(): void {
    this.loadTransactionLogs();
  }

  loadTransactionLogs(): void {
    this.transactionLogService.getTransactionLogs().subscribe({
      next: (logs) => {
        this.dataSource.data = logs;
        setTimeout(() => {
          if (this.paginator) {
            this.dataSource.paginator = this.paginator;
          }
          if (this.sort) {
            this.dataSource.sort = this.sort;
          }
        });
      },
      error: (err) => {
        console.error('Error fetching transaction logs:', err);
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

  openJsonDialog(title: string, jsonString: string): void {
    this.dialog.open(JsonPayloadDialogComponent, {
      width: '800px',
      data: { title, jsonString }
    });
  }
}
