:param params =>({from:'GB45LMCU60161331926819', to:'IE64BOFI90583812345678', bic:'LOYDGB22TSY'});

MATCH path=(a1:Account{iban:$params.from})-[*]-(a2:Account{iban:$params.to})
// If only one bank in path and it is us the OnUs=TRUE
WITH path, (size([x IN nodes(path) WHERE labels(x)[0]='Bank'])=1 AND any(x in nodes(path) WHERE x.bic=$params.bic)) as onUs
RETURN onUs

:param params =>({source:{identifierType:'iid', id:193},target:{identifierType:'bic', id:'UBSWCHZH81M'},sla:1,currency:'CHF' })	;	   

//OnUs
//sicBic: UBSWCHZH80V
//sicBic: UBSWCHZH12T
//sicBic: UBSWCHZH75A

//SIC5 DIRECT Participant
//sicBic: SNBZCHZZXXX

//euroSIC (only)
//sicBic: RAIFCH22102
//sicBic: SECGDEFFXXX

//Determine the source node
OPTIONAL MATCH (sourceIBAN:ProcessingEntity{iban:$params.source.id}) WHERE $params.source.identifierType ='iban'
OPTIONAL MATCH (sourceIID:ProcessingEntity{iid:$params.source.id}) WHERE $params.source.identifierType = 'iid'
OPTIONAL MATCH (sourceBIC:ProcessingEntity{bic:$params.source.id}) WHERE $params.source.identifierType = 'bic'
//Determine the target node
OPTIONAL MATCH (targetIBAN:ProcessingEntity{iban:$params.target.id}) WHERE $params.target.identifierType ='iban'
OPTIONAL MATCH (targetIID:ProcessingEntity{iid:$params.target.id}) WHERE $params.target.identifierType = 'iid'
OPTIONAL MATCH (targetBIC:ProcessingEntity{bic:$params.target.id}) WHERE $params.target.identifierType = 'bic'
WITH 
CASE
	WHEN $params.source.identifierType ='iban' THEN sourceIBAN
	WHEN $params.source.identifierType = 'iid' THEN sourceIID
	WHEN $params.source.identifierType = 'bic' THEN sourceBIC
END as source,
CASE
	WHEN $params.target.identifierType ='iban' THEN targetIBAN
	WHEN $params.target.identifierType = 'iid' THEN targetIID
	WHEN $params.target.identifierType = 'bic' THEN targetBIC
END as target

//Find all paths from source to target
MATCH paths=(source)-[*]-(target)
UNWIND paths as path
WITH path, 
[ n IN nodes(path)  WHERE labels(n)[0]='CSMAgent' ] as csms, 
[ n IN nodes(path)  WHERE labels(n)[0]='ProcessingEntity' ] as participants, 
[ n IN nodes(path)  WHERE labels(n)[0]='BilateralAgreement' ] as bilateralAgreements, 
[ r IN relationships(path)  WHERE type(r)='OVERRIDES' ] as override
WHERE size(override)<=0 WITH path, reduce(s=[], x IN csms | s + x.name) as csms,
size(participants) as participants, 
reduce(s=[], x IN nodes(path) | s + x.name) as nodes 
WHERE NOT nodes IS NULL 
RETURN DISTINCT length(path),nodes, csms, participants ORDER BY length(path)

//Connected by SIC5 
MATCH (source:FI{BIC:'SNBZCHZZXXX'}), (target:FI{BIC:'UBSWCHZH86N'}) 
MATCH paths=(source)-[*]-(target) 
UNWIND paths as path 
WITH 
	path, 
	[ n IN nodes(path) WHERE labels(n)[0]='CSMAgent' ] as csms, 
	[ n IN nodes(path) WHERE labels(n)[0]='FI' ] as participants 
WHERE length(path)<=6 
RETURN DISTINCT length(path), csms, participants 

//Connected by OnUs 
MATCH (source:FI{BIC:'UBSWCHZH93A'}), (target:FI{BIC:'UBSWCHZH86N'}) 
MATCH paths=(source)-[*]-(target) 
UNWIND paths as path 
WITH 
	path, 
	[x IN [ n IN nodes(path) WHERE labels(n)[0]='CSMAgent' ] | x.name] as csms, 
	[ n IN nodes(path) WHERE labels(n)[0]='FI' ] as participants, 
	reduce(p=0, x IN [ n IN nodes(path) WHERE labels(n)[0]='CSMAgent' ] | p+ x.priority) as priority 
WHERE length(path)<=6 
RETURN DISTINCT length(path)-2, csms, priority , participants 
ORDER BY priority 

MATCH (source:FI{BIC:'BSCHESMM'}), (target:FI{BIC:'ABKSDEFF'}) 
MATCH paths=(source)-[*]-(target) 
UNWIND paths as path 
WITH 
	path, 
	[x IN [ n IN nodes(path) 
WHERE labels(n)[0]='CSMAgent' ] | x.name] as csms, 
[ n IN nodes(path) WHERE labels(n)[0]='FI' ] as participants, 
reduce(p=0, x IN [ n IN nodes(path) WHERE labels(n)[0]='CSMAgent' ] |
 p+ x.priority) as priority
 WHERE length(path)<=6 
 RETURN DISTINCT length(path)-2, csms, priority , participants 
 ORDER BY priority