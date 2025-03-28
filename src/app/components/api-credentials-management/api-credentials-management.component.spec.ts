import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ApiCredentialsManagementComponent } from './api-credentials-management.component';

describe('ApiCredentialsManagementComponent', () => {
  let component: ApiCredentialsManagementComponent;
  let fixture: ComponentFixture<ApiCredentialsManagementComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [ ApiCredentialsManagementComponent ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ApiCredentialsManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
