import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface CustomerAccountResponse {
  customerName: string;
}

export interface AccountStatusBalanceResponse {
  customerName: string;
  acStatNoDr: string;
  acStatNoCr: string;
  frozen: string;
  availableBalance: string;
}

export interface ServiceIncomeGl {
  id: number;
  glCode: string;
  name: string;
  description: string;
  // New fields to match your backend
  status?: 'Open' | 'Closed';
  calculationType?: 'Flat' | 'Rate';
  flatPrice?: number;
  rate?: number;
}

export interface VatCollectionTransactionDto {
  branchCode: number;
  accountNumber: string;
  customerVatRegistrationNo?: string;
  customerTinNo?: string;
  customerTelephone?: string;
  principalAmount: number;
  transferAmount: number;
  serviceIncomeGl: string;
  serviceCharge: number;
  vatOnServiceCharge: number;
  totalAmount: number;
  customerName: string;
  // Optional if returned from the server
  id?: number;
  status?: string;
  createdAt?: string;
}

@Injectable({ providedIn: 'root' })
export class VatCollectionService {
  private apiBaseUrl = environment.apiUrl;
  private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) {}

  queryCustomerAccount(brn: string, acc: string): Observable<CustomerAccountResponse> {
    const url = `${this.apiBaseUrl}/CustomerAccount/query`;
    const payload = { BRN: brn, ACC: acc };
    return this.http.post<CustomerAccountResponse>(url, payload);
  }

  queryAccountStatusBalance(brn: string, acc: string): Observable<AccountStatusBalanceResponse> {
    const url = `${this.apiBaseUrl}/CustomerAccount/status-balance`;
    const payload = { BRN: brn, ACC: acc };
    return this.http.post<AccountStatusBalanceResponse>(url, payload);
  }

  getServiceIncomeGl(): Observable<ServiceIncomeGl[]> {
    return this.http.get<ServiceIncomeGl[]>(`${this.apiBaseUrl}/ServiceIncomeGl`);
  }

  createVatCollectionTransaction(dto: VatCollectionTransactionDto): Observable<any> {
    const url = `${this.apiBaseUrl}/CustomerAccount/vat-collection`;
    return this.http.post<any>(url, dto);
  }

  getPendingVatCollections(): Observable<VatCollectionTransactionDto[]> {
    const url = `${this.apiBaseUrl}/CustomerAccount/vat-collection`;
    return this.http.get<VatCollectionTransactionDto[]>(url);
  }

  approveVatCollection(id: number): Observable<any> {
    const url = `${this.apiBaseUrl}/CustomerAccount/vat-collection/${id}/approve`;
    return this.http.put<any>(url, {});
  }
  
  deleteVatCollection(id: number): Observable<any> {
    const url = `${this.apiBaseUrl}/CustomerAccount/vat-collection/${id}`;
    return this.http.delete<any>(url);
  }

  // GET: list of transactions by status (PENDING, APPROVED, REJECTED)
  getVatCollectionsByStatus(status: string): Observable<VatCollectionTransactionDto[]> {
    return this.http.get<VatCollectionTransactionDto[]>(
      `${this.apiBaseUrl}/CustomerAccount/vat-collection/status/${status}`
    );
  }

  // PUT: reject a transaction (set status to REJECTED)
  rejectVatCollection(id: number): Observable<any> {
    return this.http.put<any>(
      `${this.apiBaseUrl}/CustomerAccount/vat-collection/${id}/reject`, {}
    );
  }
}
