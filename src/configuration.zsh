#!/bin/zsh

#  Created by Markus Schmid on 28.06.22.
#  Updated by Markus Schmid on 31.10.25.
#  Copyright © 2025 Markus Schmid. All rights reserved.

#####################
# ITIS v092425 Complete
#####################
declare -A ITIS_Complete=(
   ["NR"]=1501
   ["ROOTTAXA"]='50 630578 202423 630577 935939 555705 202422 951423'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2025-09-24'
   ["NAME"]='Complete'
   ["DBSOURCEFILE"]='/mnt/datassd/itisPostgreSql092425/ITIS.sql'
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='250924001' 
   ["TNROFFSET"]=60000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises all taxa from ITIS database, published on 24 September 2025. Retrieved [09, 24, 2025], from the Integrated Taxonomic Information System (ITIS) on-line database, www.itis.gov. https://doi.org/10.5066/F7KH0KBK.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.ITIS_Complete_0925'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)

#####################
# ITIS v092425 Birds
#####################
declare -A ITIS_Birds=(
   ["NR"]=1502
   ["ROOTTAXA"]='174372 174376 174382 174391 174397 174442 174466 174476 174512 174670 174770 174982 175262 175693 176147 176445 177038 177404 177816 177848 177949 177993 178091 178093 178102 178140 178265 553433 553435 553438 823960 823961 823962 914236 914237 914238 914239 914240 914241 1077320 1077321 1243700'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2025-09-24'
   ["NAME"]='Birds'
   ["DBSOURCEFILE"]='/mnt/datassd/itisPostgreSql092425/ITIS.sql'
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='250924001' 
   ["TNROFFSET"]=60000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises a birds taxa from ITIS database, published on 24 September 2025. Retrieved [09, 24, 2025], from the Integrated Taxonomic Information System (ITIS) on-line database, www.itis.gov. https://doi.org/10.5066/F7KH0KBK.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.ITIS_Birds_0925'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)
