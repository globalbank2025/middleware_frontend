import { Component } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';

@Component({
  selector: 'app-server-testing',
  templateUrl: './server-testing.component.html',
  styleUrls: ['./server-testing.component.css']
})
export class ServerTestingComponent {
  // Example public test URL returning JSON
  coreBankingUrl: string = 'https://jsonplaceholder.typicode.com/todos/1';

  // Another example array of test URLs
  thirdPartyUrls: string[] = [
    'https://jsonplaceholder.typicode.com/posts/1',
    'https://jsonplaceholder.typicode.com/comments/1'
  ];

  coreBankingStatus: string | null = null;
  thirdPartyStatuses: { [key: string]: string } = {};

  constructor(private http: HttpClient) { }

  pingCoreBanking() {
    this.coreBankingStatus = 'Testing...';
    this.http.get(this.coreBankingUrl, { responseType: 'text' }).subscribe({
      next: () => {
        this.coreBankingStatus = 'Online';
      },
      error: (error: HttpErrorResponse) => {
        this.coreBankingStatus = `Offline or Error: ${error.message}`;
      }
    });
  }

  pingThirdParties() {
    for (const url of this.thirdPartyUrls) {
      this.thirdPartyStatuses[url] = 'Testing...';
      this.http.get(url, { responseType: 'text' }).subscribe({
        next: () => {
          this.thirdPartyStatuses[url] = 'Online';
        },
        error: (error: HttpErrorResponse) => {
          this.thirdPartyStatuses[url] = `Offline or Error: ${error.message}`;
        }
      });
    }
  }
}
