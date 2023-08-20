//CREATE (n1:CSMParticipant)-[:DIRECT {nostro: "", vostro: "", currency: "", limit: ""}]->(n1)-[:INDIRECT {loro: "", //currency: ""}]->(n1)-[:PARTICIPANT_OF]->(n0:CSMAgent {type: "", name: ""})-[:SUPPORTS {limit: ""}]->(:Currency {isoCode: //""}),(:ProcessingEntity {id: "", name: ""})-[:USES]->(n0)

//http://user:password@host/path?query

:param auth =>({user:'admin', password:'AgentParticipantData'});

MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT u_processingEntity_id IF NOT EXISTS FOR (pe:ProcessingEntity) REQUIRE pe.id IS UNIQUE;
CREATE CONSTRAINT u_FinancialInstitution_id IF NOT EXISTS FOR (fi:FinancialInstitution) REQUIRE fi.id IS UNIQUE;
CREATE CONSTRAINT u_CSMAgent_id IF NOT EXISTS FOR (agent:CSMAgent) REQUIRE agent.id IS UNIQUE;
CREATE CONSTRAINT u_CSMParticipant_id IF NOT EXISTS FOR (cp:csmParticipant) REQUIRE cp.id IS UNIQUE;
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
			
//Load FI 
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/participant')
YIELD value
WITH value.settings as FIs
UNWIND FIs as FI
	MERGE (fi:FinancialInstitution{id:FI.payload.csmParticipantIdentifier})
	ON CREATE SET 
		fi.processingEntity     = FI.processingEntity,
		fi.name     			= FI.payload.participantName,
		fi.branchId     		= FI.payload.industryFields.branchId,
		fi.headOffice     		= FI.payload.industryFields.headOffice,
		fi.domicileAddress  	= FI.payload.domicileAddress,
		fi.city     			= FI.payload.participantCity,
		fi.postalCode     		= FI.payload.postalCode,
		fi.postalAddress    	= FI.payload.postalAddress,
		fi.country              = FI.payload.participantCountry
	WITH FI,fi, (CASE 
				WHEN FI.payload.csmAgentId="SIC" THEN FI.payload.industryFields.sicIid 
				WHEN FI.payload.csmAgentId="euroSIC" THEN FI.payload.industryFields.sicBic 
				WHEN FI.payload.csmAgentId="UbsCh" THEN FI.payload.industryFields.sicBic 
			  END) as participantId
	CREATE (p:CSMParticipant{id:participantId})
		SET p.of=FI.payload.csmAgentId	
//	WITH FI,fi,p
	MERGE (a:CSMAgent{agentId:FI.payload.csmAgentId})
//	WITH FI,fi,a,p
	MERGE (fi)-[:DIRECT]->(p)-[:OF]->(a);



	
//Load MPD Services
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/mpd-services')
YIELD value
WITH value as Services
UNWIND Services as Service
	MERGE (a:CSMAgent{agentId:Service.Service})
		SET a.name=Service.ServiceName, a.mpd=true
	FOREACH(cur IN CASE WHEN NOT Service.CurrencyCode IS NULL THEN [Service.CurrencyCode] ELSE [] END |
		MERGE (c:Currency{isoCode:cur})
			ON CREATE SET c.mpd=true
		MERGE (a)-[s:SUPPORTS]->(c)
	);

//Load MPD DIRECT participants 
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/mpd-direct-participant')
YIELD value
WITH value as FIs
UNWIND FIs as FI
	MERGE (fi:FinancialInstitution{id:FI.MPDKey})
	ON CREATE SET 
		fi.processingEntity     = "001",
		fi.name     			= FI.Name,
		fi.domicileAddress  	= FI.Address,
		fi.city     			= FI.City,
		fi.postalCode     		= FI.postalCode,
		fi.postalAddress    	= FI.Address,
		fi.country              = FI.Country,
		fi.mpd = true
	CREATE (p:CSMParticipant{id:FI.MktSerId})
		SET p.of=FI.Service,
			p.currency = FI.CurrencyCode,
			p.mpd=true	
	WITH FI,fi,p
	MERGE (fi)-[:DIRECT]->(p) 
	MERGE (a:CSMAgent{agentId:FI.Service})
		ON CREATE SET a.mpd=true
	MERGE (p)-[:OF]->(a);

//Load MPD INDIRECT participants 
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/mpd-indirect-participant')
YIELD value
WITH value as FIs
UNWIND FIs as FI
	MERGE (fi:FinancialInstitution{id:FI.MPDKey})
	ON CREATE SET 
		fi.processingEntity     = "001",
		fi.name     			= FI.Name,
		fi.domicileAddress  	= FI.Address,
		fi.city     			= FI.City,
		fi.postalCode     		= FI.postalCode,
		fi.postalAddress    	= FI.Address,
		fi.country              = FI.Country,
		fi.mpd = true
	MERGE (ip:CSMParticipant{id:FI.MktSerId})
	ON CREATE SET
		ip.mpd = true
	WITH fi,FI,ip, CASE WHEN FI.Service="CHI" THEN "CPI" ELSE FI.Service END as service
	MATCH (holder:FinancialInstitution{id:FI.HolderMPDKey})-[:DIRECT]->(p:CSMParticipant)-[:OF]-(a:CSMAgent{agentId:service})	
	WITH fi,p,ip
	MERGE (fi)-[:DIRECT]->(ip)-[:INDIRECT]->(p);
	
//Load MPD Correspondants 
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/mpd-correspondant')
YIELD value
WITH value as FIs
UNWIND FIs as FI
	MATCH (owner:FinancialInstitution{id:FI.MPDKey_Owner})
	MATCH (holder:FinancialInstitution{id:FI.MPDKey_Holder})
	WITH owner,holder
	MERGE (owner)-[:CORRESPONDANT_OF]->(holder);

// Merge IPF euroSIC and MPD 
MATCH (a1:CSMAgent{agentId:"euroSIC"}),(a2:CSMAgent{agentId:"PCH"})
CALL apoc.refactor.mergeNodes([a1,a2],{}) YIELD node;