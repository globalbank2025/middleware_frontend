import { Component, OnInit, ViewChild } from '@angular/core';
import { UserService, UserWithRoles } from '../../services/user.service';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-users-list',
  templateUrl: './users-list.component.html',
  styleUrls: ['./users-list.component.css']
})
export class UsersListComponent implements OnInit {
  // Removed 'id' and added 'actions'
  displayedColumns: string[] = ['userName', 'email', 'branchName', 'roles', 'lockStatus', 'actions'];
  //displayedColumns: string[] = ['userName', 'email', 'branchName', 'roles', 'actions'];
  dataSource = new MatTableDataSource<UserWithRoles>();

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(private userService: UserService, private toastr: ToastrService) { }

  ngOnInit(): void {
    this.userService.getUsersWithRoles().subscribe({
      next: (users: UserWithRoles[]) => {
        this.dataSource.data = users;
        this.dataSource.paginator = this.paginator;
        this.dataSource.sort = this.sort;
      },
      error: err => {
        console.error('Error fetching users', err);
      }
    });
  }

  applyFilter(event: Event) {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }
  
  onResetPassword(user: UserWithRoles): void {
    if (confirm(`Reset password for ${user.userName}?`)) {
      this.userService.resetUserPassword(user.id).subscribe({
        next: res => {
          this.toastr.success('Password reset to default ("Gbe@1234").', 'Success');
        },
        error: err => {
          console.error('Error resetting password', err);
          this.toastr.error('Failed to reset password.', 'Error');
        }
      });
    }
  }

  onLockUser(user: UserWithRoles): void {
    if (confirm(`Lock the account for ${user.userName}?`)) {
      this.userService.lockUserAccount(user.id).subscribe({
        next: (res) => {
          if (res && res.success) {
            this.toastr.success(res.message, 'Success');
            // Immediately reflect lock status in the UI:
            user.isLockedOut = true;
          } else {
            this.toastr.error('Failed to lock account.', 'Error');
          }
        },
        error: (err) => {
          if (err.error && err.error.errors) {
            const errorMessages = Array.isArray(err.error.errors)
              ? err.error.errors.join(', ')
              : err.error.errors;
            this.toastr.error(errorMessages, 'Error');
          } else if (err.error && err.error.message) {
            this.toastr.error(err.error.message, 'Error');
          } else {
            this.toastr.error('Failed to lock account.', 'Error');
          }
        },
      });
    }
  }
  

  onUnlockUser(user: UserWithRoles): void {
    if (confirm(`Unlock the account for ${user.userName}?`)) {
      this.userService.unlockUserAccount(user.id).subscribe({
        next: (res) => {
          if (res && res.success) {
            this.toastr.success(res.message, 'Success');
            // Update the local UI
            user.isLockedOut = false;
          } else {
            this.toastr.error('Failed to unlock account.', 'Error');
          }
        },
        error: (err) => {
          if (err.error && err.error.errors) {
            const errorMessages = Array.isArray(err.error.errors)
              ? err.error.errors.join(', ')
              : err.error.errors;
            this.toastr.error(errorMessages, 'Error');
          } else if (err.error && err.error.message) {
            this.toastr.error(err.error.message, 'Error');
          } else {
            this.toastr.error('Failed to unlock account.', 'Error');
          }
        },
      });
    }
  }
  
  
  
}
