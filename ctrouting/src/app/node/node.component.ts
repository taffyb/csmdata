import { PathNode } from './../../types/PathNode';
import { Component, Input } from '@angular/core';


@Component({
  selector: 'app-node',
  templateUrl: './node.component.html',
  styles: [`.circle {
    width: 50px;
    height: 50px;
    line-height: 50px;
    border-radius: 50%;
    font-size: 12px;
    color: #fff;
    text-align: center;
    background: #000;

  }`]
})
export class NodeComponent {
  @Input()size!:number;
  @Input()color!:string;
  pathNode: PathNode = new PathNode();

  constructor(){
    this.pathNode.name='T';
  }
}
