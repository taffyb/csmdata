import {Integer, Node} from'neo4j-driver';

export type CSMParticipantNode =Node<Integer,{
  currency:string,
  of:string,
  id:string
}>
