import { Injectable } from '@angular/core';
import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { Router } from '@angular/router';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {
  constructor(private router: Router) {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    // Retrieve the full login response from localStorage
    const loginResponseStr = localStorage.getItem('loginResponse');
    if (loginResponseStr) {
      try {
        const loginResponse = JSON.parse(loginResponseStr);
        // Assume the backend returns an ISO string in "expiration"
        const expiration = new Date(loginResponse.expiration);
        if (new Date() > expiration) {
          // Token expired: clear storage and redirect to login
          localStorage.removeItem('auth_token');
          localStorage.removeItem('loginResponse');
          this.router.navigate(['/login']);
          return throwError(() => new Error('Session expired'));
        }
      } catch (error) {
        console.error('Error parsing loginResponse:', error);
      }
    }

    const token = localStorage.getItem('auth_token');
    if (token) {
      const clonedRequest = req.clone({
        setHeaders: { Authorization: `Bearer ${token}` }
      });
      return next.handle(clonedRequest);
    }
    return next.handle(req);
  }
}
