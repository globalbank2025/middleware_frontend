import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { UserService, UserWithRoles } from '../../services/user.service';
import { ToastrService } from 'ngx-toastr';
import { Router } from '@angular/router';

@Component({
  selector: 'app-change-password',
  templateUrl: './change-password.component.html',
  styleUrls: ['./change-password.component.css']
})
export class ChangePasswordComponent implements OnInit {
  changePasswordForm!: FormGroup;
  hideCurrent = true;
  hideNew = true;
  hideConfirm = true;

  constructor(
    private fb: FormBuilder,
    private authService: UserService,
    private toastr: ToastrService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.changePasswordForm = this.fb.group({
      currentPassword: ['', Validators.required],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmNewPassword: ['', Validators.required]
    }, { validators: this.passwordsMatch });
  }

  // Custom validator to ensure newPassword and confirmNewPassword match.
  passwordsMatch(group: FormGroup) {
    const newPassword = group.get('newPassword')?.value;
    const confirmNewPassword = group.get('confirmNewPassword')?.value;
    return newPassword === confirmNewPassword ? null : { notMatching: true };
  }

  onSubmit(): void {
    if (this.changePasswordForm.invalid) {
      return;
    }
    const { currentPassword, newPassword, confirmNewPassword } = this.changePasswordForm.value;
    this.authService.changePassword({ currentPassword, newPassword, confirmNewPassword })
      .subscribe({
        next: (res: any) => {
          if (res.success) {
            this.toastr.success(res.message, 'Success');
            // Redirect or reset the form as needed.
            this.router.navigate(['/dashboard']);
          } else {
            this.toastr.error(res.message, 'Error');
          }
        },
        error: (err: any) => {
          const errorMessage = err.error?.message || 'Failed to change password.';
          this.toastr.error(errorMessage, 'Error');
        }
      });
  }
}
