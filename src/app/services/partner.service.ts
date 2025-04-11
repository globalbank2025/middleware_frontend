import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Partner } from '../models/partner.model';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class PartnerService {
  //private baseUrl = 'https://localhost:7033/api/Partner'; // adjust as needed
  private baseUrl = `${environment.apiUrl}/partner`;

  constructor(private http: HttpClient) { }

  getAllPartners(): Observable<Partner[]> {
    return this.http.get<Partner[]>(this.baseUrl);
    
  }

  getPartnerById(id: number): Observable<Partner> {
    return this.http.get<Partner>(`${this.baseUrl}/${id}`);
  }

  createPartner(partner: Partner): Observable<Partner> {
    return this.http.post<Partner>(this.baseUrl, partner);
  }

  updatePartner(id: number, partner: Partner): Observable<any> {
    return this.http.put(`${this.baseUrl}/${id}`, partner);
  }

  deletePartner(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/${id}`);
  }
}
