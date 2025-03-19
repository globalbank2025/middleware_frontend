import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface UserWithRoles {
  id: string;
  userName: string;
  email: string;
  branchName: string; // Updated property for branch name
  roles: string[];
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private apiUrl = 'https://localhost:7033/api/User'; // Adjust as needed

  constructor(private http: HttpClient) { }

  getUsersWithRoles(): Observable<UserWithRoles[]> {
    return this.http.get<UserWithRoles[]>(`${this.apiUrl}/list`);
  }
}
