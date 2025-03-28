import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ToastrService } from 'ngx-toastr';

import { Partner } from 'src/app/models/partner.model';
import { PartnerService } from 'src/app/services/partner.service';

@Component({
  selector: 'app-partner-management',
  templateUrl: './partner-management.component.html',
  styleUrls: ['./partner-management.component.css']
})
export class PartnerManagementComponent implements OnInit {
  displayedColumns: string[] = [
    'partnerCode',
    'partnerName',
    'contactPerson',
    'contactEmail',
    'contactPhone',
    'status',
    'actions'
  ];
  dataSource = new MatTableDataSource<Partner>([]);
  partnerForm!: FormGroup;
  isEdit = false;
  editPartnerId!: number;

  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild('dialogTpl') dialogTpl!: TemplateRef<any>;
  dialogRef!: MatDialogRef<any>;

  constructor(
    private partnerService: PartnerService,
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.fetchPartners();
  }

  fetchPartners(): void {
    this.partnerService.getAllPartners().subscribe({
      next: (partners) => {
        this.dataSource.data = partners;
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;
      },
      error: () => {
        this.toastr.error('Failed to load partners', 'Error');
      }
    });
  }

  applyFilter(event: any): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  openDialog(partner?: Partner): void {
    // If partner is provided, we are editing; otherwise, creating a new partner
    this.isEdit = !!partner;
    this.editPartnerId = partner ? partner.partnerId! : 0;

    // Build the form
    this.partnerForm = this.fb.group({
      // If editing, keep partnerId in a hidden field; if new, use empty string
      partnerId: [partner ? partner.partnerId : ''],
      partnerCode: [partner ? partner.partnerCode : '', Validators.required],
      partnerName: [partner ? partner.partnerName : '', Validators.required],
      contactPerson: [partner ? partner.contactPerson : '', Validators.required],
      contactEmail: [partner ? partner.contactEmail : '', [Validators.required, Validators.email]],
      contactPhone: [partner ? partner.contactPhone : '', Validators.required],
      status: [partner ? partner.status : 'ACTIVE', Validators.required]
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
    if (this.partnerForm.invalid) return;

    // Copy form values to avoid mutating this.partnerForm directly
    const formData = { ...this.partnerForm.value } as Partner;

    if (this.isEdit) {
      // --------------------------------------
      // UPDATE (PUT) -> we do pass partnerId
      // --------------------------------------
      this.partnerService.updatePartner(this.editPartnerId, formData).subscribe({
        next: () => {
          this.toastr.success('Partner updated successfully', 'Success');
          this.fetchPartners();
          this.closeDialog();
        },
        error: () => {
          this.toastr.error('Failed to update partner', 'Error');
        }
      });
    } else {
      // --------------------------------------
      // CREATE (POST) -> remove partnerId
      // --------------------------------------
      // The backend now expects CreatePartnerDto (no PartnerId).
      delete formData.partnerId;

      this.partnerService.createPartner(formData).subscribe({
        next: () => {
          this.toastr.success('Partner created successfully', 'Success');
          this.fetchPartners();
          this.closeDialog();
        },
        error: () => {
          this.toastr.error('Failed to create partner', 'Error');
        }
      });
    }
  }

  deletePartner(partnerId: number): void {
    if (!confirm('Are you sure you want to delete this partner?')) return;

    this.partnerService.deletePartner(partnerId).subscribe({
      next: () => {
        this.toastr.success('Partner deleted successfully', 'Success');
        this.fetchPartners();
      },
      error: () => {
        this.toastr.error('Failed to delete partner', 'Error');
      }
    });
  }
}
