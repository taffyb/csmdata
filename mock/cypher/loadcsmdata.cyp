//CREATE (n1:CSMParticipant)-[:DIRECT {nostro: "", vostro: "", currency: "", limit: ""}]->(n1)-[:INDIRECT {loro: "", //currency: ""}]->(n1)-[:PARTICIPANT_OF]->(n0:CSMAgent {type: "", name: ""})-[:SUPPORTS {limit: ""}]->(:Currency {isoCode: //""}),(:ProcessingEntity {id: "", name: ""})-[:USES]->(n0)

//http://user:password@host/path?query

:param auth =>({user:'admin', password:'AgentParticipantData'});

MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT u_processingEntity_id IF NOT EXISTS FOR (pe:ProcessingEntity) REQUIRE pe.id IS UNIQUE;
CREATE CONSTRAINT u_CSMAgent_id IF NOT EXISTS FOR (agent:CSMAgent) REQUIRE agent.id IS UNIQUE;
CREATE CONSTRAINT u_FI_id IF NOT EXISTS FOR (fi:FinancialInstitution) REQUIRE (fi.bic, fi.iid) IS UNIQUE;
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
			
//Load CSM Agent Selection Order
//CALL //apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/csmagentselectionorder')
//YIELD value
//WITH value.settings as csmAgents
//UNWIND csmAgentCurrencies as csmAgentCurrency

//Load CSMParticipants as FinancialInstitutions
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/participant')
YIELD value
WITH value.settings as FinancialInstitutions
UNWIND FinancialInstitutions as FinancialInstitution
	MERGE (fi:FinancialInstitution{id:FinancialInstitution.payload.csmParticipantIdentifier})
	ON CREATE SET 
		fi.name     			= FinancialInstitution.payload.participantName,
		fi.branchId     		= FinancialInstitution.payload.industryFields.branchId,
		fi.headOffice     		= FinancialInstitution.payload.industryFields.headOffice,
		fi.iidType  	   		= FinancialInstitution.payload.industryFields.iidType,
		fi.sic     				= FinancialInstitution.payload.industryFields.sic,
		fi.euroSic     			= FinancialInstitution.payload.industryFields.euroSic,
		fi.sicBic     			= FinancialInstitution.payload.industryFields.sicBic,
		fi.sicIid     			= FinancialInstitution.payload.industryFields.sicIid,
		fi.newIid     			= FinancialInstitution.payload.industryFields.newIid,
		fi.domicileAddress  	= FinancialInstitution.payload.domicileAddress,
		fi.city     			= FinancialInstitution.payload.participantCity,
		fi.postalCode     		= FinancialInstitution.payload.postalCode,
		fi.postalAddress    	= FinancialInstitution.payload.postalAddress,
		fi.participantCountry   = FinancialInstitution.payload.participantCountry
		//fi.csmAgent 			= FinancialInstitution.payload.csmAgentId
	WITH fi, FinancialInstitution
	MERGE (csmAgent:CSMAgent{agentId:FinancialInstitution.payload.csmAgentId})
	MERGE (fi)-[of:PARTICIPANT_OF]->(csmAgent)
		SET of.type = FinancialInstitution.payload.participantType;