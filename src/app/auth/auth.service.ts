import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BehaviorSubject, Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

// Example imports from your models folder – adjust as necessary
import { Branch } from '../models/branchs';
import { Role } from '../models/role';
import { ServiceIncomeGl } from '../models/service-income-gl';

/**
 * Represents the structure of the login response from the backend.
 */
export interface LoginResponse {
  token: string;
  expiration: string;
  user: {
    id: string;
    userName: string;
    email: string;
    branchId: number;
    branchName: string;
    roles: string[];
  };
}

/**
 * Represents a user registration payload.
 */
export interface RegisterUser {
  email: string;
  password: string;
  branchId: number;
  role: string;
}

/**
 * Represents a user object returned from /api/auth/users
 */
export interface UserDto {
  id: string;
  email: string;
  userName: string;
  branchId: number;
  branchName: string;
  roles: string[];
}

/**
 * Represents the shape of a role object that includes both Id and Name.
 */
export interface RoleInfo {
  id: string;
  name: string;
}

/**
 * Represents a shortened version of a permission with just Id and Name.
 */
export interface PermissionShort {
  id: number;
  name: string;
}

/**
 * Represents the full permission data from the server, e.g. GET /Role/permissions/all
 */
export interface PermissionDto {
  id: number;
  name: string;
  description: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private baseUrl = 'https://localhost:7033/api'; // Adjust to your actual API base
  private tokenKey = 'auth_token';

  private currentUserSubject = new BehaviorSubject<any>(null);
  currentUser$ = this.currentUserSubject.asObservable();

  // We'll store the full login response (including roles) here.
  private userSubject = new BehaviorSubject<LoginResponse | null>(null);
  public user$ = this.userSubject.asObservable();

  constructor(private http: HttpClient) {
    // Re-initialize user and token from localStorage if present
    const savedResponse = localStorage.getItem('loginResponse');
    if (savedResponse) {
      try {
        const parsed = JSON.parse(savedResponse);
        this.userSubject.next(parsed);
        this.currentUserSubject.next(parsed.user);
      } catch (e) {
        console.error('Error parsing saved login response:', e);
        // If parse fails, remove invalid local storage
        localStorage.removeItem('auth_token');
        localStorage.removeItem('loginResponse');
      }
    }
  }

  // -------------------------------------------------------------
  // Auth / Login
  // -------------------------------------------------------------
  login(email: string, password: string): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${this.baseUrl}/auth/login`, { email, password })
      .pipe(
        tap(response => {
          localStorage.setItem(this.tokenKey, response.token);
          localStorage.setItem('loginResponse', JSON.stringify(response));
          this.userSubject.next(response);
          this.currentUserSubject.next(response.user);
        })
      );
  }

  register(user: RegisterUser): Observable<any> {
    return this.http.post(`${this.baseUrl}/auth/register`, user);
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem('loginResponse');
    this.userSubject.next(null);
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  getCurrentUser() {
    return this.currentUserSubject.value;
  }

  // -------------------------------------------------------------
  // Branches
  // -------------------------------------------------------------
  getBranches(): Observable<any> {
    return this.http.get(`${this.baseUrl}/branch`);
  }

  getAllBranches(): Observable<Branch[]> {
    return this.http.get<Branch[]>(`${this.baseUrl}/branch`);
  }

  createBranch(payload: Partial<Branch>): Observable<any> {
    return this.http.post(`${this.baseUrl}/branch`, payload);
  }

  updateBranch(branchId: number, data: Partial<Branch>): Observable<any> {
    return this.http.put(`${this.baseUrl}/branch/${branchId}`, data);
  }

  deleteBranch(branchId: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/branch/${branchId}`);
  }

  // -------------------------------------------------------------
  // Roles
  // -------------------------------------------------------------
  getAllRoles(): Observable<string[]> {
    return this.http.get<string[]>(`${this.baseUrl}/Role/all`);
  }

  getRoles(): Observable<string[]> {
    return this.getAllRoles();
  }

  // GET /api/Role/all-with-id => must exist on your backend
  getAllRolesWithId(): Observable<RoleInfo[]> {
    return this.http.get<RoleInfo[]>(`${this.baseUrl}/Role/all-with-id`);
  }

  createRole(payload: Partial<Role>): Observable<any> {
    return this.http.post(`${this.baseUrl}/role/create`, payload);
  }

  updateRole(roleId: number, data: Partial<Role>): Observable<any> {
    return this.http.put(`${this.baseUrl}/roles/${roleId}`, data);
  }

  deleteRole(roleId: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/role/${roleId}`);
  }

  getAllUsers(): Observable<UserDto[]> {
    return this.http.get<UserDto[]>(`${this.baseUrl}/auth/users`);
  }

  assignRole(payload: { email: string; roleName: string }): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/Role/assign`, payload);
  }

  getUserRoles(email: string): Observable<string[]> {
    return this.http.get<string[]>(`${this.baseUrl}/Role/user-roles/${email}`);
  }

  removeRole(payload: { email: string; roleName: string }): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/Role/remove`, payload);
  }

  // -------------------------------------------------------------
  // Service Income GL
  // -------------------------------------------------------------
  getAllServiceIncomeGl(): Observable<ServiceIncomeGl[]> {
    return this.http.get<ServiceIncomeGl[]>(`${this.baseUrl}/serviceincomegl`);
  }

  createServiceIncomeGl(payload: Partial<ServiceIncomeGl>): Observable<any> {
    return this.http.post(`${this.baseUrl}/serviceincomegl`, payload);
  }

  updateServiceIncomeGl(id: number, data: Partial<ServiceIncomeGl>): Observable<any> {
    return this.http.put(`${this.baseUrl}/serviceincomegl/${id}`, data);
  }

  deleteServiceIncomeGl(id: number): Observable<any> {
    return this.http.delete(`${this.baseUrl}/serviceincomegl/${id}`);
  }

  // -------------------------------------------------------------
  // Permissions
  // -------------------------------------------------------------
  getAllPermissions(): Observable<PermissionDto[]> {
    return this.http.get<PermissionDto[]>(`${this.baseUrl}/Role/permissions/all`);
  }

  createPermission(payload: { permissionName: string; description?: string }): Observable<any> {
    return this.http.post(`${this.baseUrl}/Role/permissions/create`, payload);
  }

  getRolePermissionsById(roleId: string): Observable<PermissionShort[]> {
    return this.http.get<PermissionShort[]>(`${this.baseUrl}/Role/permissions/role/${roleId}`);
  }

  assignPermissionToRole(payload: { roleName: string; permissionName: string }): Observable<any> {
    return this.http.post(`${this.baseUrl}/Role/permissions/assign`, payload);
  }

  removePermissionFromRole(payload: { roleName: string; permissionName: string }): Observable<any> {
    return this.http.post(`${this.baseUrl}/Role/permissions/remove`, payload);
  }

  deletePermission(permissionId: number): Observable<any> {
    // Adjust `this.apiUrl` to match your actual controller route, e.g.:
    // If `apiUrl = 'https://localhost:5001/api/Role'`, then final request is:
    //    DELETE https://localhost:5001/api/Role/permissions/delete/123
    //return this.http.delete<any>(`${this.baseUrl}/permissions/delete/${permissionId}`);
    return this.http.delete<any>(`${this.baseUrl}/Role/permissions/delete/${permissionId}`);

  }
  

  
}
