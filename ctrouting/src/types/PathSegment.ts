import {Node,Relationship} from 'neo4j-driver';
export interface PathSegment {
  start:Node;
  relationship:Relationship;
  end:Node;
}
