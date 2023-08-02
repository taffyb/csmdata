//
// CYPHER statement to retrieve all possible routes between a source Participant and a target Participant
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




MATCH (source:CSMParticipant{sicBic:$params.sourceBic})
MATCH (target:CSMParticipant{sicBic:$params.targetBic})
MATCH paths=allShortestPaths((source)-[*]-(target))
UNWIND paths as path
WITH source, target, path,
[ n IN nodes(path)  WHERE labels(n)[0]='CSMAgent' ] as csms,
reduce(p=0, x IN [ n IN nodes(path) WHERE NOT (labels(n)[0]='CSMAgent' OR labels(n)[0]='CSMParticipant')]| p+ 1) as not_agent_or_p ,
reduce(p=[], x IN [ n IN nodes(path)  ] | p+ [labels(x)[0]+ "("+CASE WHEN labels(x)[0]='CSMParticipant' THEN x.sicBic WHEN labels(x)[0]='CSMAgent' THEN x.name END+")"]) as node_names,
[ n IN nodes(path)  WHERE labels(n)[0]='CSMAgent' AND (NOT $params.csmSelectionOrder.serviceLevel="INST" OR n.isInstant=true) ] as ip_csms
WITH source, target, path, not_agent_or_p, node_names, csms, ip_csms
CALL {
    WITH source, target, path, not_agent_or_p, node_names, csms, ip_csms
    UNWIND csms as csm
    MATCH (csm)-[s:SUPPORTS]->(cur:Currency{isoCode:$params.csmSelectionOrder.transferCurrency})
    RETURN collect(csm) as cur_csms
}
WITH source, target, path, not_agent_or_p, node_names, csms, ip_csms, cur_csms
//Filter out paths that use non INST CSMs when routing IP 
//  OR include nodes that are not CSMAgents or Financial Institutions
//  OR include CSMAgents that don't support the selected currency
WHERE size(csms)=size(ip_csms) AND size(csms)=size(cur_csms) AND not_agent_or_fi=0
WITH source, target, path, csms, node_names, $params.csmSelectionOrder.csmAgentOptions as csmOrders
// for each csm in the path add the selection order from the passed parameters
UNWIND csms as csm
WITH source, target, path, node_names, reduce(p=0, x IN [ n IN csmOrders WHERE n.csmAgentId=csm.agentId ] | p+ x.order) as csmOrder ,csms
RETURN DISTINCT length(path) as hops ,node_names, csmOrder as order ORDER BY csmOrder