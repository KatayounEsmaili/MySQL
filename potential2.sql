UPDATE vtigercrm600.vtiger_potential as potential 
INNER JOIN (
  SELECT quotes.potentialid, max(quotes.total) as total
  FROM vtigercrm600.vtiger_quotes AS quotes
  
  GROUP BY quotes.potentialid
) AS q ON q.potentialid = potential.potentialid
 SET potential.amount = q.total
  where potential.amount=0
  
  UPDATE vtigercrm600.vtiger_potential as potential 
INNER JOIN (
  SELECT salesorder.potentialid, max(salesorder.total) as total
  FROM vtigercrm600.vtiger_salesorder AS salesorder
  
  GROUP BY salesorder.potentialid
) AS s ON s.potentialid = potential.potentialid
 SET potential.amount = s.total
  where potential.amount=0
  