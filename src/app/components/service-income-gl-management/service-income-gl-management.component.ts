import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ServiceIncomeGl } from '../../models/service-income-gl';
import { AuthService } from '../../auth/auth.service';
import { ToastrService } from 'ngx-toastr';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-service-income-gl-management',
  templateUrl: './service-income-gl-management.component.html',
  styleUrls: ['./service-income-gl-management.component.css']
})
export class ServiceIncomeGlManagementComponent implements OnInit {
  displayedColumns: string[] = [
    'glCode',
    'name',
    'description',
    'status',
    'calculationType',
    'flatPrice',
    'rate',
    'actions'
  ];
  dataSource = new MatTableDataSource<ServiceIncomeGl>([]);
  glForm!: FormGroup;
  isEdit = false;
  editId!: number;
  calcTypeSub!: Subscription;

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  dialogRef!: MatDialogRef<any>;

  constructor(
    private authService: AuthService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchItems();
  }

  fetchItems(): void {
    this.authService.getAllServiceIncomeGl().subscribe({
      next: (items: ServiceIncomeGl[]) => {
        this.dataSource.data = items;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: (error) => {
        const errorMsg = this.extractErrorMessages(error);
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }

  applyFilter(event: any): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openDialog(item?: ServiceIncomeGl): void {
    this.isEdit = !!item;
    this.editId = item ? item.id : 0;

    this.glForm = this.fb.group({
      glCode: [
        item ? item.glCode : '',
        [Validators.required, Validators.minLength(7), Validators.maxLength(7)]
      ],
      name: [item ? item.name : '', Validators.required],
      description: [item ? item.description : ''],
      status: [item ? item.status : 'Open', Validators.required],
      calculationType: [item ? item.calculationType : 'Flat', Validators.required],
      flatPrice: [
        item && item.calculationType === 'Flat' ? item.flatPrice : null,
        [Validators.min(0)]
      ],
      rate: [
        item && item.calculationType === 'Rate' ? item.rate : null,
        [Validators.min(0)]
      ]
    });

    // Subscribe to calculationType changes for conditional validators.
    if (this.calcTypeSub) {
      this.calcTypeSub.unsubscribe();
    }
    this.calcTypeSub = this.glForm.get('calculationType')!.valueChanges.subscribe(val => {
      if (val === 'Flat') {
        this.glForm.get('flatPrice')!.setValidators([Validators.required, Validators.min(0)]);
        this.glForm.get('rate')!.clearValidators();
        this.glForm.get('rate')!.setValue(null);
      } else if (val === 'Rate') {
        this.glForm.get('rate')!.setValidators([Validators.required, Validators.min(0)]);
        this.glForm.get('flatPrice')!.clearValidators();
        this.glForm.get('flatPrice')!.setValue(null);
      }
      this.glForm.get('flatPrice')!.updateValueAndValidity();
      this.glForm.get('rate')!.updateValueAndValidity();
    });

    this.dialogRef = this.dialog.open(this.dialogTpl, {
      width: '400px',
      disableClose: true
    });
  }

  closeDialog(): void {
    if (this.calcTypeSub) {
      this.calcTypeSub.unsubscribe();
    }
    this.dialogRef.close();
  }

  saveDialog(): void {
    if (this.glForm.invalid) return;

    const formData = this.glForm.value;
    const payload: ServiceIncomeGl = {
      id: this.isEdit ? this.editId : 0,
      glCode: formData.glCode,
      name: formData.name,
      description: formData.description,
      status: formData.status,
      calculationType: formData.calculationType,
      flatPrice: formData.flatPrice,
      rate: formData.rate
    };

    if (this.isEdit) {
      this.authService.updateServiceIncomeGl(this.editId, payload).subscribe({
        next: () => {
          this.toastr.success('Item updated successfully', 'Success');
          this.fetchItems();
          this.closeDialog();
        },
        error: (error) => {
          const errorMsg = this.extractErrorMessages(error);
          this.toastr.error(errorMsg, 'Error');
        }
      });
    } else {
      this.authService.createServiceIncomeGl(payload).subscribe({
        next: () => {
          this.toastr.success('Item added successfully', 'Success');
          this.fetchItems();
          this.closeDialog();
        },
        error: (error) => {
          const errorMsg = this.extractErrorMessages(error);
          this.toastr.error(errorMsg, 'Error');
        }
      });
    }
  }

  deleteItem(id: number): void {
    if (!confirm('Are you sure you want to delete this item?')) return;
    this.authService.deleteServiceIncomeGl(id).subscribe({
      next: () => {
        this.toastr.success('Item deleted', 'Success');
        this.fetchItems();
      },
      error: (error) => {
        const errorMsg = this.extractErrorMessages(error);
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }

  // Extracts and formats error messages from the API response.
  private extractErrorMessages(error: any): string {
    if (error.error && error.error.errors) {
      // Combine all error messages into one string.
      const messages = Object.values(error.error.errors)
        .flat()
        .join('\n');
      return messages || error.error.title || 'An error occurred';
    }
    return 'An unexpected error occurred.';
  }
}
