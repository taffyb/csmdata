
// OnUs or SIC
:param params =>({processingEntityId:'001', sourceId:"UBSWCHZH93A",  targetId:"UBSWCHZH70A", csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via SIC
:param params =>({processingEntityId:'001', sourceId:"UBSWCHZH80V",  targetId:"SNBZCHZZXXX", , csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via OnUs
:param params =>({processingEntityId:'001',sourceId:"UBSWCHZH83B", targetId:"UBSWCHZH81M",sla:"INST",csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

//via OnUs to SIC participant
:param params =>({processingEntityId:'001',sourceId:"UBSWCHZH83B", targetId:"SNBZCHZZXXX",sla:"INST"}); 

//via OnUs to SIC participant to eurSIC participant(no longer an instant payment)
:param params =>({processingEntityId:'001',sourceId:"UBSWCHZH83B", targetId:"RAIFCH22102",sla:"INST"}); 

:param params =>({csmSelectionOrder:{paymentType: "DMTR", serviceLevel: "INST", transferCurrency: "CHF", csmAgentOptions: [{order: 1,csmAgentId: "UbsCh"},{order: 2,csmAgentId: "SIC"}]}}); 

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