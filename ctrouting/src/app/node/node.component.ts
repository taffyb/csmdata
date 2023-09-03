import { Component, Input } from '@angular/core';
import { Node } from 'neo4j-driver';
import { CSMAgentNode } from 'src/types/CSMAgentNode';
import { CSMParticipantNode } from 'src/types/CSMParticipantNode';
import { FinancialInstitutionNode } from 'src/types/FinancialInstitutionNode';

@Component({
  selector: 'app-node',
  templateUrl: './node.component.html',
  styleUrls: ['./node.component.css']
})
export class NodeComponent {
  @Input()size!:number;
  @Input()color!:string;
  @Input()node!: Node;

  nodeText(){
    let text:string="";
    let node;
    switch (this.node.labels[0]) {
      case "FinancialInstitution":
        node=this.node as FinancialInstitutionNode;
        text=`${node.properties.name}
         (${node.properties.city})`;
        break;
      case "CSMAgent":
        node=this.node as CSMAgentNode;
        text=node.properties.name;
        break;
        case "CSMParticipant":
          node=this.node as CSMParticipantNode;
          text=`${node.properties.id?node.properties.id:"Cor"}
          ${node.properties.currency?'in '+node.properties.currency:''}`;
          break;

      default:
        text=this.node.labels[0]
        break;
    }
    return text;
  }
}
