import { Routes } from '@angular/router';
import { ShipmentList } from './shipment-list/shipment-list';
import { ShipmentDetail } from './shipment-detail/shipment-detail';
import { ShipmentNew } from './shipment-new/shipment-new';

// Order matters: 'shipments/new' must be listed before 'shipments/:id',
// otherwise the router would treat "new" as an :id value.
export const routes: Routes = [
  { path: '', component: ShipmentList },
  { path: 'shipments/new', component: ShipmentNew },
  { path: 'shipments/:id', component: ShipmentDetail },
];
