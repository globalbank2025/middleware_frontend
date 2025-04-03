import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiCredentials } from '../models/api-credentials.model';

@Injectable({
  providedIn: 'root'
})
export class ApiCredentialsService {
  private baseUrl = 'http://10.10.14.21:4060/api/ApiCredentials'; // Adjust to match your API

  constructor(private http: HttpClient) { }

  getAllApiCredentials(): Observable<ApiCredentials[]> {
    return this.http.get<ApiCredentials[]>(this.baseUrl);
  }

  getApiCredentialsById(id: number): Observable<ApiCredentials> {
    return this.http.get<ApiCredentials>(`${this.baseUrl}/${id}`);
  }

  createApiCredentials(data: ApiCredentials): Observable<ApiCredentials> {
    return this.http.post<ApiCredentials>(this.baseUrl, data);
  }

  updateApiCredentials(id: number, data: ApiCredentials): Observable<any> {
    return this.http.put(`${this.baseUrl}/${id}`, data);
  }

  deleteApiCredentials(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
}
