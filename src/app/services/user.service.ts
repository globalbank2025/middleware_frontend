import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

export interface UserWithRoles {
  id: string;
  userName: string;
  email: string;
  branchName: string; // Updated property for branch name
  roles: string[];
  isLockedOut: boolean; // <--- Add this
}

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private apiUrl = environment.apiUrl; // Adjust as needed
  private baseUrl = environment.apiUrl;

  constructor(private http: HttpClient) { }

  getUsersWithRoles(): Observable<UserWithRoles[]> {
    return this.http.get<UserWithRoles[]>(`${this.apiUrl}/User/list`);

  }
  // NEW METHOD: Reset user password to default ("Gbe@1234")
  resetUserPassword(userId: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/reset-password/${userId}`, {});
  }

  // NEW METHOD: Lock user account
  lockUserAccount(userId: string): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/lock-user/${userId}`, {});
  }
  unlockUserAccount(userId: string): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/unlock-user/${userId}`, {});
  }
  // Change Password
  // In auth.service.ts
changePassword(changePasswordDto: { currentPassword: string, newPassword: string, confirmNewPassword: string }): Observable<any> {
  return this.http.post<any>(`${this.apiUrl}/change-password`, changePasswordDto);
}

}
