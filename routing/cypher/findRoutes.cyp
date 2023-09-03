//
// CYPHER statement to retrieve all possible routes between a source  and a target Financial Institution
// It is assumed that prior to calling source and target accounts have been converted into Participant references
//
// Find all paths between source and target
// For each path
//  count the CSMAgents in the path (csms)
//  count nodes that are not either a CSMAgent or CSMParticipant (not_agent_or_p)
//  create an array of node names (node_names)
//  count CSMAgents that support Instant Payments (ip_csms)
//  FILTER out paths where
//    at least on of the CSMAgents in the path do not support the required currency
//    there are any nodes that are not a CSMAgent or CSMParticipant
//    if the payment type has an INST service level the path contains a CSM Agent that does not support IP
// RETURN a list showing 
//   hops       - number of nodes between source and target
//   node_names - description of nodes in the path
// ORDERED BY the provided CSMAgent selection order preference
//

//:param params =>({sourceId:"0008",  targetId:"UBSWCHZH94N"}); 
MATCH (source:FinancialInstitution)-[]->(:CSMParticipant{id:$params.sourceId})
MATCH (target:FinancialInstitution)-[]->(:CSMParticipant{id:$params.targetId})
MATCH paths=allShortestPaths((source)-[*]-(target))
UNWIND paths as path
    WITH path,
        (size([n IN nodes(path) WHERE (labels(n)[0]='Currency' OR labels(n)[0]='ProcessingEntity')])=0) as only_relevant_nodes
    WHERE only_relevant_nodes
    WITH path,
        ("["+reduce(p="", x IN [ n IN nodes(path)  ] | p+ (CASE 
        WHEN labels(x)[0]="CSMParticipant" AND NOT x.id IS NULL THEN labels(x)[0]+"<"+x.id+"> " 
        WHEN labels(x)[0]="CSMParticipant" AND x.id IS NULL THEN labels(x)[0]+"<Cor> " 
        WHEN labels(x)[0]="CSMAgent" THEN labels(x)[0]+"<"+x.name+"> " 
        WHEN labels(x)[0]="FinancialInstitution" THEN "{"+x.name+"} " 
        ELSE "" END))+"]") as node_names
RETURN DISTINCT length(path) as hops, path, node_names