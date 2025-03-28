export interface Service {
    serviceId?: number;
    serviceCode: string;
    serviceName: string;
    description: string;
    serviceType: string;  // "Credit" or "Debit"
    offsetAccNo: string;
    status: string;       // "ACTIVE" or "INACTIVE"
    createdAt?: string;
    updatedAt?: string;
  }
  