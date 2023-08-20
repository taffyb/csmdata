import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PathSegmentComponent } from './path-segment.component';

describe('PathSegmentComponent', () => {
  let component: PathSegmentComponent;
  let fixture: ComponentFixture<PathSegmentComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [PathSegmentComponent]
    });
    fixture = TestBed.createComponent(PathSegmentComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
