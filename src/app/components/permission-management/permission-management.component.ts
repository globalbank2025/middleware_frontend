import { Component, OnInit, ViewChild } from '@angular/core';
import { FormBuilder, FormGroup, Validators, FormArray, FormControl } from '@angular/forms';
import { MatTableDataSource } from '@angular/material/table';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { ToastrService } from 'ngx-toastr';
import { forkJoin } from 'rxjs';

import {
  AuthService,
  RoleInfo,
  PermissionShort,
  PermissionDto
} from '../../auth/auth.service';

@Component({
  selector: 'app-permission-management',
  templateUrl: './permission-management.component.html',
  styleUrls: ['./permission-management.component.css']
})
export class PermissionManagementComponent implements OnInit {
  dataSource = new MatTableDataSource<PermissionDto>([]);
// 1) Ensure 'actions' is in your displayedColumns array:
displayedColumns: string[] = ['name', 'description', 'actions'];
  // The main form group that includes 'roleId' + 'permissions'
  rolePermissionForm!: FormGroup | null;

  // An array of roles (with ID + name) from the server
  roles: RoleInfo[] = [];
  selectedRoleId = '';

  // Material table references
  @ViewChild(MatSort) sort!: MatSort;
  @ViewChild(MatPaginator) paginator!: MatPaginator;

