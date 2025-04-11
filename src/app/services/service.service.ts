import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Service } from '../models/service.model';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ServiceService {
  //private baseUrl = 'https://localhost:7033/api/Service'; // Adjust to match your API
  private baseUrl = `${environment.apiUrl}/Service`;


  constructor(private http: HttpClient) { }

  getAllServices(): Observable<Service[]> {
    return this.http.get<Service[]>(this.baseUrl);
  }

  getServiceById(id: number): Observable<Service> {
    return this.http.get<Service>(`${this.baseUrl}/${id}`);
  }

  createService(service: Service): Observable<Service> {
    return this.http.post<Service>(this.baseUrl, service);
  }

  updateService(id: number, service: Service): Observable<any> {
    return this.http.put(`${this.baseUrl}/${id}`, service);
  }

  deleteService(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
}
