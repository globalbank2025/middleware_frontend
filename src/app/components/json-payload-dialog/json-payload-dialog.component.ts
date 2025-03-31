import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-json-payload-dialog',
  templateUrl: './json-payload-dialog.component.html',
  styleUrls: ['./json-payload-dialog.component.css']
})
export class JsonPayloadDialogComponent {
  formattedData: string;
  isJson = false;
  isXml = false;

  constructor(
    public dialogRef: MatDialogRef<JsonPayloadDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { title: string; jsonString: string }
  ) {
    this.formattedData = this.formatData(data.jsonString);
  }

  close(): void {
    this.dialogRef.close();
  }

  private formatData(dataStr: string): string {
    if (!dataStr) return '(No data)';
    
    // Try formatting as JSON
    try {
      const parsed = JSON.parse(dataStr);
      this.isJson = true;
      return JSON.stringify(parsed, null, 2);
    } catch (jsonErr) {
      // Not valid JSON; try XML if it appears to be XML
      if (dataStr.trim().startsWith('<')) {
        try {
          this.isXml = true;
          return this.formatXml(dataStr);
        } catch (xmlErr) {
          // If XML formatting fails, just return the raw data
          return dataStr;
        }
      }
      // Otherwise, return the data as-is
      return dataStr;
    }
  }

  private formatXml(xml: string): string {
    // A simple XML pretty printer
    let formatted = '';
    const reg = /(>)(<)(\/*)/g;
    xml = xml.replace(reg, '$1\r\n$2$3');
    let pad = 0;
    xml.split('\r\n').forEach((node) => {
      let indent = 0;
      if (node.match(/.+<\/\w[^>]*>$/)) {
        indent = 0;
      } else if (node.match(/^<\/\w/)) {
        if (pad !== 0) {
          pad -= 1;
        }
      } else if (node.match(/^<\w[^>]*[^\/]>.*$/)) {
        indent = 1;
      } else {
        indent = 0;
      }
      formatted += '  '.repeat(pad) + node + '\r\n';
      pad += indent;
    });
    return formatted;
  }
}
