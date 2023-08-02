update  vtigercrm600.vtiger_potential potential
   inner join (select cf_847,potentialid from  vtigercrm600.vtiger_potentialscf ) as pscf
    on pscf.potentialid=potential.potentialid 
    set potential.amount =ifnull(cf_847,0)*1800000
where potential.amount=0
;

-- select * from vtigercrm600.vtiger_potential potential
-- inner join  vtigercrm600.vtiger_potentialscf  as pscf
--    on pscf.potentialid=potential.potentialid 
-- where potential.amount=0;
