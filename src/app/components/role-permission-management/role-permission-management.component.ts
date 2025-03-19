import { Component, OnInit, ViewChild, TemplateRef } from '@angular/core';
import { FormBuilder, FormGroup, Validators, FormArray, FormControl } from '@angular/forms';
import { MatDialog, MatDialogRef } from '@angular/material/dialog';
import { ToastrService } from 'ngx-toastr';
import { forkJoin } from 'rxjs';
import { AuthService, PermissionDto, RoleInfo, PermissionShort } from '../../auth/auth.service';

@Component({
  selector: 'app-role-permission-management',
  templateUrl: './role-permission-management.component.html',
  styleUrls: ['./role-permission-management.component.css']
})
export class RolePermissionManagementComponent implements OnInit {
  // The main form for assigning permissions
  assignForm!: FormGroup;
  assignDialogRef!: MatDialogRef<any>;

  // We still store "roles" as string[] because your UI wants role names.
  roles: string[] = [];
  // But we also store the roles with IDs, so we can call getRolePermissionsById.
  private allRoleInfo: RoleInfo[] = [];

  // All permissions from the server
  allPermissions: PermissionDto[] = [];

  // Local store of assigned permissions per role
  // e.g. { role: "Maker", permissions: ["VatCollection_Create"] }
  rolePermissions: { role: string; permissions: string[] }[] = [];

  // TemplateRef for the assign dialog
  @ViewChild('assignDialogTpl') assignDialogTpl!: TemplateRef<any>;

  constructor(
    private fb: FormBuilder,
    private dialog: MatDialog,
    private toastr: ToastrService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    this.loadRolesAndPermissions();
  }

  /**
   * Returns the FormArray of boolean controls for each permission.
   */
  get permissionsArray(): FormArray {
    return this.assignForm?.get('permissions') as FormArray;
  }

  /**
   * Loads:
   * 1) All roles with IDs
   * 2) All permissions
   * Then builds the form, and calls loadRolePermissions to find out what's assigned.
   */
  loadRolesAndPermissions(): void {
    // We no longer call getAllRoles() – instead we call getAllRolesWithId()
    // so we can track role IDs for getRolePermissionsById.
    forkJoin([
      this.authService.getAllRolesWithId(),
      this.authService.getAllPermissions()
    ]).subscribe({
      next: ([roleInfoList, perms]) => {
        // 1) Store the full role info (with IDs)
        this.allRoleInfo = roleInfoList || [];

        // 2) Also fill roles: string[] with just the role names (for your existing UI logic)
        this.roles = this.allRoleInfo.map(r => r.name);

        // 3) Store the full list of permissions
        this.allPermissions = perms || [];

        // 4) Create the assignment form
        this.createAssignForm();

        // 5) Load the assigned permissions from the DB
        this.loadRolePermissions();
      },
      error: () => this.toastr.error('Failed to load roles and permissions', 'Error')
    });
  }

  /**
   * Creates the form with "roleName" and a FormArray of booleans for each permission.
   */
  createAssignForm(): void {
    this.assignForm = this.fb.group({
      roleName: [this.roles.length > 0 ? this.roles[0] : '', Validators.required],
      permissions: this.fb.array(
        this.allPermissions.map(() => new FormControl(false))
      )
    });
  }

  /**
   * Opens the "Assign Permission" dialog.
   * Defaults to the first role if available, then calls onRoleChange() to sync checkboxes.
   */
  openAssignDialog(): void {
    if (!this.assignForm) {
      this.createAssignForm();
    }

    if (this.roles.length > 0) {
      this.assignForm.get('roleName')?.setValue(this.roles[0]);
      this.onRoleChange();
    }

    this.assignDialogRef = this.dialog.open(this.assignDialogTpl, {
      width: '400px',
      disableClose: true
    });
  }

  /**
   * Called whenever the user selects a different role name in the dialog.
   * We look up that role's assigned perms from rolePermissions (already loaded),
   * and check the appropriate boxes in the form array.
   */
  onRoleChange(): void {
    const selectedRoleName = this.assignForm.get('roleName')?.value;
    if (!selectedRoleName) return;

    // 1) Reset all checkboxes to false
    this.permissionsArray.controls.forEach(ctrl => ctrl.setValue(false));

    // 2) Find that role's assigned perms in local rolePermissions array
    const assignedPerms = this.rolePermissions.find(rp => rp.role === selectedRoleName)?.permissions || [];

    // 3) Check each permission if it's in assignedPerms
    this.permissionsArray.controls.forEach((control, index) => {
      const permName = this.allPermissions[index].name;
      control.setValue(assignedPerms.includes(permName));
    });
  }

  /**
   * Closes the "Assign Permission" dialog without saving changes.
   */
  closeAssignDialog(): void {
    this.assignDialogRef.close();
  }

  /**
   * Submits the assignment form. For every checked permission, we call the API to assign it;
   * for every unchecked permission that is currently assigned, we'd remove it. Then reload local data.
   */
  saveAssignDialog(): void {
    if (this.assignForm.invalid) return;

    const roleName = this.assignForm.get('roleName')?.value;
    const selectedPermissions = this.allPermissions
      .filter((_, i) => this.permissionsArray.at(i).value === true)
      .map(p => p.name);

    if (selectedPermissions.length === 0) {
      this.toastr.error('Please select at least one permission', 'Error');
      return;
    }

    // We do a request for each selected permission
    const requests = selectedPermissions.map(permissionName =>
      this.authService.assignPermissionToRole({ roleName, permissionName })
    );

    forkJoin(requests).subscribe({
      next: () => {
        this.toastr.success('Permissions assigned successfully', 'Success');
        this.closeAssignDialog();
        // Reload local data so the checkboxes update
        this.loadRolePermissions();
      },
      error: () => this.toastr.error('Failed to assign one or more permissions', 'Error')
    });
  }

  /**
   * Removes a permission from a role (triggered by the 'X' icon on the chip).
   */
  removePermission(roleName: string, permission: string): void {
    this.authService.removePermissionFromRole({ roleName, permissionName: permission })
      .subscribe({
        next: () => {
          this.toastr.success('Permission removed successfully', 'Success');
          this.loadRolePermissions();
        },
        error: () => this.toastr.error('Failed to remove permission', 'Error')
      });
  }

  /**
   * Loads assigned permissions for *each role name* by bridging to getRolePermissionsById.
   * Because your roles[] is just names, we find the matching ID from allRoleInfo and call getRolePermissionsById(roleId).
   * Then we store those permissions in rolePermissions for local usage.
   */
  loadRolePermissions(): void {
    if (this.roles.length === 0) return;

    // Build an array of requests, each mapping from roleName => roleId => getRolePermissionsById
    const requests = this.roles.map(roleName => {
      // find the role's ID from our allRoleInfo
      const info = this.allRoleInfo.find(r => r.name === roleName);
      if (!info) {
        // If not found, return an empty array or handle as error
        return Promise.resolve([] as PermissionShort[]);
      }
      // Now call getRolePermissionsById
      return this.authService.getRolePermissionsById(info.id).toPromise();
    });

    // forkJoin for all requests
    Promise.all(requests).then(results => {
      // results[i] is an array of PermissionShort for roles[i]
      this.rolePermissions = this.roles.map((roleName, i) => {
        const assignedShorts = results[i] || [];
        return {
          role: roleName,
          permissions: assignedShorts.map(p => p.name)
        };
      });
    })
    .catch(() => {
      this.toastr.error('Failed to load role permissions', 'Error');
    });
  }
}
