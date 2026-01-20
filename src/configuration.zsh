#!/bin/zsh

#  Created by Markus Schmid on 28.06.22.
#  Updated by Markus Schmid on 31.10.25.
#  Copyright © 2025 Markus Schmid. All rights reserved.

#####################
# ITIS v122325 Complete
#####################

# 202423 Animalia                           
# 202422 Plantae                                                      
# 555705 Fungi                              
# 630577 Protozoa                           
# 630578 Chromista                          
# 50     Bacteria
# 935939 Archaea                            

declare -A ITIS_Complete_122325=(
   ["NR"]=1501
   ["ROOTTAXA"]='50 630578 202423 630577 935939 555705 202422'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2025-12-23'
   ["NAME"]='Complete'
   ["DBSOURCEFILE"]='/home/user/Projekte/gitrepos/sqlite-core-data-creation/origdata/itisPostgreSql122325/ITIS.sql'
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='251223001' 
   ["TNROFFSET"]=60000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises all taxa from ITIS database, published on 23 December 2025. Retrieved [12, 23, 2025], from the Integrated Taxonomic Information System (ITIS) on-line database, www.itis.gov. https://doi.org/10.5066/F7KH0KBK.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.ITIS_Complete_1225'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)

#####################
# ITIS v092425 Complete
#####################

# 202423 Animalia                           
# 202422 Plantae                                                      
# 555705 Fungi                              
# 630577 Protozoa                           
# 630578 Chromista                          
# 50     Bacteria
# 935939 Archaea   

declare -A ITIS_Complete_092425=(
   ["NR"]=1501
   ["ROOTTAXA"]='50 630578 202423 630577 935939 555705 202422'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2025-09-24'
   ["NAME"]='Complete'
   ["DBSOURCEFILE"]='/home/user/Projekte/gitrepos/sqlite-core-data-creation/origdata/itisPostgreSql092425/ITIS.sql'
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

# 174372  Struthioniformes                   
# 174376  Rheiformes                         
# 174382  Casuariiformes                     
# 174391  Apterygiformes                     
# 174397  Tinamiformes                       
# 174442  Sphenisciformes                    
# 174466  Gaviiformes                        
# 174476  Podicipediformes                   
# 174512  Procellariiformes                  
# 174670  Pelecaniformes                     
# 174770  Ciconiiformes                      
# 174982  Anseriformes                       
# 175262  Falconiformes                      
# 175693  Galliformes                        
# 176147  Gruiformes                         
# 176445  Charadriiformes                    
# 177038  Columbiformes                      
# 177404  Psittaciformes                     
# 177816  Cuculiformes                       
# 177848  Strigiformes                       
# 177949  Caprimulgiformes                   
# 177993  Apodiformes                        
# 178091  Coliiformes                        
# 178093  Trogoniformes                      
# 178102  Coraciiformes                      
# 178140  Piciformes                         
# 178265  Passeriformes                      
# 553433  Phoenicopteriformes                
# 553435  Bucerotiformes                     
# 553438  Musophagiformes                    
# 823960  Suliformes                         
# 823961  Accipitriformes                    
# 823962  Phaethontiformes                   
# 914236  Cariamiformes                      
# 914237  Eurypygiformes                     
# 914238  Leptosomiformes                    
# 914239  Mesitornithiformes                 
# 914240  Opisthocomiformes                  
# 914241  Otidiformes                        
# 1077320 Nyctibiiformes                     
# 1077321 Steatornithiformes                 
# 1243700 Pterocliformes                     

declare -A ITIS_Birds=(
   ["NR"]=1502
   ["ROOTTAXA"]='174372 174376 174382 174391 174397 174442 174466 174476 174512 174670 174770 174982 175262 175693 176147 176445 177038 177404 177816 177848 177949 177993 178091 178093 178102 178140 178265 553433 553435 553438 823960 823961 823962 914236 914237 914238 914239 914240 914241 1077320 1077321 1243700'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='ITIS'
   ["PUBLISHED"]='2025-12-23'
   ["NAME"]='Birds'
   ["DBSOURCEFILE"]='/home/user/Projekte/gitrepos/sqlite-core-data-creation/origdata/itisPostgreSql122325/ITIS.sql'
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='251223001' 
   ["TNROFFSET"]=60000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises a birds taxa from ITIS database, published on 23 December 2025. Retrieved [12, 23, 2025], from the Integrated Taxonomic Information System (ITIS) on-line database, www.itis.gov. https://doi.org/10.5066/F7KH0KBK.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.ITIS_Birds_1225'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)

#####################
# GERMANSL v092925
#####################

# 60002 Embryophyta
# 91947 Flechten
# 99000 Algen

declare -A GERMANSL_Complete=(
   ["NR"]=2502
   ["ROOTTAXA"]='91947 60002 99000'
   ["DBHOSTPOSTGRES"]='localhost' 
   ["BACKBONE"]='GERMANSL'
   ["PUBLISHED"]='2025-09-29'
   ["NAME"]='Complete'
   ["DBSOURCEFILE"]='/home/user/Projekte/gitrepos/sqlite-core-data-creation/origdata/GermanSL/GermanSL1.5.6/germansl.sqlite'
   ["DBTARGETFILE"]='../data/SYSTEM.sqlite'
   ["DBCONFIGFILE"]='../data/CONFIG.sqlite'
   ["TARGETVERSION"]='250929001' 
   ["TNROFFSET"]=70000000
   ["NAMELANGS"]='de,en,fr,sci'
   ["NATIVELANG"]='en'
   ["RANKLANGS"]='de,en,sci'
   ["CITATION"]='This database comprises the ''Referenzliste der Pflanzen Deutschlands'', published on 29 September 2025.'
   ["PURCHASEID_RAW"]='com.mascapp.TaxaDB.GERMANSL_0925'
   ["PURCHASECONTENTVERSION"]='1.0'
   ["PURCHASECONTENTFEATURE"]='D'
   ["STATUS"]=771)