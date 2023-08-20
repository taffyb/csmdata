//CREATE (n1:CSMParticipant)-[:DIRECT {nostro: "", vostro: "", currency: "", limit: ""}]->(n1)-[:INDIRECT {loro: "", //currency: ""}]->(n1)-[:PARTICIPANT_OF]->(n0:CSMAgent {type: "", name: ""})-[:SUPPORTS {limit: ""}]->(:Currency {isoCode: //""}),(:ProcessingEntity {id: "", name: ""})-[:USES]->(n0)

//http://user:password@host/path?query

:param auth =>({user:'admin', password:'AgentParticipantData'});

MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT u_processingEntity_id IF NOT EXISTS FOR (pe:ProcessingEntity) REQUIRE pe.id IS UNIQUE;
CREATE CONSTRAINT u_CSMAgent_id IF NOT EXISTS FOR (agent:CSMAgent) REQUIRE agent.id IS UNIQUE;
CREATE CONSTRAINT u_CSMParticipant_id IF NOT EXISTS FOR (cp:csmParticipant) REQUIRE (cp.bic, cp.iid) IS UNIQUE;
CREATE CONSTRAINT u_processingEntity IF NOT EXISTS FOR (pe2:ProcessingEntity) REQUIRE (pe2.id, pe2.name) IS UNIQUE;
CREATE CONSTRAINT u_currency_isoCode  IF NOT EXISTS FOR (c:Currency) REQUIRE c.isoCode IS UNIQUE;

//load Processing Entities
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/processingentity')
YIELD value
WITH value.settings as processingEntities
UNWIND processingEntities as entity
	MERGE (pe:ProcessingEntity{id:entity.logicalUniqueKey})
	ON CREATE SET 
		pe.name = entity.payload.processingEntityName,
		pe.bic  = entity.payload.bic,
		pe.type = entity.payload.processingEntityType;

//Load CSM Agents
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/csmagents')
YIELD value
WITH value.settings as csmAgents
UNWIND csmAgents as csmAgent
	MERGE (a:CSMAgent{id:csmAgent.logicalUniqueKey})
	ON CREATE SET 
		a.name 		= csmAgent.payload.csmAgentName,
		a.type 		= csmAgent.payload.csmAgentType,
		a.bic  		= csmAgent.payload.csmAgentBic,
		a.agentId  	= csmAgent.payload.csmAgentId,
		a.isInstant	= csmAgent.payload.instantPayments
	WITH a, csmAgent
	MATCH (pe:ProcessingEntity{id:csmAgent.processingEntity})
	MERGE (pe)-[:USES]->(a);
	
//Load CSM Agent Currency
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/csmagentcurrency')
YIELD value
WITH value.settings as csmAgentCurrencies
UNWIND csmAgentCurrencies as csmAgentCurrency
	MERGE (c:Currency{isoCode:csmAgentCurrency.payload.transferCurrency})
	WITH c, csmAgentCurrency
	MATCH (pe:ProcessingEntity{id:csmAgentCurrency.processingEntity})-[USES]-(a:CSMAgent{agentId:csmAgentCurrency.payload.csmAgentId})
	MERGE (a)-[s:SUPPORTS]->(c)
	WITH s,csmAgentCurrency
	UNWIND csmAgentCurrency.payload.limits as limit
		SET s.limitType = limit.limitType,
			s.limit		= limit.amount;
			


//Load CSMParticipants
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/participant')
YIELD value
WITH value.settings as CSMParticipants
UNWIND CSMParticipants as Participant
	MERGE (cp:CSMParticipant{id:Participant.payload.csmParticipantIdentifier})
	ON CREATE SET 
		cp.processingEntity     = Participant.processingEntity,
		cp.name     			= Participant.payload.participantName,
		cp.branchId     		= Participant.payload.industryFields.branchId,
		cp.headOffice     		= Participant.payload.industryFields.headOffice,
		cp.iidType  	   		= Participant.payload.industryFields.iidType,
		cp.sic     				= Participant.payload.industryFields.sic,
		cp.euroSic     			= Participant.payload.industryFields.euroSic,
		cp.sicBic     			= Participant.payload.industryFields.sicBic,
		cp.sicIid     			= Participant.payload.industryFields.sicIid,
		cp.newIid     			= Participant.payload.industryFields.newIid,
		cp.domicileAddress  	= Participant.payload.domicileAddress,
		cp.city     			= Participant.payload.participantCity,
		cp.postalCode     		= Participant.payload.postalCode,
		cp.postalAddress    	= Participant.payload.postalAddress,
		cp.participantCountry   = Participant.payload.participantCountry
	WITH cp, Participant
	MERGE (csmAgent:CSMAgent{agentId:Participant.payload.csmAgentId})
	MERGE (cp)-[of:PARTICIPANT_OF]->(csmAgent)
		SET of.type = Participant.payload.participantType;


//Load SCT Inst CSMAgent
MERGE (a:CSMAgent{id:"001-SCT-Inst"})
ON CREATE SET 
	a.name 		= "SEPA Inst Credit Transfer",
	a.type 		= "RTGS",
	a.agentId  	= "SCT-Inst",
	a.isInstant	= true
WITH a
MATCH (pe:ProcessingEntity{id:"001"})
MERGE (c:Currency{isoCode:"EUR"})
MERGE (pe)-[:USES]->(a)
MERGE (a)-[:SUPPORTS]->(c);

//Load SCT Inst Participants
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/sct-inst')
YIELD value
WITH value as SCTParticipants
UNWIND SCTParticipants as Participant
	MERGE (cp:CSMParticipant{id:randomUUID()})
	ON CREATE SET 
		cp.name     			= Participant.ParticipantName,
		cp.Bic     				= Participant.BIC,
		cp.domicileAddress  	= Participant.Address,
		cp.city     			= Participant.City,
		cp.participantCountry   = Participant.Country
	WITH cp, Participant
	MERGE (csmAgent:CSMAgent{agentId:"SCT-Inst"})
	MERGE (cp)-[of:PARTICIPANT_OF]->(csmAgent)
		SET of.type = Participant.payload.participantType;

