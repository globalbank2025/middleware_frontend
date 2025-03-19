export interface ServiceIncomeGl {
  id: number;
  glCode: string;         // Exactly 7-digit numeric string (preserved as string to maintain leading zeros)
  name: string;
  description?: string;
  status: 'Open' | 'Closed';
  calculationType: 'Flat' | 'Rate';
  flatPrice?: number;     // Required if calculationType is 'Flat'
  rate?: number;          // Required if calculationType is 'Rate'
}
