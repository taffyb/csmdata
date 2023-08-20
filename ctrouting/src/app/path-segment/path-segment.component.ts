import { Component, Input } from '@angular/core';
import { PathSegment } from 'src/types/PathSegment';

@Component({
  selector: 'app-path-segment',
  templateUrl: './path-segment.component.html',
  styleUrls: ['./path-segment.component.css']
})
export class PathSegmentComponent {
  @Input()segment!:PathSegment;
  @Input()idx!:number;
}
