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
  currentUser: any;
  
  // Toggle for VAT submenu (Maker/Checker)
  isVatExpanded: boolean = false;
  
  // Toggle for Administration submenu (Admin only)
  isAdministrationExpanded: boolean = false;

  isAdmin$!: Observable<boolean>;
  isMakerOrChecker$!: Observable<boolean>;
  isMobile = false;

  constructor(
    private authService: AuthService,
    private router: Router,
    private breakpointObserver: BreakpointObserver
  ) {
    this.currentUser = this.authService.getCurrentUser();
  }

  ngOnInit(): void {
    // isAdmin$ indicates if user has Admin role
    this.isAdmin$ = this.authService.user$.pipe(
      map(userData => {
        if (!userData) return false;
        return userData.user.roles.includes('Admin');
      })
    );

    // isMakerOrChecker$ indicates if user has Maker or Checker role
    this.isMakerOrChecker$ = this.authService.user$.pipe(
      map(userData => {
        if (!userData) return false;
        return userData.user.roles.includes('Maker') || userData.user.roles.includes('Checker');
      })
    );

    // Observe screen size for mobile devices
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

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  closeIfMobile(): void {
    if (this.isMobile && this.sidenav) {
      this.sidenav.close();
    }
  }

  toggleVatSubmenu(): void {
    this.isVatExpanded = !this.isVatExpanded;
  }
  
  toggleAdministrationSubmenu(): void {
    this.isAdministrationExpanded = !this.isAdministrationExpanded;
  }
}
