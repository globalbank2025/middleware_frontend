import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { ReconciliationTransaction } from 'src/app/services/reconciliation-transaction.service';

@Component({
  selector: 'app-transaction-detail-dialog',
  templateUrl: './transaction-detail-dialog.component.html',
  styleUrls: ['./transaction-detail-dialog.component.css']
})
export class TransactionDetailDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<TransactionDetailDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { transaction: ReconciliationTransaction }
  ) {}

  close(): void {
    this.dialogRef.close();
  }
}
