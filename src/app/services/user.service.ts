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
  private apiUrl = 'https://localhost:7033/api/Auth'; // Adjust as needed

  constructor(private http: HttpClient) { }

  getUsersWithRoles(): Observable<UserWithRoles[]> {
    return this.http.get<UserWithRoles[]>(`https://localhost:7033/api/User/list`);
  }
  // NEW METHOD: Reset user password to default ("Gbe@1234")
  resetUserPassword(userId: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/reset-password/${userId}`, {});
  }

  // NEW METHOD: Lock user account
  lockUserAccount(userId: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/lock-user/${userId}`, {});
  }
  // Change Password
  // In auth.service.ts
changePassword(changePasswordDto: { currentPassword: string, newPassword: string, confirmNewPassword: string }): Observable<any> {
  return this.http.post<any>(`${this.apiUrl}/change-password`, changePasswordDto);
}

}
