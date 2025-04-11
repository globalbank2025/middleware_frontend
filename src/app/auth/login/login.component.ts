import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService, LoginResponse } from '../auth.service';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  hide = true;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private toastr: ToastrService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required]]
    });
  }

  onSubmit(): void {
    // Prevent submission if invalid
    if (this.loginForm.invalid) return;
  
    const { email, password } = this.loginForm.value;
    this.authService.login(email, password).subscribe({
      next: (res: LoginResponse) => {
        // Handle success
        localStorage.setItem('auth_token', res.token);
        localStorage.setItem('loginResponse', JSON.stringify(res));
        this.toastr.success('Login successful!', 'Success');
        this.router.navigate(['/dashboard']);
      },
      error: (err) => {
        /*
          For a response like:
          HTTP 401
          body: { "error": "User is locked out." }
        */
        if (err.error && err.error.error) {
          // Show the exact message from server
          this.toastr.error(err.error.error, 'Login Failed');
        } else {
          // Fallback message
          this.toastr.error('Invalid email or password.', 'Login Failed');
        }
      }
    });
  }
  
}
