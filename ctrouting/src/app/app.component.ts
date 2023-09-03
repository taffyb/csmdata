import { Observable } from 'rxjs';
import { Component } from '@angular/core';
import { Parameters } from 'src/types/Parameters';
import { CSMService } from './csm.service';
import { Currency } from 'src/types/Currency';
import { CSMParticipant } from 'src/types/CSMParticipant';
import { CSMSelectionOrder } from 'src/types/CSMSelectionOrder';
import { PaymentRoute } from 'src/types/PaymentRoute';
import { RoutingService } from './routing.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'ctrouting';
  user!:string;
  pwd!:string;
  selectedServiceLevel!:string;
  selectedPreset!:Parameters;
  currencies$!:Observable<Currency[]>;
  sourceParticipants$!:Observable<CSMParticipant[]>;
  targetParticipants$!:Observable<CSMParticipant[]>;
  paymentRoutes$!:Observable<PaymentRoute[]>|null;
  selectedCurrency:string="";
  sourceParticipant!:CSMParticipant;
  targetParticipant!:CSMParticipant;
  csmSelectionOrder!:CSMSelectionOrder;

  presets:Parameters[] = this.definePresets();


  constructor(private csmSvc:CSMService,
    private routingSvc:RoutingService){
    this.currencies$=csmSvc.getCurrencies$();
    this.sourceParticipants$=csmSvc.getCSMParticipants$();
    this.targetParticipants$=csmSvc.getCSMParticipants$();

  }
  onFindPayment(){
    const params:Parameters = new Parameters();
    if(this.sourceParticipant && this.targetParticipant){
      params.sourceId = this.sourceParticipant.bankIdentifier;
      params.targetId = this.targetParticipant.bankIdentifier;
    }

    // console.log(`Parameters: ${JSON.stringify(params,null,2)}`);
    this.paymentRoutes$=null;
    this.paymentRoutes$= this.routingSvc.findRoutes(params);
  }
  definePresets():Parameters[]{
    let presets:Parameters[]=[];
    presets.push(
      {
        sourceId:"UBSWCHZH89D",
        targetId:"UBSWCHZH70A",
        description:"Two UBS branches only accessible OnUs"
      },
      {
        sourceId:"UBSWCHZH93A",
        targetId:"UBSWCHZH70A",
        description:"Two UBS branches participants of OnUs and SICInst. Priority to OnUs"
      },
      {
        sourceId:"UBSWCHZH93A",
        targetId:"UBSWCHZH70A",
        description:"Two UBS branches participants of OnUs and SICInst. Priority to SICInst to demonstrate changing Order"
      }
    );
    return presets;
  }
  selectPreset(p:Parameters){
    this.targetParticipant=this.csmSvc.getParticipant(p.targetId);
    this.sourceParticipant=this.csmSvc.getParticipant(p.sourceId);
  }
}

