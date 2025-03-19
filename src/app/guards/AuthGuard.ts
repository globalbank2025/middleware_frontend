import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private router: Router) {}

  canActivate(): boolean {
    const loginResponseStr = localStorage.getItem('loginResponse');
    if (!loginResponseStr) {
      this.router.navigate(['/login']);
      return false;
    }
    try {
      const loginResponse = JSON.parse(loginResponseStr);
      const expiration = new Date(loginResponse.expiration);
      if (new Date() > expiration) {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('loginResponse');
        this.router.navigate(['/login']);
        return false;
      }
    } catch (error) {
      this.router.navigate(['/login']);
      return false;
    }
    return true;
  }
}
