
import {Integer, Path} from 'neo4j-driver';
export class PaymentRoute{
  public hops!:Integer;
  public path!:Path;
  public node_names!:string;
}
