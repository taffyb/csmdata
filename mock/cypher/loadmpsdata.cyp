
:param auth =>({user:'admin', password:'AgentParticipantData'});

MATCH (n) WHERE n.mpd=true DETACH DELETE n;

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
	SET 
		fi.processingEntity     = "001",
		fi.name     			= FI.`Owner.Name`,
		fi.domicileAddress  	= FI.Address,
		fi.city     			= FI.`Owner.City`,
		fi.postalCode     		= FI.postalCode,
		fi.postalAddress    	= FI.Address,
		fi.country              = FI.Country,
		fi.mpd = true
	WITH fi,FI, CASE WHEN FI.Service="CHI" THEN "CPI" ELSE FI.Service END as service
	MATCH (holder:FinancialInstitution{id:FI.HolderMPDKey})-[:DIRECT]->(p:CSMParticipant)-[:OF]-(a:CSMAgent{agentId:service})	
	WITH fi,p
	MERGE (fi)-[:INDIRECT]->(p);
	
//Load MPD Correspondants 
CALL apoc.load.json('https://'+$auth.user+':'+$auth.password+'@oxiktfha7b.execute-api.eu-west-2.amazonaws.com/default/mpd-correspondant')
YIELD value
WITH value as FIs
UNWIND FIs as FI
	MATCH (owner:FinancialInstitution{id:FI.MPDKey_Owner})
	MATCH (holder:FinancialInstitution{id:FI.MPDKey_Holder})
	MATCH (network:CSMAgent{agentId:"FIN"})
	WITH owner,holder,network
    CREATE (p:CSMParticipant)
		SET p.of="COR",
			p.mpd=true
	WITH owner,holder,p,network
	MERGE (owner)-[:DIRECT]->(p)-[:OF]->(holder)
    MERGE (p)-[:USING]->(network);

// Merge IPF euroSIC and MPD 
MATCH (a1:CSMAgent{agentId:"euroSIC"}),(a2:CSMAgent{agentId:"PCH"})
CALL apoc.refactor.mergeNodes([a1,a2],{}) YIELD node
RETURN node;

MATCH (a:CSMAgent{agentId:"PCH"})
SET a.agentId=a.name;