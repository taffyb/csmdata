MATCH (csm:CSMAgent) 
WITH {
        agentId:csm.agentId,
        name:csm.name,
        type:csm.type,
        isInstant:csm.isInstant
     } as csmAgent
RETURN collect(csmAgent) as csmAgents