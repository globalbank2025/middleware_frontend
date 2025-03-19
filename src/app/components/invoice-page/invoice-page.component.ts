import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { InvoiceStateService } from '../../services/invoice-state.service';

@Component({
  selector: 'app-invoice-page',
  templateUrl: './invoice-page.component.html',
  styleUrls: ['./invoice-page.component.css']
})
export class InvoicePageComponent implements OnInit {
  invoice: any = null;

  constructor(
    private invoiceState: InvoiceStateService,
    private router: Router
  ) {}

  ngOnInit(): void {
    // Retrieve the stored invoice data
    this.invoice = this.invoiceState.getInvoiceData();
    if (!this.invoice) {
      // If no data is found, go back to the VAT Collection page
      this.router.navigate(['/vat-collection']);
    }
  }

  // Print / Save as PDF
  printInvoice() {
    window.print();
  }
}
