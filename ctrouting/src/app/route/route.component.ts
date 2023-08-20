import { Component, Input } from '@angular/core';
import { PaymentRoute } from 'src/types/PaymentRoute';

@Component({
  selector: 'app-route',
  templateUrl: './route.component.html',
  styleUrls: ['./route.component.css']
})
export class RouteComponent {
 @Input()route!:PaymentRoute;
}
