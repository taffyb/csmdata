 interface ICSMParticipant{
  domicileAddress:string;
  city:string;
  bankIdentifier:string;
  bankIdentifierType:string;
  name:string;
  participantCountry:string;
}

export class CSMParticipant implements ICSMParticipant{
  domicileAddress!: string;
  city!: string;
  bankIdentifier!: string;
  bankIdentifierType!: string;
  name!: string;
  participantCountry!: string;

}
