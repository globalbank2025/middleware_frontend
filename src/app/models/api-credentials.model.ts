export interface ApiCredentials {
    apiCredId?: number;
    partnerId: number;      // Link to Partner
    serviceId: number;      // Link to Service
    apiKey: string;
    apiSecret: string;
    username: string;
    password: string;
    tokenExpiry?: string;   // or Date
    allowedIp: string;
    status: string;         // "ACTIVE" or "INACTIVE"
    createdAt?: string;
    updatedAt?: string;
  }
  