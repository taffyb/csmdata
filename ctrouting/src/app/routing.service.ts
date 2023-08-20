import { Injectable } from '@angular/core';
import { Parameters } from 'src/types/Parameters';
import { PaymentRoute } from 'src/types/PaymentRoute';
import { Observable } from 'rxjs/internal/Observable';
import { map, tap } from 'rxjs/operators';
import * as _ from 'lodash';
import { HttpClient } from '@angular/common/http';
import { of } from 'rxjs';
import { CSMAgentNode } from 'src/types/CSMAgentNode';

@Injectable({
  providedIn: 'root'
})
export class RoutingService {

  constructor(private http:HttpClient) { }

  public findRoutes(params:Parameters):Observable<PaymentRoute[]>{


    return new Observable<PaymentRoute[]>(observer=>{
      let paymentRoutes:PaymentRoute[]=[];

      this.getRoutes(params).subscribe({
        next: routes=> {
          routes.forEach(route=>{
            this.calculateOrder(route,params);
          })
          routes.sort((a,b)=>a.order-b.order)
          paymentRoutes=routes;
        },
        complete:()=>{
          observer.next(paymentRoutes);
          observer.complete();
        }
      });
    });
  }
  private calculateOrder(route:PaymentRoute,params:Parameters){
    let order=0;
    route.path.segments.forEach(segment=>{
      if(segment.start.labels[0]=="CSMAgent"){
        let csmOrder=100;
        params.csmSelectionOrder.csmAgentOptions.forEach(option=>{
          let node=segment.start as CSMAgentNode;
          if(option.csmAgentId==node.properties.agentId){
            csmOrder=option.order;
          }
        })
        order+=csmOrder;
      }
    })
    route.order=order;
  }
  private getRoutes(params:Parameters):Observable<PaymentRoute[]>{
    let url:string = 'https://kzbx5f89j4.execute-api.eu-west-2.amazonaws.com/default/find-routes';

    return this.http
    .post<PaymentRoute[]>(url,params)
    .pipe(map(data => _.values(data)))
  }
}
