import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable({
  providedIn: 'root'
})
export class RoleService {
  // Adjust the base URL as per your environment or backend configuration
  //private baseUrl = 'https://localhost:7033/api/Role';
  private baseUrl = `${environment.apiUrl}/Role`;


  constructor(private http: HttpClient) {}

  // GET all roles: returns an array of strings, e.g. ["Admin","Maker"]
  getAllRoles(): Observable<string[]> {
    return this.http.get<string[]>(`${this.baseUrl}/all`);
  }

  // POST a new role (payload: { roleName: "string" })
  createRole(roleName: string): Observable<any> {
    const body = { roleName }; // { "roleName": "theInput" }
    return this.http.post<any>(this.baseUrl, body);
  }
}
