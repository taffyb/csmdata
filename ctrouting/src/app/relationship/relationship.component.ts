import { Component, Input } from '@angular/core';
import { Relationship } from 'neo4j-driver';

@Component({
  selector: 'app-relationship',
  templateUrl: './relationship.component.html',
  styleUrls: ['./relationship.component.css']
})
export class RelationshipComponent {
  @Input()rel!:Relationship;
}
