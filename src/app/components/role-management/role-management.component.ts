import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { AuthService, UserDto } from '../../auth/auth.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-role-management',
  templateUrl: './role-management.component.html',
  styleUrls: ['./role-management.component.css']
})
export class RoleManagementComponent implements OnInit {
  displayedColumns: string[] = ['roleName', 'actions'];
  dataSource = new MatTableDataSource<string>([]);

  roleForm!: FormGroup;
  assignForm!: FormGroup;
  removeAssignForm!: FormGroup;

  dialogRef!: MatDialogRef<any>;
  assignDialogRef!: MatDialogRef<any>;
  removeDialogRef!: MatDialogRef<any>;

  usersEmails: string[] = [];
  selectedUserRoles: string[] = [];

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  @ViewChild('assignDialogTpl') assignDialogTpl!: TemplateRef<any>;
  @ViewChild('removeDialogTpl') removeDialogTpl!: TemplateRef<any>;

  constructor(
    private authService: AuthService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchRoles();
  }

  fetchRoles(): void {
    this.authService.getAllRoles().subscribe({
      next: (roles: string[]) => {
        this.dataSource.data = roles;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: () => {
        this.toastr.error('Failed to load roles', 'Error');
      }
    });
  }

  applyFilter(event: any): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  // --------------------------
  // Create New Role
  // --------------------------
  openDialog(): void {
    this.roleForm = this.fb.group({
      roleName: ['', Validators.required]
    });
    this.dialogRef = this.dialog.open(this.dialogTpl, {
      width: '400px',
      disableClose: true
    });
  }

  closeDialog(): void {
    this.dialogRef.close();
  }

  saveDialog(): void {
    if (this.roleForm.invalid) return;
    const { roleName } = this.roleForm.value;
    this.authService.createRole({ roleName }).subscribe({
      next: (res: any) => {
        const message = Array.isArray(res) ? res[0] : res;
        this.toastr.success(message, 'Success');
        this.fetchRoles();
        this.closeDialog();
      },
      error: (err: any) => {
        // Check if error response has an 'error' property and then display it
        if (err.error && err.error.error) {
          this.toastr.error(err.error.error, 'Error');
        } else if (err.error && Array.isArray(err.error)) {
          const combinedErrors = err.error.join(', ');
          this.toastr.error(combinedErrors, 'Error');
        } else if (typeof err.error === 'string') {
          this.toastr.error(err.error, 'Error');
        } else {
          this.toastr.error('Failed to add role', 'Error');
        }
      }
    });
  }

  // --------------------------
  // Assign Role to User
  // --------------------------
  openAssignDialog(): void {
    this.authService.getAllUsers().subscribe({
      next: (users: UserDto[]) => {
        this.usersEmails = users.map(u => u.email);
        this.assignForm = this.fb.group({
          email: ['', Validators.required],
          roleName: ['', Validators.required]
        });
        if (this.dataSource.data.length > 0) {
          this.assignForm.patchValue({ roleName: this.dataSource.data[0] });
        }
        this.assignDialogRef = this.dialog.open(this.assignDialogTpl, {
          width: '400px',
          disableClose: true
        });
      },
      error: () => {
        this.toastr.error('Failed to load users', 'Error');
      }
    });
  }

  closeAssignDialog(): void {
    this.assignDialogRef.close();
  }

  saveAssignDialog(): void {
    if (this.assignForm.invalid) return;
    const { email, roleName } = this.assignForm.value;
    this.authService.assignRole({ email, roleName }).subscribe({
      next: (res: any) => {
        const message = Array.isArray(res) ? res[0] : res;
        this.toastr.success(message, 'Success');
        this.closeAssignDialog();
      },
      error: (err: any) => {
        if (err.error && err.error.error) {
          this.toastr.error(err.error.error, 'Error');
        } else if (err.error && Array.isArray(err.error)) {
          const combinedErrors = err.error.join(', ');
          this.toastr.error(combinedErrors, 'Error');
        } else if (typeof err.error === 'string') {
          this.toastr.error(err.error, 'Error');
        } else {
          this.toastr.error('Failed to assign role', 'Error');
        }
      }
    });
  }

  // --------------------------
  // Remove Role from User
  // --------------------------
  openRemoveRoleDialog(): void {
    this.authService.getAllUsers().subscribe({
      next: (users: UserDto[]) => {
        this.usersEmails = users.map(u => u.email);
        this.removeAssignForm = this.fb.group({
          email: ['', Validators.required],
          roleName: ['', Validators.required]
        });
        this.removeDialogRef = this.dialog.open(this.removeDialogTpl, {
          width: '400px',
          disableClose: true
        });
      },
      error: () => {
        this.toastr.error('Failed to load users', 'Error');
      }
    });
  }

  closeRemoveDialog(): void {
    this.removeDialogRef.close();
  }

  onUserEmailChange(): void {
    const email = this.removeAssignForm.get('email')?.value;
    if (email) {
      this.authService.getUserRoles(email).subscribe({
        next: (roles: string[]) => {
          this.selectedUserRoles = roles;
          if (roles.length > 0) {
            this.removeAssignForm.patchValue({ roleName: roles[0] });
          }
        },
        error: () => {
          this.toastr.error('Failed to load user roles', 'Error');
        }
      });
    }
  }

  saveRemoveDialog(): void {
    if (this.removeAssignForm.invalid) return;
    const { email, roleName } = this.removeAssignForm.value;
    this.authService.removeRole({ email, roleName }).subscribe({
      next: (res: any) => {
        const message = Array.isArray(res) ? res[0] : res;
        this.toastr.success(message, 'Success');
        this.closeRemoveDialog();
      },
      error: (err: any) => {
        if (err.error && err.error.error) {
          this.toastr.error(err.error.error, 'Error');
        } else if (err.error && Array.isArray(err.error)) {
          const combinedErrors = err.error.join(', ');
          this.toastr.error(combinedErrors, 'Error');
        } else if (typeof err.error === 'string') {
          this.toastr.error(err.error, 'Error');
        } else {
          this.toastr.error('Failed to remove role', 'Error');
        }
      }
    });
  }
}
