// invoice-state.service.ts
import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class InvoiceStateService {
  private invoiceData: any = null;

  setInvoiceData(data: any): void {
    this.invoiceData = data;
  }

  getInvoiceData(): any {
    return this.invoiceData;
  }
}
