//CREATE (n1:CSMParticipant)-[:DIRECT {nostro: "", vostro: "", currency: "", limit: ""}]->(n1)-[:INDIRECT {loro: "", //currency: ""}]->(n1)-[:PARTICIPANT_OF]->(n0:CSMAgent {type: "", name: ""})-[:SUPPORTS {limit: ""}]->(:Currency {isoCode: //""}),(:ProcessingEntity {id: "", name: ""})-[:USES]->(n0)

//http://user:password@host/path?query

:param auth =>({user:'admin', password:'AgentParticipantData'});

MATCH (n) DETACH DELETE n;

CREATE CONSTRAINT u_processingEntity_id IF NOT EXISTS FOR (pe:ProcessingEntity) REQUIRE pe.id IS UNIQUE;
CREATE CONSTRAINT u_CSMAgent_id IF NOT EXISTS FOR (agent:CSMAgent) REQUIRE agent.id IS UNIQUE;
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
		a.name = csmAgent.payload.csmAgentName,
		a.type = csmAgent.payload.csmAgentType,
		a.bic  = csmAgent.payload.csmAgentBic,
		a.agentId  = csmAgent.payload.csmAgentId
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

//Load CSMParticipants
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/participant')
YIELD value
WITH value.settings as csmParticipants
UNWIND csmParticipants as csmParticipant
	MERGE (p:CSMParticipant{id:csmParticipant.payload.csmParticipantIdentifier})
	ON CREATE SET 
		p.name     = csmParticipant.payload.participantName,
		p.csmAgent = csmParticipant.payload.csmAgentId
	WITH p, csmParticipant
	MATCH (csmAgent:CSMAgent{agentId:csmParticipant.payload.csmAgentId})
	MERGE (p)-[of:PARTICIPANT_OF]->(csmAgent)
		SET of.type = csmParticipant.payload.participantType;
		

	
	