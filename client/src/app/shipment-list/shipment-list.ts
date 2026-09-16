import { Component, OnInit, inject, signal } from '@angular/core';
import { DatePipe } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ShipmentService, Shipment, ShipmentStatus } from '../core/shipment';

const STATUSES: ShipmentStatus[] = [
  'ORDER_CONFIRMED',
  'PICKED_UP',
  'DEPARTED',
  'ARRIVED_AT_HUB',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'EXCEPTION',
];

@Component({
  selector: 'app-shipment-list',
  imports: [
    FormsModule,
    RouterLink,
    DatePipe,
    MatTableModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatSlideToggleModule,
    MatButtonModule,
    MatIconModule,
  ],
  templateUrl: './shipment-list.html',
  styleUrl: './shipment-list.css',
})
export class ShipmentList implements OnInit {
  private shipmentService = inject(ShipmentService);
  private router = inject(Router);

  readonly statuses = STATUSES;
  readonly displayedColumns = ['customer_name', 'destination', 'status', 'promised_date', 'is_late'];

  shipments = signal<Shipment[]>([]);
  loading = signal(false);
  error = signal<string | null>(null);

  searchText = '';
  statusFilter = '';
  lateOnly = false;

  ngOnInit(): void {
    this.load();
  }

  load(): void {
    this.loading.set(true);
    this.error.set(null);

    this.shipmentService
      .getShipments({
        status: this.statusFilter || undefined,
        search: this.searchText || undefined,
        lateOnly: this.lateOnly,
      })
      .subscribe({
        next: (data) => {
          this.shipments.set(data);
          this.loading.set(false);
        },
        error: () => {
          this.error.set('Could not load shipments. Is the API server running?');
          this.loading.set(false);
        },
      });
  }

  openShipment(id: number): void {
    this.router.navigate(['/shipments', id]);
  }
}
