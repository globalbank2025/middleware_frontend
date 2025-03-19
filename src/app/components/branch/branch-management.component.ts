import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { Branch } from '../../models/branchs';
import { AuthService } from '../../auth/auth.service'; // Adjust to your actual service
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-branch-management',
  templateUrl: './branch-management.component.html',
  styleUrls: ['./branch-management.component.css']
})
export class BranchManagementComponent implements OnInit {
  displayedColumns: string[] = ['branchCode', 'branchName', 'location', 'actions'];
  dataSource = new MatTableDataSource<Branch>([]);
  branchForm!: FormGroup;
  isEdit = false;
  editBranchId!: number;

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;

  // We reference the dialog template from the HTML
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  dialogRef!: MatDialogRef<any>;

  constructor(
    private authService: AuthService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchBranches();
  }

  fetchBranches() {
    // Example: Adjust to your actual backend
    // e.g., this.authService.getAllBranches()
    this.authService.getAllBranches().subscribe({
      next: (branches: Branch[]) => {
        this.dataSource.data = branches;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: () => {
        this.toastr.error('Failed to load branches', 'Error');
      }
    });
  }

  applyFilter(event: any) {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openDialog(branch?: Branch) {
    this.isEdit = !!branch;
    this.editBranchId = branch ? branch.branchId : 0;

    // Initialize form with either existing data (edit) or blank (add)
    this.branchForm = this.fb.group({
      branchCode: [branch ? branch.branchCode : '', Validators.required],
      branchName: [branch ? branch.branchName : '', Validators.required],
      location: [branch ? branch.location : '']
    });

    this.dialogRef = this.dialog.open(this.dialogTpl, {
      width: '400px',
      disableClose: true,
      data: {}
    });
  }

  closeDialog() {
    this.dialogRef.close();
  }

  saveDialog() {
    if (this.branchForm.invalid) return;

    const formData = this.branchForm.value;

    if (this.isEdit) {
      // Update existing branch
      const updatePayload = {
        branchId: this.editBranchId, // Ensure branchId is present
        branchCode: formData.branchCode,
        branchName: formData.branchName,
        location: formData.location
      };
      this.authService.updateBranch(this.editBranchId, updatePayload).subscribe({
        next: () => {
          this.toastr.success('Branch updated successfully', 'Success');
          this.fetchBranches();
          this.closeDialog();
        },
        error: () => {
          this.toastr.error('Failed to update branch', 'Error');
        }
      });
    } else {
      // Add new branch
      this.authService.createBranch(formData).subscribe({
        next: () => {
          this.toastr.success('Branch added successfully', 'Success');
          this.fetchBranches();
          this.closeDialog();
        },
        error: (err) => {
          // Attempt to extract a detailed error message from the backend response.
          let errorMessage = 'Failed to save transaction.';
          if (err && err.error) {
            if (typeof err.error === 'string') {
              errorMessage = err.error;
            } else if (err.error.error) {
              errorMessage = err.error.error;
            } else if (err.error.message) {
              errorMessage = err.error.message;
            }
          }
          this.toastr.error(errorMessage, 'Error');
          console.error('Error saving transaction:', err);
        }
      });
    }
  }

  deleteBranch(branchId: number) {
    if (!confirm('Are you sure you want to delete this branch?')) return;
    this.authService.deleteBranch(branchId).subscribe({
      next: () => {
        this.toastr.success('Branch deleted', 'Success');
        this.fetchBranches();
      },
      error: () => {
        this.toastr.error('Failed to delete branch', 'Error');
      }
    });
  }
}
