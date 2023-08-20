MATCH (fi:FinancialInstitution)-[]-(p:CSMParticipant) 
WITH fi, p
ORDER BY p.id
WITH DISTINCT {name:fi.name, bankIdentifier:p.id, country:fi.Country, city:fi.city} as participant
RETURN collect(participant) as participants 