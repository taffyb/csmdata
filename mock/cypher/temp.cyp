
// OnUs or SIC
:param params =>({processingEntityId:'001', sourceBic:"UBSWCHZH93A",  targetBic:"UBSWCHZH70A", csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via SIC
:param params =>({processingEntityId:'001', sourceBic:"UBSWCHZH80V",  targetBic:"SNBZCHZZXXX", , csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via OnUs
:param params =>({processingEntityId:'001',sourceBic:"UBSWCHZH83B", targetBic:"UBSWCHZH81M",sla:"INST",csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via OnUs to SIC participant
:param params =>({processingEntityId:'001',sourceBic:"UBSWCHZH83B", targetBic:"SNBZCHZZXXX",sla:"INST"}); 

//via OnUs to SIC participant to eurSIC participant(no longer an instant payment)
:param params =>({processingEntityId:'001',sourceBic:"UBSWCHZH83B", targetBic:"RAIFCH22102",sla:"INST"}); 

:param params =>({csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 


MATCH (source:FinancialInstitution{sicBic:$params.sourceBic})-[:PARTICIPANT_OF]->(:CSMAgent)<-[:USES]-(:ProcessingEntity{id:$params.processingEntityId})
MATCH (target:FinancialInstitution{sicBic:$params.targetBic})
MATCH paths=allShortestPaths((source)-[*]-(target))
UNWIND paths as path
WITH source, target, path,
reduce(p=0, x IN [ n IN nodes(path) WHERE NOT (labels(n)[0]='CSMAgent' OR labels(n)[0]='FinancialInstitution')]| p+ 1) as not_agent_or_fi ,
reduce(p=[], x IN [ n IN nodes(path)  ] | p+ [labels(x)[0]+ "("+CASE WHEN labels(x)[0]='FinancialInstitution' THEN x.sicBic WHEN labels(x)[0]='CSMAgent' THEN x.name END+")"]) as node_names,
[ n IN nodes(path)  WHERE labels(n)[0]='CSMAgent' ] as csms,
[ n IN nodes(path)  WHERE labels(n)[0]='CSMAgent' AND (NOT $params.csmSelectionOrder.serviceLevel="INST" OR n.isInstant=true) ] as ip_csms
WITH source, target, path, not_agent_or_fi, node_names, csms, ip_csms
CALL {
    WITH source, target, path, not_agent_or_fi, node_names, csms, ip_csms
    UNWIND csms as csm
    MATCH (csm)-[s:SUPPORTS]->(cur:Currency{isoCode:$params.csmSelectionOrder.transferCurrency})
    RETURN collect(csm) as cur_csms
}
WITH source, target, path, not_agent_or_fi, node_names, csms, ip_csms, cur_csms
//Filter out paths that use non INST CSMs when routing IP 
//  OR include nodes that are not CSMAgents or Financial Institutions
//  OR include CSMAgents that don't support the selected currency
WHERE size(csms)=size(ip_csms) AND size(csms)=size(cur_csms) AND not_agent_or_fi=0
WITH source, target, path, csms, node_names, $params.csmSelectionOrder.csmAgentOptions as csmOrders
// for each csm in the path add the selection order from the passed parameters
UNWIND csms as csm
WITH source, target, path, node_names, reduce(p=0, x IN [ n IN csmOrders WHERE n.csmAgentId=csm.agentId ] | p+ x.order) as csmOrder ,csms
RETURN DISTINCT length(path) as hops ,path, csmOrder as order ORDER BY csmOrder
 


================================================
CREATE (a1:A{id:1})
CREATE (a2:A{id:2})
CREATE (a3:A{id:3})
CREATE (b1:B{flag:true})
CREATE (b2:B{flag:true})
CREATE (b3:B{flag:false})
CREATE (a1)-[:LINKS]->(b1)-[:LINKS]->(a2)-[:LINKS]->(b2)-[:LINKS]->(a3)
CREATE (a2)-[:LINKS]->(b3)-[:LINKS]->(a3);

MATCH paths=allShortestPaths((:A{id:1})-[*]-(:A{id:3}))
UNWIND paths as path
WITH path,
reduce(p=[], x IN [ n IN nodes(path) WHERE labels(n)[0]='A' ] | p+ [x.id]) as x,
reduce(p=[], x IN [ n IN nodes(path) WHERE labels(n)[0]='B' ] | p+ [x.flag]) as all_y,
reduce(p=[], x IN [ n IN nodes(path) WHERE labels(n)[0]='B' AND n.flag=true ] | p+ [x.flag]) as true_y
WHERE size(all_y)=size(true_y)
RETURN length(path), x, all_y;

(:A)-[]-(:B{flag:true})-[]-(:A)-[]-(:B{flag:false})-[]-(:A)
(:A)-[]-(:B{flag:true})-[]-(:A)-[]-(:B{flag:true})-[]-(:A)