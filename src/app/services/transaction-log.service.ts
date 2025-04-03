import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

// Example model interface for transaction logs
export interface TransactionLog {
  id: number;
  vatCollectionTransactionId: number;
  customerAccount: string;
  transactionAmount: number;
  customerName: string;
  requestPayload: string;
  responsePayload: string;
  transactionReference: string;
  approvedBy: string;
  approvedAt: string;    // or Date
  createdAt: string;     // or Date
}

@Injectable({
  providedIn: 'root'
})
export class TransactionLogService {
  // Ideally, read this from environment.ts
  private readonly baseUrl = 'http://10.10.14.21:4060/api'; 

  constructor(private http: HttpClient) {}

  getTransactionLogs(): Observable<TransactionLog[]> {
    // The endpoint matches our .NET controller route
    return this.http.get<TransactionLog[]>(`${this.baseUrl}/CustomerAccount/transaction-logs`);
  }
}
