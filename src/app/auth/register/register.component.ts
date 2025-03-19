import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService, RegisterUser } from '../auth.service';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';
import { Branch } from '../../models/branchs';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  registerForm!: FormGroup;
  hide = true;

  branches: Branch[] = [];
  roles: string[] = [];

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private toastr: ToastrService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.registerForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]],
      branchId: ['', [Validators.required]],
      role: ['', [Validators.required]]
    });

    // Fetch branches from backend
    this.authService.getBranches().subscribe({
      next: (data: Branch[]) => {
        this.branches = data;
      },
      error: () => {
        this.toastr.error('Failed to load branches', 'Error');
      }
    });

    // Fetch roles from backend
    this.authService.getRoles().subscribe({
      next: (data: string[]) => {
        this.roles = data;
      },
      error: () => {
        this.toastr.error('Failed to load roles', 'Error');
      }
    });
  }

  onSubmit(): void {
    if (this.registerForm.invalid) {
      return;
    }

    const user: RegisterUser = this.registerForm.value;
    this.authService.register(user).subscribe({
      next: (res: any) => {
        // Determine success message: if the response is an object, use its 'message' property if available.
        let successMsg = '';
        if (typeof res === 'object') {
          successMsg = res.message ? res.message : JSON.stringify(res);
        } else {
          successMsg = res;
        }
        this.toastr.success(successMsg, 'Success');

        // Reset the form completely
        this.registerForm.reset();
        this.registerForm.markAsPristine();
        this.registerForm.markAsUntouched();

        // Delay navigation so that the success toast is visible
        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 1500);
      },
      error: (err: any) => {
        if (err.error && Array.isArray(err.error.errors)) {
          const combinedErrors = err.error.errors.join(', ');
          this.toastr.error(combinedErrors, 'Error');
        } else if (err.error && typeof err.error === 'string') {
          this.toastr.error(err.error, 'Error');
        } else {
          this.toastr.success('Registerd Successfully. Registered.', 'Success');
        }
      }
    });
  }
}
