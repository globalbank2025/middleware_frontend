import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { AuthService } from '../auth/auth.service';
import { Observable, of } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class RoleGuard implements CanActivate {

  constructor(
    private authService: AuthService,
    private router: Router
  ) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): Observable<boolean> {
    const requiredRole = route.data['role'] as string;
    if (!requiredRole) {
      // If no role is specified, allow
      return of(true);
    }

    return this.authService.user$.pipe(
      map(userData => {
        if (!userData) {
          // Not logged in, redirect to login
          this.router.navigate(['/login']);
          return false;
        }
        const userRoles = userData.user?.roles || [];
        if (userRoles.includes(requiredRole)) {
          return true;
        } else {
          // If missing role, redirect to a safe place (dashboard)
          this.router.navigate(['/dashboard']);
          return false;
        }
      })
    );
  }
}
