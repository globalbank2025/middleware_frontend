import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-json-payload-dialog',
  templateUrl: './json-payload-dialog.component.html',
  styleUrls: ['./json-payload-dialog.component.css']
})
export class JsonPayloadDialogComponent {
  formattedJson: string;
  isValidJson = true;

  constructor(
    public dialogRef: MatDialogRef<JsonPayloadDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { title: string; jsonString: string }
  ) {
    this.formattedJson = this.formatJson(data.jsonString);
  }

  close(): void {
    this.dialogRef.close();
  }

  private formatJson(jsonString: string): string {
    if (!jsonString) return '(No data)';
    try {
      const parsed = JSON.parse(jsonString);
      return JSON.stringify(parsed, null, 2);
    } catch {
      this.isValidJson = false;
      return jsonString; // fallback if it's not valid JSON
    }
  }
}
