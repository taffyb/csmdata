import { Component, Input } from '@angular/core';
import { PathNode } from 'src/types/PathNode';
import { PaymentRoute } from 'src/types/PaymentRoute';

@Component({
  selector: 'app-route',
  templateUrl: './route.component.html',
  styleUrls: ['./route.component.css']
})
export class RouteComponent {
 @Input()path!:PaymentRoute[];
}
