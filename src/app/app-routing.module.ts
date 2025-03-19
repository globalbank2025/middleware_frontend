import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LayoutComponent } from './components/layout/layout.component';
import { DashboardComponent } from './components/dashboard/dashboard.component';
import { LoginComponent } from './auth/login/login.component';
import { BranchManagementComponent } from './components/branch/branch-management.component';
import { RegisterComponent } from './auth/register/register.component';
import { RoleManagementComponent } from './components/role-management/role-management.component';
import { ServiceIncomeGlManagementComponent } from './components/service-income-gl-management/service-income-gl-management.component';
import { VatCollectionComponent } from './components/vat-collection/vat-collection.component';
import { AuthGuard } from './guards/AuthGuard';
import { UsersListComponent } from './components/users-list/users-list.component';
import { InvoicePageComponent } from './components/invoice-page/invoice-page.component';
import { VatCollectionListComponent } from './components/vat-collection-list/vat-collection-list.component';
import { ServerTestingComponent } from './components/server-testing/server-testing.component';
import { TransactionLogListComponent } from './components/transaction-log-list/transaction-log-list.component';
import { PermissionManagementComponent } from './components/permission-management/permission-management.component';
import { RolePermissionManagementComponent } from './components/role-permission-management/role-permission-management.component';

const routes: Routes = [
  // If someone hits '/', redirect to '/dashboard'
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },

  // Login route (no layout) remains public
  { path: 'login', component: LoginComponent },

  // All routes that require authentication use the LayoutComponent shell
  {
    path: '',
    component: LayoutComponent,
    canActivate: [AuthGuard], // Protect all child routes
    children: [
      { path: 'dashboard', component: DashboardComponent },
      { path: 'register', component: RegisterComponent },
      { path: 'branch-management', component: BranchManagementComponent },
      { path: 'role-management', component: RoleManagementComponent },
      { path: 'service-income-gl-management', component: ServiceIncomeGlManagementComponent },
      { path: 'vat-collection', component: VatCollectionComponent },
      { path: 'users-list', component: UsersListComponent },
      { path: 'invoice', component: InvoicePageComponent },
      { path: 'vat-collection-list', component: VatCollectionListComponent },
      { path: 'test-servers', component: ServerTestingComponent },
      { path: 'vat-list/:status', component: VatCollectionListComponent },
      { path: 'transaction-logs', component: TransactionLogListComponent },
      { path: 'permission-management', component: PermissionManagementComponent },
      { path: 'role-permission', component: RolePermissionManagementComponent },



    ]
  },

  // 404 handler (optional)
  { path: '**', redirectTo: 'dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
