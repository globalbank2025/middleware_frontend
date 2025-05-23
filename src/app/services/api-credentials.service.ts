import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ApiCredentials } from '../models/api-credentials.model';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiCredentialsService {
  //private baseUrl = 'https://localhost:7033/api/ApiCredentials'; // Adjust to match your API
  private baseUrl = `${environment.apiUrl}/ApiCredentials`;


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
