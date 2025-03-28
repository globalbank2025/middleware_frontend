import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ToastrService } from 'ngx-toastr';

import { ApiCredentials } from 'src/app/models/api-credentials.model';
import { ApiCredentialsService } from 'src/app/services/api-credentials.service';

// Services for populating dropdowns
import { Partner } from 'src/app/models/partner.model';
import { PartnerService } from 'src/app/services/partner.service';
import { Service } from 'src/app/models/service.model';
import { ServiceService } from 'src/app/services/service.service';

@Component({
  selector: 'app-api-credentials-management',
  templateUrl: './api-credentials-management.component.html',
  styleUrls: ['./api-credentials-management.component.css']
})
export class ApiCredentialsManagementComponent implements OnInit {
  displayedColumns: string[] = [
    'partnerName', // Display partner name instead of ID
    'serviceName', // Display service name instead of ID
    'apiKey',
    'apiSecret',
    'status',
    'actions'
  ];
  dataSource = new MatTableDataSource<ApiCredentials>([]);
  credentialsForm!: FormGroup;
  isEdit = false;
  editId!: number;

  // Dropdown arrays for partner and service lookups
  partners: Partner[] = [];
  services: Service[] = [];

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  dialogRef!: MatDialogRef<any>;

  constructor(
    private apiCredentialsService: ApiCredentialsService,
    private partnerService: PartnerService,
    private serviceService: ServiceService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchApiCredentials();
    this.fetchPartners();
    this.fetchServices();
  }

  fetchApiCredentials(): void {
    this.apiCredentialsService.getAllApiCredentials().subscribe({
      next: (creds) => {
        this.dataSource.data = creds;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: (err) => {
        const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to load API Credentials';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }

  fetchPartners(): void {
    this.partnerService.getAllPartners().subscribe({
      next: (partners) => {
        this.partners = partners;
      },
      error: (err) => {
        const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to load partners';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }

  fetchServices(): void {
    this.serviceService.getAllServices().subscribe({
      next: (services) => {
        this.services = services;
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

  // Helper to display partner name instead of ID
  getPartnerName(cred: ApiCredentials): string {
    const partner = this.partners.find(p => p.partnerId === cred.partnerId);
    return partner ? partner.partnerName : cred.partnerId.toString();
  }

  // Helper to display service name instead of ID
  getServiceName(cred: ApiCredentials): string {
    const service = this.services.find(s => s.serviceId === cred.serviceId);
    return service ? service.serviceName : cred.serviceId.toString();
  }

  openDialog(apiCred?: ApiCredentials): void {
    this.isEdit = !!apiCred;
    this.editId = apiCred ? apiCred.apiCredId! : 0;

    this.credentialsForm = this.fb.group({
      // If editing, populate existing fields; otherwise default
      apiCredId:   [apiCred ? apiCred.apiCredId : null],
      partnerId:   [apiCred ? apiCred.partnerId   : '', Validators.required],
      serviceId:   [apiCred ? apiCred.serviceId   : '', Validators.required],
      apiKey:      [apiCred ? apiCred.apiKey      : ''],
      apiSecret:   [apiCred ? apiCred.apiSecret   : ''],
      username:    [apiCred ? apiCred.username    : ''],
      password:    [apiCred ? apiCred.password    : ''],
      allowedIp:   [apiCred ? apiCred.allowedIp   : ''],
      status:      [apiCred ? apiCred.status      : 'ACTIVE', Validators.required]
    });

    this.dialogRef = this.dialog.open(this.dialogTpl, {
      width: '600px',
      disableClose: true
    });
  }

  closeDialog(): void {
    this.dialogRef.close();
  }

  saveDialog(): void {
    if (this.credentialsForm.invalid) return;

    // Copy form data to avoid mutating credentialsForm directly
    const formData = { ...this.credentialsForm.value } as ApiCredentials;

    if (this.isEdit) {
      // ------------------------------
      // UPDATE (PUT)
      // ------------------------------
      this.apiCredentialsService.updateApiCredentials(this.editId, formData).subscribe({
        next: (res: any) => {
          const message = res.message || 'API Credentials updated successfully';
          this.toastr.success(message, 'Success');
          this.fetchApiCredentials();
          this.closeDialog();
        },
        error: (err) => {
          const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to update API Credentials';
          this.toastr.error(errorMsg, 'Error');
        }
      });
    } else {
      // ------------------------------
      // CREATE (POST)
      // ------------------------------
      // Remove apiCredId so we don't send it to the server
      delete formData.apiCredId;

      this.apiCredentialsService.createApiCredentials(formData).subscribe({
        next: (res: any) => {
          const message = res.message || 'API Credentials created successfully';
          this.toastr.success(message, 'Success');
          this.fetchApiCredentials();
          this.closeDialog();
        },
        error: (err) => {
          const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to create API Credentials';
          this.toastr.error(errorMsg, 'Error');
        }
      });
    }
  }

  deleteApiCredentials(id: number): void {
    if (!confirm('Are you sure you want to delete these credentials?')) return;

    this.apiCredentialsService.deleteApiCredentials(id).subscribe({
      next: (res: any) => {
        const message = res.message || 'API Credentials deleted successfully';
        this.toastr.success(message, 'Success');
        this.fetchApiCredentials();
      },
      error: (err) => {
        const errorMsg = err.error && err.error.message ? err.error.message : 'Failed to delete API Credentials';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }
}
