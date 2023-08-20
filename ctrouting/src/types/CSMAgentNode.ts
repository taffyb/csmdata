import {Integer, Node} from'neo4j-driver';

export type CSMAgentNode =Node<Integer,{
  agentId:string,
  name:string,
  type:string,
}>
