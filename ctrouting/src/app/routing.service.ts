import { Injectable } from '@angular/core';
import { Parameters } from 'src/types/Parameters';
import { PaymentRoute } from 'src/types/PaymentRoute';
import {Integer, Node, Relationship, PathSegment} from 'neo4j-driver';
import { Observable } from 'rxjs/internal/Observable';
import { map, tap } from 'rxjs/operators';
import * as _ from 'lodash';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class RoutingService {
  private params!:Parameters;

  constructor(private http:HttpClient) { }

  public findRoutes(params:Parameters):Observable<PaymentRoute[]>{
    let url:string = 'https://kzbx5f89j4.execute-api.eu-west-2.amazonaws.com/default/find-routes';
    console.log(`
    URL: ${url}
    Params: ${JSON.stringify(params,null,2)}`);

    return this.http
    .post<PaymentRoute[]>(url,params)
    .pipe(map(data => _.values(data)))
    .pipe(tap(console.log));
  }

  private toNumber(arg:{ low:any, high:any }) {
    let res = arg.high

    for (let i = 0; i < 32; i++) {
      res *= 2
    }

    return arg.low + res
  }
}
