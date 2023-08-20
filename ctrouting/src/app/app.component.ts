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
  selectedCurrency:string="CHF";
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
    params.sourceId = this.sourceParticipant.bankIdentifier;
    params.targetId = this.targetParticipant.bankIdentifier;
    params.csmSelectionOrder = new CSMSelectionOrder();
    params.csmSelectionOrder.transferCurrency=this.selectedCurrency;
    params.csmSelectionOrder.serviceLevel = this.selectedServiceLevel;
    params.csmSelectionOrder.csmAgentOptions = this.csmSelectionOrder.csmAgentOptions;

    console.log(`Parameters: ${JSON.stringify(params,null,2)}`);
    this.paymentRoutes$=null;
    this.paymentRoutes$= this.routingSvc.findRoutes(params);
  }
  definePresets():Parameters[]{
    let presets:Parameters[]=[];
    presets.push(
      {
        sourceId:"UBSWCHZH93A",
        targetId:"UBSWCHZH70A",
        processingEntityId:"001",
        csmSelectionOrder:{
          transferCurrency:"CHF",
          serviceLevel:"INST",
          paymentType:"ACTR",
          csmAgentOptions: [
            {
              order: 1,
              csmAgentId: "UbsCh"
            }
          ]
        }
      }
    );
    return presets;
  }
  selectPreset(p:Parameters){
    this.selectedCurrency=p.csmSelectionOrder.transferCurrency;
    this.selectedServiceLevel=p.csmSelectionOrder.serviceLevel;
    this.targetParticipant=this.csmSvc.getParticipant(p.targetId);
    this.sourceParticipant=this.csmSvc.getParticipant(p.sourceId);
    this.csmSelectionOrder = p.csmSelectionOrder;
  }
}

