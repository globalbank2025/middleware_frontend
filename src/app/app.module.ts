import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

// ✅ Import Angular Material Modules
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatButtonModule } from '@angular/material/button';
import { MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatCardModule } from '@angular/material/card';
import { MatSelectModule } from '@angular/material/select';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar'; // ✅ Toastr Alternative
import { MatCheckboxModule } from '@angular/material/checkbox';

// Import Components
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { LoginComponent } from './auth/login/login.component';
import { RegisterComponent } from './auth/register/register.component';
import { BranchManagementComponent } from './components/branch/branch-management.component';
import { ToastrModule } from 'ngx-toastr';
import { LayoutComponent } from './components/layout/layout.component';
import { RoleManagementComponent } from './components/role-management/role-management.component';
import { ServiceIncomeGlManagementComponent } from './components/service-income-gl-management/service-income-gl-management.component';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { VatCollectionComponent } from './components/vat-collection/vat-collection.component';
import { UsersListComponent } from './components/users-list/users-list.component';
import { InvoicePageComponent } from './components/invoice-page/invoice-page.component';
import { VatCollectionListComponent } from './components/vat-collection-list/vat-collection-list.component';
import { ServerTestingComponent } from './components/server-testing/server-testing.component';
import { TransactionLogListComponent } from './components/transaction-log-list/transaction-log-list.component';
import { JsonPayloadDialogComponent } from './components/json-payload-dialog/json-payload-dialog.component';
import { PermissionManagementComponent } from './components/permission-management/permission-management.component';
import { RolePermissionManagementComponent } from './components/role-permission-management/role-permission-management.component';
import { MatChipsModule } from '@angular/material/chips';  // <-- Importing Chips
import { MatIconModule } from '@angular/material/icon';
import { PartnerManagementComponent } from './components/partner-management/partner-management.component';
import { ChangePasswordComponent } from './components/change-password/change-password.component';
import { ServiceManagementComponent } from './components/service-management/service-management.component';
import { ApiCredentialsManagementComponent } from './components/api-credentials-management/api-credentials-management.component';     // <-- Importing Icons
@NgModule({
  declarations: [
    AppComponent,
    DashboardComponent,
    LoginComponent,
    RegisterComponent,
    BranchManagementComponent,
    LayoutComponent,
    RoleManagementComponent,
    ServiceIncomeGlManagementComponent,
    VatCollectionComponent,
    UsersListComponent,
    InvoicePageComponent,
    VatCollectionListComponent,
    ServerTestingComponent,
    TransactionLogListComponent,
    JsonPayloadDialogComponent,
    PermissionManagementComponent,
    RolePermissionManagementComponent,
    PartnerManagementComponent,
    ChangePasswordComponent,
    ServiceManagementComponent,
    ApiCredentialsManagementComponent,
  ],
  imports: [
    BrowserModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    HttpClientModule,
    FormsModule,
    ReactiveFormsModule,
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatButtonModule,
    MatIconModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatCardModule,
    MatSelectModule,
    MatToolbarModule,
    MatSidenavModule,
    MatListModule,
    MatSnackBarModule, // ✅ Use Snackbar for Toastr-like notifications
    MatInputModule,      // Add this to imports
    MatInputModule,      // <--- Important
    MatButtonModule,    // <--- Important
    MatButtonModule ,    // Also ensure you have the ButtonModule for mat-button
    MatChipsModule,  // <-- Add Chips module here
    MatIconModule,   // <-- And the Icon module here
    MatCheckboxModule,  // <-- Key import for checkboxes
    ToastrModule.forRoot(),
  ],
  
  providers: [
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true },
    // other providers...
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
