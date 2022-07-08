#!/bin/zsh

#  Created by Markus Schmid on 28.06.22.
#  Updated by Markus Schmid on 08.07.22.
#  Copyright © 2022 Markus Schmid. All rights reserved.

#####################
# ITIS v062822
#####################
declare -A ITIS_1501=(
   ["NR"]=1501
   ["ROOTTAXA"]='50 630578 202423 630577 935939 555705 202422' 
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2022-06-28'
   ["NAME"]='Complete'
   ["DBSOURCEFILE"]='../data/itisPostgreSql062822/ITIS.sql' 
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='220628001' 
   ["TNROFFSET"]=60000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises all taxa from ITIS database, published on 28 June 2022. Retrieved [06, 28, 2022], from the Integrated Taxonomic Information System (ITIS) on-line database, www.itis.gov. https://doi.org/10.5066/F7KH0KBK.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.ITIS_Complete_0622'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)