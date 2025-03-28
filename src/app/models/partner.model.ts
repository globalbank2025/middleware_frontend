export interface Partner {
    partnerId?: number;  // optional when creating a new partner
    partnerCode: string;
    partnerName: string;
    contactPerson: string;
    contactEmail: string;
    contactPhone: string;
    status: string;
    createdAt?: Date;
    updatedAt?: Date;
  }
  