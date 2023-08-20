import { TestBed } from '@angular/core/testing';

import { CSMService } from './csm.service';

describe('CSMService', () => {
  let service: CSMService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CSMService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
