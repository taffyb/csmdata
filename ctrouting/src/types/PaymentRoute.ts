
import {Integer, Node} from 'neo4j-driver';
import { PathSegment } from './PathSegment';
export class PaymentRoute{
  public hops!:Integer;
  public path!:{start:Node,segments:PathSegment[],end:Node,length:Integer};
  public node_names!:string;
  public order!:number;
}
