import { Service, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

const API_BASE = 'http://localhost:3000/api';

export type ShipmentStatus =
  | 'ORDER_CONFIRMED'
  | 'PICKED_UP'
  | 'DEPARTED'
  | 'ARRIVED_AT_HUB'
  | 'OUT_FOR_DELIVERY'
  | 'DELIVERED'
  | 'EXCEPTION';

export interface Shipment {
  id: number;
  destination: string;
  promised_date: string;
  status: ShipmentStatus;
  created_at: string;
  customer_id: number;
  customer_name: string;
  is_late: boolean;
}

export interface ShipmentEvent {
  id: number;
  status: ShipmentStatus;
  note: string | null;
  occurred_at: string;
}

export interface ShipmentDetail extends Shipment {
  customer_email: string;
  customer_address: string;
  events: ShipmentEvent[];
}

export interface Customer {
  id: number;
  name: string;
  email: string;
  address: string;
}

export interface ShipmentFilters {
  status?: string;
  search?: string;
  lateOnly?: boolean;
}

// A UI-only copy of the server's transition rule (server/lib/transitions.js),
// used only to decide which "record event" buttons to show. The server is
// still the real enforcement — this just avoids offering a button for a move
// the server would reject anyway.
export const TRANSITIONS: Record<ShipmentStatus, ShipmentStatus[]> = {
  ORDER_CONFIRMED: ['PICKED_UP', 'EXCEPTION'],
  PICKED_UP: ['DEPARTED', 'EXCEPTION'],
  DEPARTED: ['ARRIVED_AT_HUB', 'EXCEPTION'],
  ARRIVED_AT_HUB: ['OUT_FOR_DELIVERY', 'EXCEPTION'],
  OUT_FOR_DELIVERY: ['DELIVERED', 'EXCEPTION'],
  DELIVERED: [],
  EXCEPTION: [],
};

@Service()
export class ShipmentService {
  private http = inject(HttpClient);

  getShipments(filters: ShipmentFilters = {}): Observable<Shipment[]> {
    const params: Record<string, string> = {};
    if (filters.status) params['status'] = filters.status;
    if (filters.search) params['search'] = filters.search;
    if (filters.lateOnly) params['lateOnly'] = 'true';

    return this.http.get<Shipment[]>(`${API_BASE}/shipments`, { params });
  }

  getShipment(id: number): Observable<ShipmentDetail> {
    return this.http.get<ShipmentDetail>(`${API_BASE}/shipments/${id}`);
  }

  createShipment(data: {
    customerId: number;
    destination: string;
    promisedDate: string;
  }): Observable<Shipment> {
    return this.http.post<Shipment>(`${API_BASE}/shipments`, data);
  }

  recordEvent(
    shipmentId: number,
    data: { status: ShipmentStatus; note?: string }
  ): Observable<ShipmentEvent> {
    return this.http.post<ShipmentEvent>(`${API_BASE}/shipments/${shipmentId}/events`, data);
  }

  getCustomers(): Observable<Customer[]> {
    return this.http.get<Customer[]>(`${API_BASE}/customers`);
  }
}