  // For creating a new permission
  createPermissionForm!: FormGroup;
  showCreatePermissionDialog = false;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private toastr: ToastrService
  ) {}

  ngOnInit(): void {
    this.loadRolesAndPermissions();
  }

  /**
   * A typed getter for the array of checkbox controls.
   * We guard with "?" because rolePermissionForm might be null initially.
   */
  get permissionsArray(): FormArray | null {
    return this.rolePermissionForm
      ? (this.rolePermissionForm.get('permissions') as FormArray)
      : null;
  }

  /**
   * Loads roles (with ID) and all permissions, then builds the form group.
   */
  loadRolesAndPermissions(): void {
    forkJoin([
      this.authService.getAllRolesWithId(),   // => RoleInfo[]
      this.authService.getAllPermissions()    // => PermissionDto[]
    ]).subscribe({
      next: ([roleList, perms]) => {
        this.roles = roleList || [];

        // Put the perms in the right-side table
        this.dataSource.data = perms || [];
        this.dataSource.sort = this.sort;
        this.dataSource.paginator = this.paginator;

        // Build the main form
        this.rolePermissionForm = this.fb.group({
          roleId: [
            this.roles.length > 0 ? this.roles[0].id : '',
            Validators.required
          ],
          // For each permission, create a FormControl(false)
          permissions: this.fb.array(
            (perms || []).map(() => new FormControl(false))
          )
        });

        // If we have at least one role, load that role's assigned perms
        if (this.roles.length > 0) {
          this.selectedRoleId = this.roles[0].id;
          this.onRoleChange();
        }
      },
      error: () => {
        this.toastr.error('Failed to load roles or permissions', 'Error');
      }
    });
  }

  /**
   * Called when the user picks a different role from the dropdown.
   *  1) Clear all checkboxes
   *  2) Fetch assigned perms for that role, check the relevant boxes
   */
  onRoleChange(): void {
    if (!this.rolePermissionForm) return;

    this.selectedRoleId = this.rolePermissionForm.get('roleId')!.value;
    if (!this.selectedRoleId) return;

    // 1) Clear all checkboxes
    const permArray = this.permissionsArray;
    if (!permArray) return;

    permArray.controls.forEach(ctrl => ctrl.setValue(false));

    // 2) Get assigned perms for the new role
    this.authService.getRolePermissionsById(this.selectedRoleId).subscribe({
      next: (assignedShorts: PermissionShort[]) => {
        const assignedIds = assignedShorts.map(a => a.id);
        const allPerms = this.dataSource.data;

        // Mark boxes as checked if the perm's ID is in assignedIds
        permArray.controls.forEach((ctrl, i) => {
          // safety check if i is within array bounds
          if (i < allPerms.length) {
            const p = allPerms[i];
            if (assignedIds.includes(p.id)) {
              ctrl.setValue(true);
            }
          }
        });
      },
      error: () => {
        this.toastr.error('Failed to fetch assigned permissions', 'Error');
      }
    });
  }

  /**
   * Saves changes: If a box is newly checked => assign, newly unchecked => remove
   */
  savePermissionChanges(): void {
    if (!this.rolePermissionForm || this.rolePermissionForm.invalid) {
      this.toastr.error('No valid role selected', 'Error');
      return;
    }

    const roleId = this.rolePermissionForm.get('roleId')!.value;
    const roleObj = this.roles.find(r => r.id === roleId);
    if (!roleObj) {
      this.toastr.error('Selected role not found', 'Error');
      return;
    }
    const roleName = roleObj.name;

    // Get DB's current assignment
    this.authService.getRolePermissionsById(roleId).subscribe({
      next: (assignedShorts) => {
        const assignedIds = assignedShorts.map(a => a.id);
        const allPerms = this.dataSource.data;
        const permArray = this.permissionsArray;
        if (!permArray) return;

        const checks = permArray.controls.map(ctrl => ctrl.value);
        const requests: Promise<any>[] = [];

        checks.forEach((val, i) => {
          if (i < allPerms.length) {
            const p = allPerms[i];
            const isAssigned = assignedIds.includes(p.id);

            // If newly checked, but was not assigned => assign
            if (val && !isAssigned) {
              requests.push(
                this.authService.assignPermissionToRole({
                  roleName,
                  permissionName: p.name
                }).toPromise()
              );
            }
            // If unchecked, but was assigned => remove
            else if (!val && isAssigned) {
              requests.push(
                this.authService.removePermissionFromRole({
                  roleName,
                  permissionName: p.name
                }).toPromise()
              );
            }
          }
        });

        if (requests.length === 0) {
          this.toastr.info('No changes to save', 'Info');
          return;
        }

        // run them
        Promise.all(requests)
          .then(() => {
            this.toastr.success('Permissions updated successfully', 'Success');
            // Refresh the checkboxes after saving
            this.onRoleChange();
          })
          .catch(() => {
            this.toastr.error('Some permission updates failed', 'Error');
          });
      },
      error: () => {
        this.toastr.error('Failed to retrieve assigned perms', 'Error');
      }
    });
  }

  /**
   * Filter the table of all perms by name/description
   */
  applyFilter(event: any): void {
    const val = (event.target as HTMLInputElement).value;
    this.dataSource.filter = val.trim().toLowerCase();
  }

  // -----------------------------
  // CREATE PERMISSION
  // -----------------------------
  openCreatePermissionDialog(): void {
    this.createPermissionForm = this.fb.group({
      permissionName: ['', Validators.required],
      description: ['']
    });
    this.showCreatePermissionDialog = true;
  }

  closeCreatePermissionDialog(): void {
    this.showCreatePermissionDialog = false;
  }

  saveCreatePermission(): void {
    if (this.createPermissionForm.invalid) return;

    const { permissionName, description } = this.createPermissionForm.value;
    this.authService.createPermission({ permissionName, description })
      .subscribe({
        next: (res: any) => {
          const msg = Array.isArray(res) ? res[0] : res;
          this.toastr.success(msg, 'Success');
          this.showCreatePermissionDialog = false;
          // reload everything
          this.loadRolesAndPermissions();
        },
        error: (err) => {
          if (err.error && Array.isArray(err.error)) {
            const combined = err.error.join(', ');
            this.toastr.error(combined, 'Error');
          } else if (typeof err.error === 'string') {
            this.toastr.error(err.error, 'Error');
          } else {
            this.toastr.error('Failed to create permission', 'Error');
          }
        }
      });
  }

  
  deletePermission(permission: any): void {
    if (!confirm(`Are you sure you want to delete the permission "${permission.name}"?`)) {
      return;
    }
  
    this.authService.deletePermission(permission.id).subscribe({
      next: (res: any) => {
        // The backend returns an array, e.g. ["Permission deleted successfully."]
        const msg = Array.isArray(res) && res.length
          ? res[0]
          : 'Permission deleted successfully.';
  
        // Show success message in Toastr
        this.toastr.success(msg, 'Success');
  
        // OPTIONAL: Wait ~1 second so the toast is visible, then reload.
        // If you want an immediate reload, remove the setTimeout wrapper.
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      },
      error: (err) => {
        // On error, e.g. ["Permission is assigned to a role..."]
        const errorMsg = (err.error && Array.isArray(err.error) && err.error.length)
          ? err.error[0]
          : 'Failed to delete permission';
        this.toastr.error(errorMsg, 'Error');
      }
    });
  }
  
  
}
