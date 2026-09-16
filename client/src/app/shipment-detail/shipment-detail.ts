import { Component, OnInit, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import {
  ShipmentService,
  ShipmentDetail as ShipmentDetailModel,
  ShipmentStatus,
  TRANSITIONS,
} from '../core/shipment';

@Component({
  selector: 'app-shipment-detail',
  imports: [RouterLink, DatePipe, FormsModule, MatButtonModule, MatIconModule, MatFormFieldModule, MatInputModule],
  templateUrl: './shipment-detail.html',
  styleUrl: './shipment-detail.css',
})
export class ShipmentDetail implements OnInit {
  private route = inject(ActivatedRoute);
  private shipmentService = inject(ShipmentService);

  shipment = signal<ShipmentDetailModel | null>(null);
  loading = signal(true);
  error = signal<string | null>(null);
  recording = signal(false);

  eventNote = '';

  ngOnInit(): void {
    const id = Number(this.route.snapshot.paramMap.get('id'));
    this.load(id);
  }

  load(id: number): void {
    this.loading.set(true);
    this.error.set(null);

    this.shipmentService.getShipment(id).subscribe({
      next: (data) => {
        this.shipment.set(data);
        this.loading.set(false);
      },
      error: () => {
        this.error.set('Shipment not found.');
        this.loading.set(false);
      },
    });
  }

  get nextStatuses(): ShipmentStatus[] {
    const current = this.shipment();
    return current ? TRANSITIONS[current.status] : [];
  }

  recordEvent(status: ShipmentStatus): void {
    const current = this.shipment();
    if (!current) return;

    this.recording.set(true);
    const note = this.eventNote.trim() || undefined;

    this.shipmentService.recordEvent(current.id, { status, note }).subscribe({
      next: () => {
        this.recording.set(false);
        this.eventNote = '';
        this.load(current.id);
      },
      error: () => {
        this.recording.set(false);
        this.error.set('Could not record that event.');
      },
    });
  }
}
