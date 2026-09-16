import { Component, OnInit, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { ShipmentService, Customer } from '../core/shipment';

@Component({
  selector: 'app-shipment-new',
  imports: [
    FormsModule,
    RouterLink,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatButtonModule,
    MatIconModule,
  ],
  templateUrl: './shipment-new.html',
  styleUrl: './shipment-new.css',
})
export class ShipmentNew implements OnInit {
  private shipmentService = inject(ShipmentService);
  private router = inject(Router);

  customers = signal<Customer[]>([]);
  submitting = signal(false);
  error = signal<string | null>(null);

  customerId: number | null = null;
  destination = '';
  promisedDate = '';

  ngOnInit(): void {
    this.shipmentService.getCustomers().subscribe({
      next: (data) => this.customers.set(data),
      error: () => this.error.set('Could not load customers.'),
    });
  }

  submit(): void {
    if (!this.customerId || !this.destination || !this.promisedDate) {
      this.error.set('Please fill in all fields.');
      return;
    }

    this.submitting.set(true);
    this.error.set(null);

    this.shipmentService
      .createShipment({
        customerId: this.customerId,
        destination: this.destination,
        promisedDate: this.promisedDate,
      })
      .subscribe({
        next: (shipment) => {
          this.router.navigate(['/shipments', shipment.id]);
        },
        error: () => {
          this.submitting.set(false);
          this.error.set('Could not create shipment.');
        },
      });
  }
}
