import {Integer, Node} from'neo4j-driver';

export type FinancialInstitutionNode =Node<Integer,{
  country:string,
  branchId:string,
  domicileAddress:string,
  postalAddress:string,
  city:string,
  postalCode:string,
  name:string,
  id:string
}>
