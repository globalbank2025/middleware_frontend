import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ToastrService } from 'ngx-toastr';

import { Service } from 'src/app/models/service.model';
import { ServiceService } from 'src/app/services/service.service';

@Component({
  selector: 'app-service-management',
  templateUrl: './service-management.component.html',
  styleUrls: ['./service-management.component.css']
})
export class ServiceManagementComponent implements OnInit {
  displayedColumns: string[] = [
    'serviceCode',
    'serviceName',
    'serviceType',
    'offsetAccNo',
    'status',
    'actions'
  ];
  dataSource = new MatTableDataSource<Service>([]);
  serviceForm!: FormGroup;
  isEdit = false;
  editServiceId!: number;

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  dialogRef!: MatDialogRef<any>;

  constructor(
    private serviceService: ServiceService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchServices();
  }

  fetchServices(): void {
    this.serviceService.getAllServices().subscribe({
      next: (services) => {
        this.dataSource.data = services;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: (err) => {
        const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to load services';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }

  applyFilter(event: any): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openDialog(service?: Service): void {
    this.isEdit = !!service;
    this.editServiceId = service ? service.serviceId! : 0;

    // Include hidden control for serviceId in the form group.
    this.serviceForm = this.fb.group({
      serviceId: [service ? service.serviceId : null], // hidden field
      serviceCode: [service ? service.serviceCode : '', Validators.required],
      serviceName: [service ? service.serviceName : '', Validators.required],
      description: [service ? service.description : '', Validators.required],
      serviceType: [service ? service.serviceType : 'Credit', Validators.required],
      offsetAccNo: [service ? service.offsetAccNo : '', Validators.required],
      status: [service ? service.status : 'ACTIVE', Validators.required]
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
    if (this.serviceForm.invalid) return;
    const formData = this.serviceForm.value as Service;

    if (this.isEdit) {
      this.serviceService.updateService(this.editServiceId, formData).subscribe({
        next: () => {
          this.toastr.success('Service updated successfully', 'Success');
          this.fetchServices();
          this.closeDialog();
        },
        error: (err) => {
          const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to update service';
          this.toastr.error(errorMsg, 'Error');
        }
      });
    } else {
      this.serviceService.createService(formData).subscribe({
        next: () => {
          this.toastr.success('Service created successfully', 'Success');
          this.fetchServices();
          this.closeDialog();
        },
        error: (err) => {
          const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to create service';
          this.toastr.error(errorMsg, 'Error');
        }
      });
    }
  }

  deleteService(serviceId: number): void {
    if (!confirm('Are you sure you want to delete this service?')) return;
    this.serviceService.deleteService(serviceId).subscribe({
      next: () => {
        this.toastr.success('Service deleted successfully', 'Success');
        this.fetchServices();
      },
      error: (err) => {
        const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to delete service';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }
}
