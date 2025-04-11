import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface ReconciliationTransaction {
  issuerBank: string;
  acquirerBank: string;
  messageTypeIdentifier: string;
  maskedCardNumber: string;
  transactionAmount: number;
  currencyCode: string;
  transactionDateTime: string; // ISO formatted date
  transactionDescription: string;
  terminalId: string;
  transactionLocation: string;
  systemTraceAuditNumber: string;
  referenceNumber: string;
  authResponseCode: string;
  frontendUtrnNo: string;
  backendUtrnNo: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message: string;
  data: T;
}

@Injectable({
  providedIn: 'root'
})
export class ReconciliationTransactionService {
  //private baseUrl = 'https://localhost:7033/api/ReconciliationTransaction';
  private baseUrl = `${environment.apiUrl}/ReconciliationTransaction`;


  constructor(private http: HttpClient) { }

  getAll(): Observable<ApiResponse<ReconciliationTransaction[]>> {
    return this.http.get<ApiResponse<ReconciliationTransaction[]>>(this.baseUrl);
  }

  deleteAll(): Observable<ApiResponse<string>> {
    return this.http.delete<ApiResponse<string>>(this.baseUrl);
  }

  uploadExcel(file: File): Observable<ApiResponse<string>> {
    const formData = new FormData();
    formData.append('file', file);
    return this.http.post<ApiResponse<string>>(`${this.baseUrl}/upload`, formData);
  }
}
