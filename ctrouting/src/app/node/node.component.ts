import { PathNode } from './../../types/PathNode';
import { Component, Input } from '@angular/core';


@Component({
  selector: 'app-node',
  templateUrl: './node.component.html',
  styleUrls: ['./node.component.css']
})
export class NodeComponent {
  @Input()size!:number;
  @Input()color!:string;
  @Input()last:boolean=false;
  @Input()pathNode!: PathNode;
}
