import { CSMParticipant } from 'src/types/CSMParticipant';
import { Injectable } from '@angular/core';
import { CSMAgent } from 'src/types/CSMAgent';
import { Currency } from 'src/types/Currency';
import {Observable, of} from "rxjs";
import { map,tap } from 'rxjs/operators';
import {HttpClient} from "@angular/common/http";
import * as _ from 'lodash';

@Injectable({
  providedIn: 'root'
})
export class CSMService {
  private participants!:CSMParticipant[];
  constructor(private http:HttpClient) { }

  public getCSMAgents$():Observable<CSMAgent[]>{
    let url:string = 'https://kzbx5f89j4.execute-api.eu-west-2.amazonaws.com/default/agents';
    // console.log(url);

    return this.http
    .get<CSMAgent[]>(url)
    .pipe(map(data => _.values(data)))
    // .pipe(tap(console.log));
  }
  public getCSMParticipants$():Observable<CSMParticipant[]>{
    let url:string = 'https://kzbx5f89j4.execute-api.eu-west-2.amazonaws.com/default/participants';
    // console.log(url);
    if(!this.participants){
      return this.http
      .get<CSMParticipant[]>(url)
      .pipe(map(data => _.values(data)))
      // .pipe(tap(console.log))
      .pipe(tap(data => this.participants=data));
    }else{
      return of(this.participants);
    }
  }
  public getParticipant(participantId:string):CSMParticipant{
    let participant:CSMParticipant= new CSMParticipant();
    this.participants.forEach(p=>{
      if(p.bankIdentifier==participantId){
        participant=p;
      }
    });
    // console.log(`getParticipant.participantId ${participantId} (${JSON.stringify(participant,null,2)})`);

    return participant;
  }
  public getCurrencies$():Observable<Currency[]>{
    let url:string = 'https://kzbx5f89j4.execute-api.eu-west-2.amazonaws.com/default/currency';
    // console.log(url);

    return this.http
    .get<Currency[]>(url)
    .pipe(map(data => _.values(data)))
    // .pipe(tap(console.log));
  }
}

