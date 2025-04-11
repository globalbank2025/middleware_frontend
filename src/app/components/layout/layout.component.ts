import { Component, OnInit, ViewChild } from '@angular/core';
import { MatSidenav } from '@angular/material/sidenav';
import { AuthService } from '../../auth/auth.service';
import { map } from 'rxjs/operators';
import { Observable } from 'rxjs';
import { Router } from '@angular/router';
import { BreakpointObserver, Breakpoints } from '@angular/cdk/layout';

@Component({
  selector: 'app-layout',
  templateUrl: './layout.component.html',
  styleUrls: ['./layout.component.css']
})
export class LayoutComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  // Holds the logged-in user info
  currentUser: any;
  showUserDetails = false;

  // Submenu toggles
  isVatExpanded = false;
  isAdministrationExpanded = false;
  isViewerExpanded = false;

  // Role-based observables
  isAdmin$!: Observable<boolean>;
  isMakerOrChecker$!: Observable<boolean>;
  isViewer$!: Observable<boolean>;

  // Mobile detection
  isMobile = false;

  // Dynamic year for the footer
  currentYear: number = new Date().getFullYear();

  constructor(
    private authService: AuthService,
    private router: Router,
    private breakpointObserver: BreakpointObserver
  ) {}

  ngOnInit(): void {
    // 1) Subscribe to the user$ observable so we always have fresh user info
    this.authService.user$.subscribe(userData => {
      this.currentUser = userData;
    });

    // 2) Attempt local storage fallback if no user data in the subscription
    if (!this.currentUser) {
      const stored = this.authService.getCurrentUser();
      if (stored) {
        this.currentUser = stored;
      }
    }

    // 3) isAdmin$ indicates if user has Admin role
    this.isAdmin$ = this.authService.user$.pipe(
      map(u => !!(u && u.user.roles.includes('Admin')))
    );

    // 4) isMakerOrChecker$
    this.isMakerOrChecker$ = this.authService.user$.pipe(
      map(u => !!(u && (u.user.roles.includes('Maker') || u.user.roles.includes('Checker'))))
    );

    // 5) isViewer$
    this.isViewer$ = this.authService.user$.pipe(
      map(u => !!(u && u.user.roles.includes('Viewer')))
    );

    // 6) Watch screen size => if mobile, use over mode for sidenav
    this.breakpointObserver.observe([Breakpoints.Handset]).subscribe(result => {
      this.isMobile = result.matches;
      if (this.isMobile) {
        this.sidenav.mode = 'over';
        this.sidenav.close();
      } else {
        this.sidenav.mode = 'side';
        this.sidenav.open();
      }
    });
  }

  // Toggle the user detail dropdown
  toggleUserDetails(): void {
    this.showUserDetails = !this.showUserDetails;
  }

  // Close user detail when mouse leaves
  closeUserDetails(): void {
    this.showUserDetails = false;
  }

  // Logout logic
  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  // Close sidenav in mobile mode
  closeIfMobile(): void {
    if (this.isMobile && this.sidenav) {
      this.sidenav.close();
    }
  }

  // Expand/collapse submenus
  toggleVatSubmenu(): void {
    this.isVatExpanded = !this.isVatExpanded;
  }
  toggleAdministrationSubmenu(): void {
    this.isAdministrationExpanded = !this.isAdministrationExpanded;
  }
  toggleViewerSubmenu(): void {
    this.isViewerExpanded = !this.isViewerExpanded;
  }
}
