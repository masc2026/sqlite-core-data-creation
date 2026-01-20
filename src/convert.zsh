#!/bin/zsh

#  Created by Markus Schmid on 28.06.22.
#  Updated by Markus Schmid on 31.10.25.
#  Copyright © 2025 Markus Schmid. All rights reserved.

# 
# command syntax:
# ./convert.zsh -conf <configuration> -username <username> -password <password>
# 
#####################
# nano ~/.pgpass
# localhost:5432:GERMANSL:<username>:<password>
# localhost:5432:ITIS:<username>:<password>
#####################

zparseopts -D -E -A args conf:: username:: password::

unset MODELVERSION
unset CONFNAME
unset CONF
unset ENT

typeset -A CONF

declare MODELVERSION=61

# ENT
declare -A ENT=(
	["BACKBONE"]=1
	["BOOKMARK"]=2
   ["COLLECTIONVIEW"]=3
	["GENERICLINK"]=4
	["GENERICLINKSET"]=5
	["IMAGE"]=6
	["IMAGEKEYWORD"]=7
	["INFO"]=8
	["LINK"]=9
	["LOCATION"]=10
	["NAMESIDX"]=11
	["OBSERVATION"]=12
	["OWNER"]=13
	["PERSON"]=14
	["RANK"]=15
	["SEARCH"]=16
	["SET"]=17
	["SPEC"]=18
	["SPECDETAIL"]=19
	["SPECINDEX"]=20
	["TRAIT"]=21)

#####################
# ITIS
source configuration.zsh
#####################

#############################
## Level 2                 ##
#############################

#############################
# import function
#############################

function import_germansl_v1 {
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   set client_min_messages = warning;

   DELETE FROM "ZSPEC";

   DELETE FROM "ZRANK";

   ALTER SEQUENCE z_pk_zspec_seq INCREMENT BY 1 RESTART WITH 1;

   ALTER SEQUENCE z_pk_zrank_seq INCREMENT BY 1 RESTART WITH 1;

   INSERT INTO "ZRANK" (ZKINGDOM,ZLEVEL,ZABBREV,ZDE_NAME,ZEN_NAME,ZFR_NAME,ZSCI_NAME) VALUES
   (1,0,  'k1', 'ROOT','ROOT','ROOT','ROOT'),
   (1,10, 'k2', 'AG3','AG3','AG3','AG3'),
   (1,20, 'k3', 'CL1','CL1','CL1','CL1'),
   (1,30, 'k4', 'ABT','ABT','ABT','ABT'),
   (1,40, 'k5', 'UAB','UAB','UAB','UAB'),
   (1,50, 'k6', 'KLA','KLA','KLA','KLA'),
   (1,60, 'k7', 'CL3','CL3','CL3','CL3'),
   (1,70, 'k8', 'CL4','CL4','CL4','CL4'),
   (1,80, 'k9', 'CL5','CL5','CL5','CL5'),
   (1,90, 'k10','ORD','ORD','ORD','ORD'),
   (1,100,'k11','FAM','FAM','FAM','FAM'),
   (1,110,'k12','AG2','AG2','AG2','AG2'),
   (1,120,'k13','SFA','SFA','SFA','SFA'),
   (1,130,'k14','GAT','GAT','GAT','GAT'),
   (1,140,'k15','AG1','AG1','AG1','AG1'),
   (1,150,'k16','SGE','SGE','SGE','SGE'),
   (1,160,'k17','SEC','SEC','SEC','SEC'),
   (1,170,'k18','AGG','AGG','AGG','AGG'),
   (1,180,'k19','SER','SER','SER','SER'),
   (1,190,'k20','SSE','SSE','SSE','SSE'),
   (1,200,'k21','SPE','SPE','SPE','SPE'),
   (1,210,'k22','SSP','SSP','SSP','SSP'),
   (1,220,'k23','VAR','VAR','VAR','VAR');

   UPDATE "germansl" AS s SET taxonrank = t.ZABBREV FROM "ZRANK" AS t WHERE trim(s.taxonrank) = trim(t.ZSCI_NAME);

   INSERT INTO "ZPERSON" (ZSHORTAUTHOR) select distinct(nameauthor) as zshortauthor from germansl where synonym = 0 and length(nameauthor)>1;

   INSERT INTO "ZSPEC" (ZNR,ZSCI_NAME,X_IS_SYNONYM,ZDE_NAME,ZRANK) select taxonusageid,taxonname,synonym,vernacularname,taxonrank from germansl;

   UPDATE "ZSPEC" SET ZAGGS = aggregatesConcatOfAggsNrBytaxonusageid(ZNR), ZAGGSRANKS = aggregatesConcatOftaxonranksNrBytaxonusageid(ZNR) WHERE X_IS_SYNONYM=0;

   UPDATE "ZSPEC" SET ZCHILDS = aggregatesConcatOfChildsNrBytaxonusageid(ZNR) WHERE X_IS_SYNONYM=0;

   UPDATE "ZSPEC" SET ZSYNONYMS = aggregatesConcatOfsynonymsNrBytaxonusageid(ZNR) WHERE X_IS_SYNONYM=0;

   UPDATE "ZSPEC" AS s SET ZVALID_NR = t.taxonconceptid FROM germansl AS t WHERE s.ZNR = t.taxonusageid and s.X_IS_SYNONYM=1;

   UPDATE "ZSPEC" SET ZDE_NAME = '' WHERE ZDE_NAME is NULL;

   UPDATE "ZSPEC" SET ZAGGS = '' WHERE ZAGGS is NULL;

   UPDATE "ZSPEC" SET ZAGGSRANKS = '' WHERE ZAGGSRANKS is NULL;
   
   UPDATE "ZSPEC" SET ZRANK = '' WHERE ZRANK is NULL;

   UPDATE "ZSPEC" SET ZCHILDS = '' WHERE ZCHILDS is NULL;

   UPDATE "ZSPEC" SET ZSYNONYMS = '' WHERE ZSYNONYMS is NULL;

   UPDATE "ZSPEC" AS s SET ZAUTHOR = p.Z_PK FROM "ZPERSON" AS p WHERE s.X_IS_SYNONYM=0 and p.ZSHORTAUTHOR = (SELECT g.nameauthor FROM germansl AS g where g.taxonusageid = s.ZNR and length(g.nameauthor)>1);

   UPDATE "ZRANK" SET ZDE_NAME='ROOT'           , ZSCI_NAME='ROOT'          , ZEN_NAME='ROOT'             , ZICON='ROOT'     where ZABBREV='k1';
   UPDATE "ZRANK" SET ZDE_NAME='Unterreich'     , ZSCI_NAME='Subregna'      , ZEN_NAME='Subkingdom'       , ZICON='AG3'      where ZABBREV='k2'; 
   UPDATE "ZRANK" SET ZDE_NAME='Unranked (CL1)' , ZSCI_NAME='Unranked (CL1)', ZEN_NAME='Unranked (CL1)'   , ZICON='CL1'      where ZABBREV='k3'; 
   UPDATE "ZRANK" SET ZDE_NAME='Abteilung'      , ZSCI_NAME='Divisio'       , ZEN_NAME='Division'         , ZICON='ABT'      where ZABBREV='k4'; 
   UPDATE "ZRANK" SET ZDE_NAME='Unterabteilung' , ZSCI_NAME='Subdivisio'    , ZEN_NAME='Subdivision'      , ZICON='UAB'      where ZABBREV='k5'; 
   UPDATE "ZRANK" SET ZDE_NAME='Klasse'         , ZSCI_NAME='Classis'       , ZEN_NAME='Class'            , ZICON='KLA'      where ZABBREV='k6'; 
   UPDATE "ZRANK" SET ZDE_NAME='Unranked (CL3)' , ZSCI_NAME='Unranked (CL3)', ZEN_NAME='Unranked (CL3)'   , ZICON='CL3'      where ZABBREV='k7'; 
   UPDATE "ZRANK" SET ZDE_NAME='Unranked (CL4)' , ZSCI_NAME='Unranked (CL4)', ZEN_NAME='Unranked (CL4)'   , ZICON='CL4'      where ZABBREV='k8'; 
   UPDATE "ZRANK" SET ZDE_NAME='Unranked (CL5)' , ZSCI_NAME='Unranked (CL5)', ZEN_NAME='Unranked (CL5)'   , ZICON='CL5'      where ZABBREV='k9'; 
   UPDATE "ZRANK" SET ZDE_NAME='Ordnung'        , ZSCI_NAME='Ordo'          , ZEN_NAME='Order'            , ZICON='ORD'      where ZABBREV='k10';
   UPDATE "ZRANK" SET ZDE_NAME='Familie'        , ZSCI_NAME='Familia'       , ZEN_NAME='Family'           , ZICON='FAM'      where ZABBREV='k11';
   UPDATE "ZRANK" SET ZDE_NAME='Großgruppe'     , ZSCI_NAME='Subregna'      , ZEN_NAME='Subkingdom'       , ZICON='AG2'      where ZABBREV='k12';
   UPDATE "ZRANK" SET ZDE_NAME='Unterfamilie'   , ZSCI_NAME='Subfamilia'    , ZEN_NAME='Subfamily'        , ZICON='SFA'      where ZABBREV='k13';
   UPDATE "ZRANK" SET ZDE_NAME='Gattung'        , ZSCI_NAME='Genus'         , ZEN_NAME='Genus'            , ZICON='GAT'      where ZABBREV='k14';
   UPDATE "ZRANK" SET ZDE_NAME='Gattung (AG1)'  , ZSCI_NAME='Genus (AG1)'   , ZEN_NAME='Genus (AG1)'      , ZICON='AG1'      where ZABBREV='k15';
   UPDATE "ZRANK" SET ZDE_NAME='Untergattung'   , ZSCI_NAME='Subgenus'      , ZEN_NAME='Subgenus'         , ZICON='SGE'      where ZABBREV='k16';
   UPDATE "ZRANK" SET ZDE_NAME='Sektion'        , ZSCI_NAME='Sectioni'      , ZEN_NAME='Section'          , ZICON='SEC'      where ZABBREV='k17';
   UPDATE "ZRANK" SET ZDE_NAME='Artengruppe'    , ZSCI_NAME='Aggregatum'    , ZEN_NAME='Species complex'  , ZICON='AGG'      where ZABBREV='k18';
   UPDATE "ZRANK" SET ZDE_NAME='Serie'          , ZSCI_NAME='Seriem'        , ZEN_NAME='Series'           , ZICON='SER'      where ZABBREV='k19';
   UPDATE "ZRANK" SET ZDE_NAME='Untersektion'   , ZSCI_NAME='Subsectio'     , ZEN_NAME='Subsection'       , ZICON='SSE'      where ZABBREV='k20';
   UPDATE "ZRANK" SET ZDE_NAME='Art'            , ZSCI_NAME='Species'       , ZEN_NAME='Species'          , ZICON='SPE'      where ZABBREV='k21';
   UPDATE "ZRANK" SET ZDE_NAME='Unterart'       , ZSCI_NAME='Subspecies'    , ZEN_NAME='Subspecies'       , ZICON='SSP'      where ZABBREV='k22';
   UPDATE "ZRANK" SET ZDE_NAME='Varietät'       , ZSCI_NAME='Varietas'      , ZEN_NAME='Variety'          , ZICON='VAR'      where ZABBREV='k23';
EOF
}

function import_itis_v1 {
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   set client_min_messages = warning;

   DROP EXTENSION IF EXISTS pg_trgm CASCADE;

   DROP INDEX IF EXISTS ZSPEC_ZAUTHOR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_GIN_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZVALID_NR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZNR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZRANK_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSCI_NAME_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSTATUS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_X_IS_SYNONYM_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERNLEN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZSPECNRCOUNT_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZLEN_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZPATTERN_INDEX;

   DROP INDEX IF EXISTS ZPERSON_X_TSN_INDEX;

   DROP TABLE IF EXISTS "ZSPEC" CASCADE;

   DROP TABLE IF EXISTS "ZRANK" CASCADE;

   DROP TABLE IF EXISTS "ZNAMESIDX" CASCADE;

   DROP TABLE IF EXISTS "ZSPECINDEX" CASCADE;

   DROP TABLE IF EXISTS "ZPERSON" CASCADE;

   DROP SEQUENCE IF EXISTS z_pk_zspec_seq;

   DROP SEQUENCE IF EXISTS z_pk_zrank_seq;

   DROP SEQUENCE IF EXISTS z_pk_znamesidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zpersonidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zspecindexidx_seq;

   CREATE EXTENSION pg_trgm;

   CREATE SEQUENCE z_pk_zspec_seq;

   CREATE SEQUENCE z_pk_zrank_seq;

   CREATE SEQUENCE z_pk_znamesidx_seq;

   CREATE SEQUENCE z_pk_zpersonidx_seq;

   CREATE SEQUENCE z_pk_zspecindexidx_seq;

   CREATE TABLE "ZSPEC" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspec_seq'), 
      Z_ENT INTEGER DEFAULT 18, 
      Z_OPT INTEGER DEFAULT 0,
      X_IS_SYNONYM INTEGER DEFAULT 0,
      X_KINGDOM INTEGER DEFAULT 0,
      ZICON INTEGER DEFAULT 0,
      ZNR INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZVALID_NR INTEGER DEFAULT 0,
      ZAUTHOR INTEGER DEFAULT -1,
      ZGEOGRAPHIC INTEGER DEFAULT 0,
      ZAGGS VARCHAR DEFAULT '',
      ZAGGSRANKS VARCHAR DEFAULT '',
      ZATTRIBUTES VARCHAR DEFAULT '',
      ZCHILDS VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZIMAGES VARCHAR DEFAULT '',
      ZINFO VARCHAR DEFAULT '',
      ZRANK VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR DEFAULT '',
      ZSYNONYMS VARCHAR DEFAULT '',
      ZUUID VARCHAR DEFAULT '' );

   CREATE TABLE "ZRANK" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zrank_seq'), 
      Z_ENT INTEGER DEFAULT 15, 
      Z_OPT INTEGER DEFAULT 0,
      ZKINGDOM INTEGER DEFAULT 0,
      ZLEVEL INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZABBREV VARCHAR DEFAULT '',
      ZCOLOR VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZICON VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR );

   CREATE TABLE "ZSPECINDEX" (
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspecindexidx_seq'), 
      Z_ENT INTEGER DEFAULT 20, 
      Z_OPT INTEGER DEFAULT 0,
      ZBBNR INTEGER DEFAULT 0, 
      ZCOLUMN INTEGER DEFAULT 0, 
      ZLEN INTEGER DEFAULT 0, 
      ZNR INTEGER DEFAULT 0, 
      ZPOS INTEGER DEFAULT 0, 
      ZSPECNR INTEGER DEFAULT 0, 
      ZPATTERN VARCHAR DEFAULT '' );

   CREATE TABLE "ZNAMESIDX" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_znamesidx_seq'), 
      Z_ENT INTEGER DEFAULT 11, 
      Z_OPT INTEGER DEFAULT 0,
      ZTYPE INTEGER DEFAULT 1,
      ZPATTERN VARCHAR DEFAULT '',
      ZPATTERNLEN INTEGER DEFAULT 0,
      ZSPECNR VARCHAR DEFAULT '',
      ZSPECNRCOUNT INTEGER DEFAULT 0 );

   CREATE TABLE "ZPERSON" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zpersonidx_seq'), 
      Z_ENT INTEGER DEFAULT 14, 
      Z_OPT INTEGER DEFAULT 0,
      X_TSN INTEGER DEFAULT -1,
      ZLANGUAGE INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT -1,
      ZYEAR TIMESTAMP, 
      ZADDRESS VARCHAR DEFAULT '', 
      ZCITEDLONG VARCHAR DEFAULT '', 
      ZCOUNTRY VARCHAR DEFAULT '', 
      ZEMAIL VARCHAR DEFAULT '', 
      ZFIRSTNAME VARCHAR DEFAULT '', 
      ZGENDER VARCHAR DEFAULT '', 
      ZINSTITUTION VARCHAR DEFAULT '', 
      ZLASTNAME VARCHAR DEFAULT '', 
      ZMD VARCHAR DEFAULT '', 
      ZNAME VARCHAR DEFAULT '', 
      ZNOTES VARCHAR DEFAULT '', 
      ZSHORTAUTHOR VARCHAR DEFAULT '', 
      ZTEL VARCHAR DEFAULT '', 
      ZTITLE VARCHAR DEFAULT '' );

   CREATE INDEX ZSPEC_ZAGGS_GIN_INDEX ON "ZSPEC" USING gin (ZAGGS gin_trgm_ops);

   CREATE INDEX ZSPEC_ZAUTHOR_INDEX ON "ZSPEC" (ZAUTHOR);

   CREATE INDEX ZSPEC_ZAGGS_INDEX ON "ZSPEC" (ZAGGS);

   CREATE INDEX ZSPEC_ZVALID_NR_INDEX ON "ZSPEC" (ZVALID_NR);

   CREATE INDEX ZSPEC_ZNR_INDEX ON "ZSPEC" (ZNR);

   CREATE INDEX ZSPEC_ZRANK_INDEX ON "ZSPEC" (ZRANK);

   CREATE INDEX ZSPEC_ZSCI_NAME_INDEX ON "ZSPEC" (ZSCI_NAME);

   CREATE INDEX ZSPEC_ZSTATUS_INDEX ON "ZSPEC" (ZSTATUS);

   CREATE INDEX ZSPEC_X_IS_SYNONYM_INDEX ON "ZSPEC" (X_IS_SYNONYM);

   CREATE INDEX ZNAMESIDX_ZPATTERN_INDEX ON "ZNAMESIDX" (ZPATTERN);

   CREATE INDEX ZNAMESIDX_ZPATTERNLEN_INDEX ON "ZNAMESIDX" (ZPATTERNLEN);

   CREATE INDEX ZNAMESIDX_ZSPECNRCOUNT_INDEX ON "ZNAMESIDX" (ZSPECNRCOUNT);

   CREATE INDEX ZSPECINDEX_ZLEN_INDEX ON "ZSPECINDEX" (ZLEN);

   CREATE INDEX ZSPECINDEX_ZPATTERN_INDEX ON "ZSPECINDEX" (ZPATTERN);

   CREATE INDEX ZPERSON_X_TSN_INDEX ON "ZPERSON" (X_TSN);

   INSERT INTO "ZPERSON" (ZSHORTAUTHOR,X_TSN) select short_author,taxon_author_id from taxon_authors_lkp;

   INSERT INTO "ZSPEC" (ZNR,ZSCI_NAME,X_KINGDOM,ZAUTHOR) select tsn,complete_name,kingdom_id,taxon_author_id from taxonomic_units as t1 WHERE (t1.unaccept_reason not in ('junior homonym','invalidly published, nomen nudum','original name/combination','pro parte','horticultural','unnecessary replacement','orthographic variant (misspelling)','subsequent name/combination','junior synonym','nomen dubium','unavailable, incorrect orig. spelling','invalidly published, other','rejected name','nomen oblitum','misapplied','unjustified emendation','homonym & junior synonym','superfluous renaming (illegitimate)','synonym','homonym (illegitimate)') or t1.unaccept_reason is NULL);

   UPDATE "ZSPEC" AS s SET ZRANK = t2.kingdom_id || 'x' || t2.rank_id  FROM taxonomic_units t1, taxon_unit_types t2 WHERE t1.tsn = s.ZNR AND s.X_KINGDOM=t1.kingdom_id AND t1.kingdom_id=t2.kingdom_id and t1.rank_id=t2.rank_id;

   UPDATE "ZSPEC" AS s SET ZAUTHOR = (select Z_PK FROM "ZPERSON" AS p WHERE p.X_TSN = s.ZAUTHOR);

   UPDATE "ZSPEC" AS s SET ZEN_NAME = (select string_agg(t1.vernacular_name,'|') FROM vernaculars t1 WHERE t1.tsn = s.ZNR AND (t1.language='English'));

   UPDATE "ZSPEC" AS s SET ZFR_NAME = (select string_agg(t1.vernacular_name,'|') FROM vernaculars t1 WHERE t1.tsn = s.ZNR AND (t1.language='French'));

   UPDATE "ZSPEC" AS s SET ZDE_NAME = (select string_agg(t1.vernacular_name,'|') FROM vernaculars t1 WHERE t1.tsn = s.ZNR AND (t1.language='German'));

   UPDATE "ZSPEC" SET ZEN_NAME='' WHERE ZEN_NAME IS NULL;

   UPDATE "ZSPEC" SET ZFR_NAME='' WHERE ZFR_NAME IS NULL;

   UPDATE "ZSPEC" SET ZDE_NAME='' WHERE ZDE_NAME IS NULL;

   UPDATE "ZSPEC" AS s SET ZVALID_NR = t1.tsn_accepted FROM synonym_links t1 WHERE t1.tsn = s.ZNR;

   UPDATE "ZSPEC" AS s SET X_IS_SYNONYM = 1 FROM synonym_links t1 WHERE t1.tsn = s.ZNR;

   UPDATE "ZSPEC" AS s1 SET ZCHILDS = (SELECT string_agg(CAST(tsn AS text),'|') FROM hierarchy where parent_tsn = s1.ZNR) WHERE s1.X_IS_SYNONYM=0;

   UPDATE "ZSPEC" AS s1 SET ZSYNONYMS = (SELECT string_agg(CAST(s2.ZNR AS text),'|') FROM "ZSPEC" s2 where s2.ZVALID_NR>0 and s2.ZVALID_NR = s1.ZNR) WHERE s1.X_IS_SYNONYM=0;

   UPDATE "ZSPEC" set ZRANK = '' WHERE X_IS_SYNONYM=1;

   UPDATE "ZSPEC" SET ZCHILDS = '' WHERE ZCHILDS is NULL;

   UPDATE "ZSPEC" SET ZSYNONYMS = '' WHERE ZSYNONYMS is NULL;

EOF

      python3 - <<EOF
from migrate import psycopg2
try:
    handle = psycopg2.connect("dbname='$CONF[BACKBONE]' user='$CONF[USERNAMEPOSTGRES]' host='$CONF[DBHOSTPOSTGRES]' password='$CONF[PASSWORDPOSTGRES]'")
    cursor = handle.cursor()
    index = 50
    limit = 1300000
    while (index <= limit):
        min = index;
        if (index+100 > limit):
            max = limit
        else:
            max = index + 10000
        sql='select * from aggsupdateV02(%d,%d)' % (min, max)
        print('Process %s ...' % (sql))
        cursor.execute(sql)
        handle.commit()
        print('... finished !')
        index=index+10000+1
except:
    print('ZAGGS update failed')
EOF

   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   UPDATE "ZSPEC" SET ZAGGS = '' WHERE ZAGGS is NULL;
   INSERT INTO "ZRANK" (ZKINGDOM,ZLEVEL,ZABBREV,ZEN_NAME) select kingdom_id,rank_id,kingdom_id || 'x' || rank_id,rank_name from taxon_unit_types;
   UPDATE "ZRANK" SET ZDE_NAME='Reich',ZSCI_NAME='Regnum' where ZEN_NAME='Kingdom';
   UPDATE "ZRANK" SET ZDE_NAME='Unterreich',ZSCI_NAME='Subregnum' where ZEN_NAME='Subkingdom';
   UPDATE "ZRANK" SET ZDE_NAME='Teilreich',ZSCI_NAME='Infraregnum' where ZEN_NAME='Infrakingdom';
   UPDATE "ZRANK" SET ZDE_NAME='Stammgruppe',ZSCI_NAME='Superphylum' where ZEN_NAME='Superphylum';
   UPDATE "ZRANK" SET ZDE_NAME='Stamm',ZSCI_NAME='Phylum' where ZEN_NAME='Phylum';
   UPDATE "ZRANK" SET ZDE_NAME='Unterstamm',ZSCI_NAME='Subphylum' where ZEN_NAME='Subphylum';
   UPDATE "ZRANK" SET ZDE_NAME='Teilstamm',ZSCI_NAME='Infraphylum' where ZEN_NAME='Infraphylum';
   UPDATE "ZRANK" SET ZDE_NAME='Überklasse',ZSCI_NAME='Superclassis' where ZEN_NAME='Superclass';
   UPDATE "ZRANK" SET ZDE_NAME='Klasse',ZSCI_NAME='Classis' where ZEN_NAME='Class';
   UPDATE "ZRANK" SET ZDE_NAME='Unterklasse',ZSCI_NAME='Subclassis' where ZEN_NAME='Subclass';
   UPDATE "ZRANK" SET ZDE_NAME='Teilklasse',ZSCI_NAME='Infraclassis' where ZEN_NAME='Infraclass';
   UPDATE "ZRANK" SET ZDE_NAME='Überordnung',ZSCI_NAME='Superordo' where ZEN_NAME='Superorder';
   UPDATE "ZRANK" SET ZDE_NAME='Ordnung',ZSCI_NAME='Ordo' where ZEN_NAME='Order';
   UPDATE "ZRANK" SET ZDE_NAME='Unterordnung',ZSCI_NAME='Subordo' where ZEN_NAME='Suborder';
   UPDATE "ZRANK" SET ZDE_NAME='Teilordnung',ZSCI_NAME='Infraordo' where ZEN_NAME='Infraorder';
   UPDATE "ZRANK" SET ZDE_NAME='Sektion',ZSCI_NAME='Sectio' where ZEN_NAME='Section';
   UPDATE "ZRANK" SET ZDE_NAME='Untersektion',ZSCI_NAME='Subsectio' where ZEN_NAME='Subsection';
   UPDATE "ZRANK" SET ZDE_NAME='Überfamilie',ZSCI_NAME='Superfamilia' where ZEN_NAME='Superfamily';
   UPDATE "ZRANK" SET ZDE_NAME='Familie',ZSCI_NAME='Familia' where ZEN_NAME='Family';
   UPDATE "ZRANK" SET ZDE_NAME='Unterfamilie',ZSCI_NAME='Subfamilia' where ZEN_NAME='Subfamily';
   UPDATE "ZRANK" SET ZDE_NAME='Stamm',ZSCI_NAME='Tribus' where ZEN_NAME='Tribe';
   UPDATE "ZRANK" SET ZDE_NAME='Unterstamm',ZSCI_NAME='Subtribus' where ZEN_NAME='Subtribe';
   UPDATE "ZRANK" SET ZDE_NAME='Gattung',ZSCI_NAME='Genus' where ZEN_NAME='Genus';
   UPDATE "ZRANK" SET ZDE_NAME='Untergattung',ZSCI_NAME='Subgenus' where ZEN_NAME='Subgenus';
   UPDATE "ZRANK" SET ZDE_NAME='Art',ZSCI_NAME='Species' where ZEN_NAME='Species';
   UPDATE "ZRANK" SET ZDE_NAME='Unterart',ZSCI_NAME='Subspecies' where ZEN_NAME='Subspecies';
   UPDATE "ZRANK" SET ZDE_NAME='Variante',ZSCI_NAME='Varietas' where ZEN_NAME='Variety';
   UPDATE "ZRANK" SET ZDE_NAME='Untervariante',ZSCI_NAME='Subvarietas' where ZEN_NAME='Subvariety';
   UPDATE "ZRANK" SET ZDE_NAME='Form',ZSCI_NAME='Forma' where ZEN_NAME='Form';
   UPDATE "ZRANK" SET ZDE_NAME='Unterform',ZSCI_NAME='Subforma' where ZEN_NAME='Subform';
   UPDATE "ZRANK" SET ZDE_NAME='Rasse',ZSCI_NAME='Race (EN)' where ZEN_NAME='Race';
   UPDATE "ZRANK" SET ZDE_NAME='Stirp (EN)',ZSCI_NAME='Stirp (EN)' where ZEN_NAME='Stirp';
   UPDATE "ZRANK" SET ZDE_NAME='Aberration (EN)',ZSCI_NAME='Aberration (EN)' where ZEN_NAME='Aberration';
   UPDATE "ZRANK" SET ZDE_NAME='Morph (EN)',ZSCI_NAME='Morph (EN)' where ZEN_NAME='Morph';
   UPDATE "ZRANK" SET ZDE_NAME='Unspecified (EN)',ZSCI_NAME='Unspecified (EN)' where ZEN_NAME='Unspecified';
   UPDATE "ZRANK" SET ZDE_NAME='Überabteilung',ZSCI_NAME='Superdivisio' where ZEN_NAME='Superdivision';
   UPDATE "ZRANK" SET ZDE_NAME='Abteilung',ZSCI_NAME='Divisio' where ZEN_NAME='Division';
   UPDATE "ZRANK" SET ZDE_NAME='Unterabteilung',ZSCI_NAME='Subordo' where ZEN_NAME='Subdivision';
   UPDATE "ZRANK" SET ZDE_NAME='Teilabteilung',ZSCI_NAME='Infraordo' where ZEN_NAME='Infradivision';
   UPDATE "ZRANK" SET ZDE_NAME='Parvdivision (EN)',ZSCI_NAME='Parvdivision (EN)' where ZEN_NAME='Parvdivision';
   UPDATE "ZRANK" SET ZDE_NAME='Parvphylum (EN)',ZSCI_NAME='Parvphylum (EN)' where ZEN_NAME='Parvphylum';
EOF
}

#############################
# info function
#############################

function info_germansl_v1 {
      python3 - <<EOT
from migrate import updateInfo, openPG
handle=openPG('$CONF[DBHOSTPOSTGRES]','$CONF[BACKBONE]','$CONF[USERNAMEPOSTGRES]','$CONF[PASSWORDPOSTGRES]')
updateInfo(handle,0)
EOT
}

function info_itis_v1 {
   echo "Import data to interims tables"
      python3 - <<EOT
from migrate import updateInfo, openPG
handle=openPG('$CONF[DBHOSTPOSTGRES]','$CONF[BACKBONE]','$CONF[USERNAMEPOSTGRES]','$CONF[PASSWORDPOSTGRES]')
updateInfo(handle,0)
EOT
}

#############################
# export function
#############################

function prepare_exporttoappdb_germansl_v2 {
    # GermanSL hat eine ZNR == 0

   local roottaxa=""
   if [[ ! -z $CONF[ROOTTAXA] ]] 
   then
      roottaxa=$CONF[ROOTTAXA]
   else
      roottaxa=$(sqlite3 "$CONF[ROOTDB]" "select zchilds from ZSPEC where zsci_name='"$CONF[ROOTTAXANAME]"';" ".exit")
      roottaxa=${roottaxa//|/ }
      tmp=${roottaxa#" "}
      roottaxa=${tmp%" "}
   fi
   roottaxa=("${(@s/ /)roottaxa}")
   local roottaxa_strA='|'${(j:|:)roottaxa}'|'
   local roottaxa_strB='(0,'${(j:,:)roottaxa}')'
  
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOT
   set client_min_messages = warning;
   DELETE FROM "ZSPEC" WHERE x_is_synonym=1;
   ALTER TABLE "ZSPEC" DROP COLUMN x_is_synonym;
   ALTER TABLE "ZSPEC" DROP COLUMN x_kingdom;
   UPDATE "ZSPEC" SET ZAGGS = '|' || ZAGGS || '|' WHERE NOT ZAGGS = '';
   UPDATE "ZSPEC" SET ZCHILDS = '|' || ZCHILDS || '|' WHERE NOT ZCHILDS = '';
   DELETE FROM "ZSPEC" WHERE ZNR = 0;
   INSERT INTO "ZSPEC" (ZNR,ZAGGS,ZCHILDS,ZSCI_NAME) VALUES (0,'|0|','$roottaxa_strA','ROOT');
   UPDATE "ZSPEC" SET ZAGGS = '|0|' WHERE ZNR in $roottaxa_strB;
   UPDATE "ZSPEC" SET ZAGGS = ZAGGS || '0|' WHERE NOT ZNR in $roottaxa_strB;
   UPDATE "ZSPEC" SET ZSYNONYMS = '';
   ALTER TABLE "ZNAMESIDX" DROP COLUMN zpatternlen;
   ALTER TABLE "ZNAMESIDX" DROP COLUMN zspecnrcount;
   ALTER SEQUENCE z_pk_zspec_seq INCREMENT BY 1 RESTART WITH 100000000;
   REINDEX INDEX "ZSPEC_pkey";
   UPDATE "ZSPEC" SET z_pk=nextval('z_pk_zspec_seq');
   ALTER SEQUENCE z_pk_zspec_seq INCREMENT BY 1 RESTART WITH 1;
   UPDATE "ZSPEC" SET z_pk=$CONF[TNROFFSET]+znr;
   REINDEX INDEX "ZSPEC_pkey";
   DELETE FROM "ZPERSON" WHERE NOT EXISTS (SELECT 1 FROM "ZSPEC" WHERE "ZPERSON".Z_PK  = "ZSPEC".ZAUTHOR);
   ALTER TABLE "ZPERSON" DROP COLUMN x_tsn;
EOT
}

function prepare_exporttoappdb_itis_v1 {
   # ITIS hat keine ZNR == 0

   local roottaxa=""
   if [[ ! -z $CONF[ROOTTAXA] ]] 
   then
      roottaxa=$CONF[ROOTTAXA]
   else
      roottaxa=$(sqlite3 "$CONF[ROOTDB]" "select zchilds from ZSPEC where zsci_name='"$CONF[ROOTTAXANAME]"';" ".exit")
      roottaxa=${roottaxa//|/ }
      tmp=${roottaxa#" "}
      roottaxa=${tmp%" "}
   fi
   roottaxa=("${(@s/ /)roottaxa}")
   local roottaxa_strA='|'${(j:|:)roottaxa}'|'
   local roottaxa_strB='(0,'${(j:,:)roottaxa}')'
   
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   set client_min_messages = warning;
   DELETE FROM "ZSPEC" WHERE ZNR=0;
   DELETE FROM "ZSPEC" WHERE x_is_synonym=1;
   ALTER TABLE "ZSPEC" DROP COLUMN x_is_synonym;
   ALTER TABLE "ZSPEC" DROP COLUMN x_kingdom;
   UPDATE "ZSPEC" SET ZAGGS = '|' || ZAGGS || '|' WHERE NOT ZAGGS = '';
   UPDATE "ZSPEC" SET ZCHILDS = '|' || ZCHILDS || '|' WHERE NOT ZCHILDS = '';
   INSERT INTO "ZSPEC" (Z_PK,ZNR,ZAGGS,ZCHILDS,ZSCI_NAME) VALUES ($CONF[TNROFFSET],0,'','$roottaxa_strA','ROOT');
   UPDATE "ZSPEC" SET ZAGGS = '|0|' WHERE ZNR in $roottaxa_strB;
   UPDATE "ZSPEC" SET ZAGGS = ZAGGS || '0|' WHERE NOT ZNR in $roottaxa_strB;
   UPDATE "ZSPEC" SET ZSYNONYMS = '';
   UPDATE "ZSPEC" SET ZEN_NAME=trim(split_part(ZEN_NAME,'|',1));
   UPDATE "ZSPEC" SET ZFR_NAME=trim(split_part(ZFR_NAME,'|',1));
   UPDATE "ZSPEC" SET ZDE_NAME=trim(split_part(ZDE_NAME,'|',1));
   ALTER TABLE "ZNAMESIDX" DROP COLUMN zpatternlen;
   ALTER TABLE "ZNAMESIDX" DROP COLUMN zspecnrcount;
   ALTER SEQUENCE z_pk_zspec_seq INCREMENT BY 1 RESTART WITH 100000000;
   REINDEX INDEX "ZSPEC_pkey";
   UPDATE "ZSPEC" SET z_pk=nextval('z_pk_zspec_seq');
   ALTER SEQUENCE z_pk_zspec_seq INCREMENT BY 1 RESTART WITH 1;
   UPDATE "ZSPEC" SET z_pk=$CONF[TNROFFSET]+znr;
   REINDEX INDEX "ZSPEC_pkey";
   DELETE FROM "ZPERSON" WHERE NOT EXISTS (SELECT 1 FROM "ZSPEC" WHERE "ZPERSON".Z_PK  = "ZSPEC".ZAUTHOR);
   ALTER TABLE "ZPERSON" DROP COLUMN x_tsn;
EOF
}

function rawimport_germansl_v1 {
   readonly file=${1:?"For GERMANSL import the DB filenname must be specified"}
   echo "Importing data into Postgres"
   
   echo "Create SQLite dump file"

   rm -f GERMANSL.tmp.sql

   sqlite3 $file .dump > GERMANSL.tmp.sql

   sed -i '/PRAGMA/d' GERMANSL.tmp.sql

   sed -i '/sqlite_sequence/d ; s/integer PRIMARY KEY AUTOINCREMENT/serial PRIMARY KEY/ig' GERMANSL.tmp.sql

   sed -i 's/`//g' GERMANSL.tmp.sql

   sed -i 's/IsChildTaxonOfID TEXT/IsChildTaxonOfID INTEGER/g' GERMANSL.tmp.sql

   sed  -i '/BEGIN TRANSACTION;/a \\nDROP TABLE IF EXISTS GermanSL CASCADE;\n\nDROP TABLE IF EXISTS Version CASCADE;\n' GERMANSL.tmp.sql

   sed -i '/BEGIN TRANSACTION/i DROP DATABASE IF EXISTS "GERMANSL";\n\nCREATE DATABASE "GERMANSL" WITH TEMPLATE = template0 ENCODING = "UTF8" LC_COLLATE = "de_DE.UTF-8" LC_CTYPE = "de_DE.UTF-8";\n\n\\connect "GERMANSL"\n' GERMANSL.tmp.sql

   # sed -i '0,/INSERT INTO GermanSL/s/INSERT INTO GermanSL/\nCOPY GermanSL (TaxonUsageID,TaxonName.NameAuthor,SYNONYM,TaxonConceptID,TaxonConcept,VernacularName,TaxonRank,GRUPPE,IsChildTaxonOfID,IsChildTaxonOf,NACHWEIS,AccordingTo,HYBRID,BEGRUEND,EDITSTATUS,EuroMed ) FROM stdin;\n\n&/' GERMANSL.tmp.sql

   # awk 'FNR==NR{ if (/INSERT INTO GermanSL VALUES/) p=NR; next} 1; FNR==p{ print "\.\n" }' GERMANSL.tmp.sql GERMANSL.tmp.sql > tmp.sql && mv tmp.sql GERMANSL.tmp.sql 

   sed -i 's/Ã/ß/g' GERMANSL.tmp.sql
   sed -i 's/Ã€/ä/g' GERMANSL.tmp.sql
   sed -i 's/Ã¶/ü/g' GERMANSL.tmp.sql
   sed -i 's/Ã¶/ö/g' GERMANSL.tmp.sql
   sed -i 's/ÃŒ/ü/g' GERMANSL.tmp.sql
   sed -i 's/Ã²/ò/g' GERMANSL.tmp.sql
   sed -i 's/Ã©/é/g' GERMANSL.tmp.sql
   sed -i 's/pÃ/ě/g' GERMANSL.tmp.sql

#break 2> /dev/null

   echo "Create database and tables and import data"
   
   psql postgres $CONF[USERNAMEPOSTGRES] < GERMANSL.tmp.sql

   echo "Create APP tables"

   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOT
   set client_min_messages = warning;

   CREATE INDEX germansl_taxonusageid_idx ON "germansl" (taxonusageid);

   CREATE INDEX germansl_ischildtaxonofid_idx ON "germansl" (ischildtaxonofid);

   CREATE INDEX germansl_synonym_idx ON "germansl" (synonym);

   DROP EXTENSION IF EXISTS pg_trgm CASCADE;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_GIN_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZVALID_NR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZNR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZRANK_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSCI_NAME_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSTATUS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_X_IS_SYNONYM_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERNLEN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZSPECNRCOUNT_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZLEN_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZPATTERN_INDEX;

   DROP TABLE IF EXISTS "ZSPEC" CASCADE;

   DROP TABLE IF EXISTS "ZRANK" CASCADE;

   DROP TABLE IF EXISTS "ZNAMESIDX" CASCADE;

   DROP TABLE IF EXISTS "ZSPECINDEX" CASCADE;

   DROP TABLE IF EXISTS "ZPERSON" CASCADE;

   DROP SEQUENCE IF EXISTS z_pk_zspec_seq;

   DROP SEQUENCE IF EXISTS z_pk_zrank_seq;

   DROP SEQUENCE IF EXISTS z_pk_znamesidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zpersonidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zspecindexidx_seq;

   CREATE EXTENSION pg_trgm;

   CREATE SEQUENCE z_pk_zspec_seq;

   CREATE SEQUENCE z_pk_zrank_seq;

   CREATE SEQUENCE z_pk_znamesidx_seq;

   CREATE SEQUENCE z_pk_zpersonidx_seq;

   CREATE SEQUENCE z_pk_zspecindexidx_seq;

   CREATE TABLE "ZSPEC" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspec_seq'), 
      Z_ENT INTEGER DEFAULT 18, 
      Z_OPT INTEGER DEFAULT 0,
      X_IS_SYNONYM INTEGER DEFAULT 0,
      X_KINGDOM INTEGER DEFAULT 0,
      ZICON INTEGER DEFAULT 0,
      ZNR INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZVALID_NR INTEGER DEFAULT 0,
      ZAUTHOR INTEGER DEFAULT -1,
      ZGEOGRAPHIC INTEGER DEFAULT 0,
      ZAGGS VARCHAR DEFAULT '',
      ZAGGSRANKS VARCHAR DEFAULT '',
      ZATTRIBUTES VARCHAR DEFAULT '',
      ZCHILDS VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZIMAGES VARCHAR DEFAULT '',
      ZINFO VARCHAR DEFAULT '',
      ZRANK VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR DEFAULT '',
      ZSYNONYMS VARCHAR DEFAULT '',
      ZUUID VARCHAR DEFAULT '' );

   CREATE TABLE "ZRANK" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zrank_seq'), 
      Z_ENT INTEGER DEFAULT 15, 
      Z_OPT INTEGER DEFAULT 0,
      ZKINGDOM INTEGER DEFAULT 0,
      ZLEVEL INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZABBREV VARCHAR DEFAULT '',
      ZCOLOR VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZICON VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR );

   CREATE TABLE "ZSPECINDEX" (
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspecindexidx_seq'), 
      Z_ENT INTEGER DEFAULT 20, 
      Z_OPT INTEGER DEFAULT 0,
      ZBBNR INTEGER DEFAULT 0, 
      ZCOLUMN INTEGER DEFAULT 0, 
      ZLEN INTEGER DEFAULT 0, 
      ZNR INTEGER DEFAULT 0, 
      ZPOS INTEGER DEFAULT 0, 
      ZSPECNR INTEGER DEFAULT 0, 
      ZPATTERN VARCHAR DEFAULT '' );

   CREATE TABLE "ZNAMESIDX" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_znamesidx_seq'), 
      Z_ENT INTEGER DEFAULT 11, 
      Z_OPT INTEGER DEFAULT 0,
      ZTYPE INTEGER DEFAULT 1,
      ZPATTERN VARCHAR DEFAULT '',
      ZPATTERNLEN INTEGER DEFAULT 0,
      ZSPECNR VARCHAR DEFAULT '',
      ZSPECNRCOUNT INTEGER DEFAULT 0 );

   CREATE TABLE "ZPERSON" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zpersonidx_seq'), 
      Z_ENT INTEGER DEFAULT 14, 
      Z_OPT INTEGER DEFAULT 0,
      X_TSN INTEGER DEFAULT -1,
      ZLANGUAGE INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT -1,
      ZYEAR TIMESTAMP, 
      ZADDRESS VARCHAR DEFAULT '', 
      ZCITEDLONG VARCHAR DEFAULT '', 
      ZCOUNTRY VARCHAR DEFAULT '', 
      ZEMAIL VARCHAR DEFAULT '', 
      ZFIRSTNAME VARCHAR DEFAULT '', 
      ZGENDER VARCHAR DEFAULT '', 
      ZINSTITUTION VARCHAR DEFAULT '', 
      ZLASTNAME VARCHAR DEFAULT '', 
      ZMD VARCHAR DEFAULT '', 
      ZNAME VARCHAR DEFAULT '', 
      ZNOTES VARCHAR DEFAULT '', 
      ZSHORTAUTHOR VARCHAR DEFAULT '', 
      ZTEL VARCHAR DEFAULT '', 
      ZTITLE VARCHAR DEFAULT '' );

   CREATE INDEX ZSPEC_ZAGGS_GIN_INDEX ON "ZSPEC" USING gin (ZAGGS gin_trgm_ops);

   CREATE INDEX ZSPEC_ZAGGS_INDEX ON "ZSPEC" (ZAGGS);

   CREATE INDEX ZSPEC_ZVALID_NR_INDEX ON "ZSPEC" (ZVALID_NR);

   CREATE INDEX ZSPEC_ZNR_INDEX ON "ZSPEC" (ZNR);

   CREATE INDEX ZSPEC_ZRANK_INDEX ON "ZSPEC" (ZRANK);

   CREATE INDEX ZSPEC_ZSCI_NAME_INDEX ON "ZSPEC" (ZSCI_NAME);

   CREATE INDEX ZSPEC_ZSTATUS_INDEX ON "ZSPEC" (ZSTATUS);

   CREATE INDEX ZSPEC_X_IS_SYNONYM_INDEX ON "ZSPEC" (X_IS_SYNONYM);

   CREATE INDEX ZNAMESIDX_ZPATTERN_INDEX ON "ZNAMESIDX" (ZPATTERN);

   CREATE INDEX ZNAMESIDX_ZPATTERNLEN_INDEX ON "ZNAMESIDX" (ZPATTERNLEN);

   CREATE INDEX ZNAMESIDX_ZSPECNRCOUNT_INDEX ON "ZNAMESIDX" (ZSPECNRCOUNT);

   CREATE INDEX ZSPECINDEX_ZLEN_INDEX ON "ZSPECINDEX" (ZLEN);

   CREATE INDEX ZSPECINDEX_ZPATTERN_INDEX ON "ZSPECINDEX" (ZPATTERN);
  
   DROP FUNCTION IF EXISTS stammbaumVonSpeciesNr(integer);

   CREATE FUNCTION stammbaumVonSpeciesNr(species integer) 
      RETURNS TABLE (LEVEL integer, NR integer, ischildtaxonofid integer, taxonrank text, taxonname text)
      AS \$\$
      WITH RECURSIVE specieshierarchy(tmp2_NR, tmp2_AGG, tmp2_taxonrank, tmp2_taxonname, tmp2_HierachyLevel) AS
      (
      SELECT taxonusageid, ischildtaxonofid, taxonrank, taxonname, 1 AS tmp2_HierachyLevel FROM germansl AS ROOT WHERE (ROOT.taxonusageid = species) AND synonym = 0
      UNION ALL
      SELECT PARENT.taxonusageid, PARENT.ischildtaxonofid, PARENT.taxonrank, PARENT.taxonname, tmp2_HierachyLevel+1 FROM germansl AS PARENT
      INNER JOIN specieshierarchy AS CHILD ON (CHILD.tmp2_AGG = PARENT.taxonusageid) AND (PARENT.taxonusageid > 0)
      )
      SELECT tmp2_HierachyLevel, tmp2_NR, tmp2_AGG, tmp2_taxonrank, tmp2_taxonname FROM specieshierarchy;
      \$\$
   LANGUAGE 'sql';

   DROP FUNCTION IF EXISTS aggregatesConcatOfAggsNrBytaxonusageid(integer);

   CREATE FUNCTION aggregatesConcatOfAggsNrBytaxonusageid(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(ischildtaxonofid AS text),''|'') FROM stammbaumVonSpeciesNr(species);'
   LANGUAGE 'sql';

   DROP FUNCTION IF EXISTS aggregatesConcatOftaxonranksNrBytaxonusageid(integer);

   CREATE FUNCTION aggregatesConcatOftaxonranksNrBytaxonusageid(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(taxonrank AS text),''|'') FROM stammbaumVonSpeciesNr(species);'
   LANGUAGE 'sql';

   DROP FUNCTION IF EXISTS aggregatesConcatOfChildsNrBytaxonusageid(integer);

   CREATE FUNCTION aggregatesConcatOfChildsNrBytaxonusageid(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(taxonusageid AS text),''|'') FROM germansl where synonym = ''0'' and ischildtaxonofid=species;'
   LANGUAGE 'sql';

   DROP FUNCTION IF EXISTS aggregatesConcatOfsynonymsNrBytaxonusageid(integer);

   CREATE FUNCTION aggregatesConcatOfsynonymsNrBytaxonusageid(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(taxonusageid AS text),''|'') FROM germansl where synonym = ''1'' and taxonconceptid=species;'
   LANGUAGE 'sql';
EOT
   
   rm GERMANSL.tmp.sql
}

function rawimport_itis_v1 {
   readonly file=${1:?"For ITIS import the dump filenname must be specified"}
   local tmp_file=${file:r}.tmp.sql

   echo "Importing $file data into Postgres ..."

   echo "migrate PostgreSQL dump file to UTF8 "

   rm -f $tmp_file

   iconv -f iso-8859-1 -t utf-8 $file > $tmp_file
   
   sed -i "s/ENCODING = 'LATIN1'/ENCODING = 'UTF8'/g" $tmp_file

   sed -i "s/LC_COLLATE = 'en_US.ISO8859-1'/LC_COLLATE = 'de_DE.UTF-8'/g" $tmp_file

   sed -i "s/LC_CTYPE = 'en_US.ISO8859-1'/LC_CTYPE = 'de_DE.UTF-8'/g" $tmp_file 

   sed -i "s/client_encoding = 'LATIN1'/client_encoding = 'UTF8'/g" $tmp_file 

   echo "Create database and tables and import data"
 
   psql postgres $CONF[USERNAMEPOSTGRES] < $tmp_file
   
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   set client_min_messages = warning;

   DROP EXTENSION IF EXISTS pg_trgm CASCADE;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_GIN_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZVALID_NR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZNR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZRANK_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSCI_NAME_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSTATUS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_X_IS_SYNONYM_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERNLEN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZSPECNRCOUNT_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZLEN_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZPATTERN_INDEX;

   DROP TABLE IF EXISTS "ZSPEC" CASCADE;

   DROP TABLE IF EXISTS "ZRANK" CASCADE;

   DROP TABLE IF EXISTS "ZNAMESIDX" CASCADE;

   DROP TABLE IF EXISTS "ZSPECINDEX" CASCADE;

   DROP TABLE IF EXISTS "ZPERSON" CASCADE;

   DROP SEQUENCE IF EXISTS z_pk_zspec_seq;

   DROP SEQUENCE IF EXISTS z_pk_zrank_seq;

   DROP SEQUENCE IF EXISTS z_pk_znamesidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zpersonidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zspecindexidx_seq;

   CREATE EXTENSION pg_trgm;

   CREATE SEQUENCE z_pk_zspec_seq;

   CREATE SEQUENCE z_pk_zrank_seq;

   CREATE SEQUENCE z_pk_znamesidx_seq;

   CREATE SEQUENCE z_pk_zpersonidx_seq;

   CREATE SEQUENCE z_pk_zspecindexidx_seq;

   CREATE TABLE "ZSPEC" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspec_seq'), 
      Z_ENT INTEGER DEFAULT 18, 
      Z_OPT INTEGER DEFAULT 0,
      X_IS_SYNONYM INTEGER DEFAULT 0,
      X_KINGDOM INTEGER DEFAULT 0,
      ZICON INTEGER DEFAULT 0,
      ZNR INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZVALID_NR INTEGER DEFAULT 0,
      ZAUTHOR INTEGER DEFAULT -1,
      ZGEOGRAPHIC INTEGER DEFAULT 0,
      ZAGGS VARCHAR DEFAULT '',
      ZAGGSRANKS VARCHAR DEFAULT '',
      ZATTRIBUTES VARCHAR DEFAULT '',
      ZCHILDS VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZIMAGES VARCHAR DEFAULT '',
      ZINFO VARCHAR DEFAULT '',
      ZRANK VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR DEFAULT '',
      ZSYNONYMS VARCHAR DEFAULT '',
      ZUUID VARCHAR DEFAULT '' );

   CREATE TABLE "ZRANK" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zrank_seq'), 
      Z_ENT INTEGER DEFAULT 15, 
      Z_OPT INTEGER DEFAULT 0,
      ZKINGDOM INTEGER DEFAULT 0,
      ZLEVEL INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZABBREV VARCHAR DEFAULT '',
      ZCOLOR VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZICON VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR );

   CREATE TABLE "ZSPECINDEX" (
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspecindexidx_seq'), 
      Z_ENT INTEGER DEFAULT 20, 
      Z_OPT INTEGER DEFAULT 0,
      ZBBNR INTEGER DEFAULT 0, 
      ZCOLUMN INTEGER DEFAULT 0, 
      ZLEN INTEGER DEFAULT 0, 
      ZNR INTEGER DEFAULT 0, 
      ZPOS INTEGER DEFAULT 0, 
      ZSPECNR INTEGER DEFAULT 0, 
      ZPATTERN VARCHAR DEFAULT '' );

   CREATE TABLE "ZNAMESIDX" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_znamesidx_seq'), 
      Z_ENT INTEGER DEFAULT 11, 
      Z_OPT INTEGER DEFAULT 0,
      ZTYPE INTEGER DEFAULT 1,
      ZPATTERN VARCHAR DEFAULT '',
      ZPATTERNLEN INTEGER DEFAULT 0,
      ZSPECNR VARCHAR DEFAULT '',
      ZSPECNRCOUNT INTEGER DEFAULT 0 );

   CREATE TABLE "ZPERSON" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zpersonidx_seq'), 
      Z_ENT INTEGER DEFAULT 14, 
      Z_OPT INTEGER DEFAULT 0,
      X_TSN INTEGER DEFAULT -1,
      ZLANGUAGE INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT -1,
      ZYEAR TIMESTAMP, 
      ZADDRESS VARCHAR DEFAULT '', 
      ZCITEDLONG VARCHAR DEFAULT '', 
      ZCOUNTRY VARCHAR DEFAULT '', 
      ZEMAIL VARCHAR DEFAULT '', 
      ZFIRSTNAME VARCHAR DEFAULT '', 
      ZGENDER VARCHAR DEFAULT '', 
      ZINSTITUTION VARCHAR DEFAULT '', 
      ZLASTNAME VARCHAR DEFAULT '', 
      ZMD VARCHAR DEFAULT '', 
      ZNAME VARCHAR DEFAULT '', 
      ZNOTES VARCHAR DEFAULT '', 
      ZSHORTAUTHOR VARCHAR DEFAULT '', 
      ZTEL VARCHAR DEFAULT '', 
      ZTITLE VARCHAR DEFAULT '' );

   CREATE INDEX ZSPEC_ZAGGS_GIN_INDEX ON "ZSPEC" USING gin (ZAGGS gin_trgm_ops);

   CREATE INDEX ZSPEC_ZAGGS_INDEX ON "ZSPEC" (ZAGGS);

   CREATE INDEX ZSPEC_ZVALID_NR_INDEX ON "ZSPEC" (ZVALID_NR);

   CREATE INDEX ZSPEC_ZNR_INDEX ON "ZSPEC" (ZNR);

   CREATE INDEX ZSPEC_ZRANK_INDEX ON "ZSPEC" (ZRANK);

   CREATE INDEX ZSPEC_ZSCI_NAME_INDEX ON "ZSPEC" (ZSCI_NAME);

   CREATE INDEX ZSPEC_ZSTATUS_INDEX ON "ZSPEC" (ZSTATUS);

   CREATE INDEX ZSPEC_X_IS_SYNONYM_INDEX ON "ZSPEC" (X_IS_SYNONYM);

   CREATE INDEX ZNAMESIDX_ZPATTERN_INDEX ON "ZNAMESIDX" (ZPATTERN);

   CREATE INDEX ZNAMESIDX_ZPATTERNLEN_INDEX ON "ZNAMESIDX" (ZPATTERNLEN);

   CREATE INDEX ZNAMESIDX_ZSPECNRCOUNT_INDEX ON "ZNAMESIDX" (ZSPECNRCOUNT);

   CREATE INDEX ZSPECINDEX_ZLEN_INDEX ON "ZSPECINDEX" (ZLEN);

   CREATE INDEX ZSPECINDEX_ZPATTERN_INDEX ON "ZSPECINDEX" (ZPATTERN);

   DROP FUNCTION IF EXISTS aggregatesConcatOfChildsNrBySPECIES_NR(integer);
   
   CREATE FUNCTION aggregatesConcatOfChildsNrBySPECIES_NR(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(tsn AS text),''|'') FROM hierarchy where parent_tsn = species;'
   LANGUAGE 'sql';

   DROP FUNCTION IF EXISTS aggregatesConcatOfSynonymsNrBySPECIES_NR(integer);
   
   CREATE FUNCTION aggregatesConcatOfSynonymsNrBySPECIES_NR(species integer) RETURNS Text
      AS 'SELECT string_agg(CAST(ZNR AS text),''|'') FROM "ZSPEC" where ZVALID_NR = species;'
   LANGUAGE 'sql';

   CREATE UNIQUE INDEX hierarchy_tsn_idx ON hierarchy (tsn);

   CREATE INDEX hierarchy_parent_tsn_idx ON hierarchy (parent_tsn);

   DROP FUNCTION IF EXISTS aggs(integer);

   CREATE OR REPLACE FUNCTION aggs(species integer) RETURNS text AS
   \$BODY\$
   DECLARE
      res text := '';
      arr text[];
   BEGIN
      arr := array (SELECT regexp_split_to_table(hierarchy_string, '-') from hierarchy where tsn = species);
      IF array_upper(arr,1)>0 THEN
         res := arr[array_upper(arr,1)-1] ;
         IF array_upper(arr,1)>1 THEN
               FOR i IN REVERSE array_upper(arr,1)-2..1 LOOP
                  res := res || '|' || arr[i];
               END LOOP;
         END IF;
      END IF;
      RETURN res;
   END
   \$BODY\$
   LANGUAGE 'plpgsql';

   DROP FUNCTION IF EXISTS aggsupdatev02(a1 integer, a2 integer);

   CREATE OR REPLACE FUNCTION aggsupdateV02(a1 integer, a2 integer) RETURNS void AS
   \$BODY\$
   DECLARE
      i int := 0;
      res text := '';
      arr text[];
      tsnummer int;
      arr2 text[];
      rank text;
   BEGIN
      FOR i IN a1..a2 LOOP
         arr := array (SELECT regexp_split_to_table(hierarchy_string, '-') FROM hierarchy WHERE tsn = i);
         IF array_upper(arr,1)>0 THEN
               res := arr[array_upper(arr,1)-1] ;
               IF array_upper(arr,1)>1 THEN
                  FOR i IN REVERSE array_upper(arr,1)-2..1 LOOP
                     res := res || '|' || arr[i];
                  END LOOP;
               END IF;
         END IF;
         UPDATE "ZSPEC" AS s SET ZAGGS = res where ZNR=i AND X_IS_SYNONYM=0;
         res := '';
         IF array_upper(arr,1)>0 THEN
               FOR i IN REVERSE array_upper(arr,1)..1 LOOP
                  tsnummer := cast(arr[i] as int);
                  SELECT trim(cast(t1.kingdom_id as text)) || 'x' || trim(cast(t1.rank_id as text)) INTO rank FROM taxonomic_units AS t1, taxon_unit_types AS t2 WHERE t1.tsn=tsnummer AND t1.kingdom_id=t2.kingdom_id AND t1.rank_id=t2.rank_id;
                  IF i > 1 THEN
                     res := res || rank  || '|';
                  ELSE
                     res := res || rank;
                  END IF;
               END LOOP;
         END IF;
         UPDATE "ZSPEC" AS s SET ZAGGSRANKS = res where ZNR=i AND X_IS_SYNONYM=0;
      END LOOP;
   RETURN; END
   \$BODY\$
   LANGUAGE 'plpgsql';
EOF
   rm $tmp_file
}

#############################
## Level 1                 ##
#############################

function roottaxa() {
   local roottaxa=""
   if [[ ! -z $CONF[ROOTTAXA] ]] 
   then
      roottaxa=$CONF[ROOTTAXA]
   else
      roottaxa=$(sqlite3 "$CONF[ROOTDB]" "select zchilds from ZSPEC where zsci_name='"$CONF[ROOTTAXANAME]"';" ".exit")
      roottaxa=${roottaxa//|/ }
      tmp=${roottaxa#" "}
      roottaxa=${tmp%" "}
   fi
   roottaxa=("${(@s/ /)roottaxa}")
   roottaxa_strA=${(j:,:)roottaxa}
   python3 - <<EOT
from migrate import openPG, roottaxaUpdate
handle=openPG('$CONF[DBHOSTPOSTGRES]','$CONF[BACKBONE]','$CONF[USERNAMEPOSTGRES]','$CONF[PASSWORDPOSTGRES]')
roottaxaUpdate(handle,'$roottaxa_strA')
EOT
}

function rawimport() {
   if [ "$CONF[BACKBONE]" = 'GERMANSL' ] 
   then
      rawimport_germansl_v1 $CONF[DBSOURCEFILE]
   elif [ "$CONF[BACKBONE]" = 'ITIS' ]; then
      rawimport_itis_v1 $CONF[DBSOURCEFILE]
   else
      echo Database "$CONF[BACKBONE]" is not supported!
   fi
}

function import() {
   if [ "$CONF[BACKBONE]" = 'GERMANSL' ] 
   then
      import_germansl_v1
   elif [ "$CONF[BACKBONE]" = 'ITIS' ]; then
      import_itis_v1
   else
      echo Database "$CONF[BACKBONE]" is not supported!
   fi
}

function info() {
   if [ "$CONF[BACKBONE]" = 'GERMANSL' ] 
   then
      info_germansl_v1
   elif [ "$CONF[BACKBONE]" = 'ITIS' ]; then
      info_itis_v1
   else
      echo Database "$CONF[BACKBONE]" is not supported!
   fi
}

function synonyms() {
   python3 - <<EOT
from migrate import openPG, insertSynonyms
handle=openPG('$CONF[DBHOSTPOSTGRES]','$CONF[BACKBONE]','$CONF[USERNAMEPOSTGRES]','$CONF[PASSWORDPOSTGRES]')
insertSynonyms(handle)
EOT
}

function specindex_prepare() {
   python3 - <<EOT
from migrate import openPG, genIndex
handle=openPG('$CONF[DBHOSTPOSTGRES]','$CONF[BACKBONE]','$CONF[USERNAMEPOSTGRES]','$CONF[PASSWORDPOSTGRES]')
# genIndex args: handle,minpatlen,maxpatlen,startnr
genIndex(handle,4,10,0)
EOT
}

function specindex_insert() {
   readonly tmpfile=${1:?"Temporary specindex_prepare file must be specified"}
   if [ -z "$tmpfile" ]
   then
      break 2> /dev/null
   fi
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] < $tmpfile
}

function namesindex() {
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOT
DROP TABLE IF EXISTS "ZNAMESIDX";
DROP SEQUENCE z_pk_znamesidx_seq;
CREATE SEQUENCE z_pk_znamesidx_seq;
CREATE TABLE "ZNAMESIDX" ( 
   Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_znamesidx_seq'), 
   Z_ENT INTEGER DEFAULT 11, 
   Z_OPT INTEGER DEFAULT 0,
   ZTYPE INTEGER DEFAULT 1,
   ZPATTERN VARCHAR DEFAULT '',
   ZPATTERNLEN INTEGER DEFAULT 0,
   ZSPECNR VARCHAR DEFAULT '',
   ZSPECNRCOUNT INTEGER DEFAULT 0 );
INSERT INTO "ZNAMESIDX"(ZSPECNR,ZSPECNRCOUNT,ZPATTERN,ZPATTERNLEN) SELECT STRING_AGG(CAST(foo.nr AS VARCHAR),',') as t1,count(*) as t2,foo.pattern as t3,min(foo.len) as t3 from (select min(zlen) as len, zspecnr as nr, trim(zpattern) as pattern from "ZSPECINDEX" group by zspecnr,zpattern) as foo group by foo.pattern;
CREATE INDEX ZNAMESIDX_ZPATTERN_INDEX ON "ZNAMESIDX" (ZPATTERN);
CREATE INDEX ZNAMESIDX_ZPATTERNLEN_INDEX ON "ZNAMESIDX" (ZPATTERNLEN);
CREATE INDEX ZNAMESIDX_ZSPECNRCOUNT_INDEX ON "ZNAMESIDX" (ZSPECNRCOUNT);
EOT
}

function exportapp_prepare() {
   if [ "$CONF[BACKBONE]" = 'GERMANSL' ] 
   then
      prepare_exporttoappdb_germansl_v2
   elif [ "$CONF[BACKBONE]" = 'ITIS' ]; then
      prepare_exporttoappdb_itis_v1
   else
      echo Database "$CONF[BACKBONE]" is not supported!
   fi
}

function finish_exportdir() {
   local month=$(date -d "$CONF[PUBLISHED]" '+%m')
   local year=$(date -d "$CONF[PUBLISHED]" '+%y')
   local feature=$CONF[PURCHASECONTENTFEATURE]
   local targetDirZip=APPDB/"$CONF[BACKBONE]/$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION]"
   mv $targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION]_DBInfo.plist $targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_"$month""$year"_$feature/Contents/DBInfo.plist
   mv $targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION].zip $targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_"$month""$year"_$feature/Contents/
   local contentInfoPlist=$targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_"$month""$year"_"$feature"/ContentInfo.plist
   local metaDataFile=$targetDirZip/SKUTaxaDB.itmsp/metadata.xml
   local iapReferenceName="$CONF[BACKBONE] $CONF[NAME] $month.$year"
   # GERMANSL_Flowers_0420_A.pkg
   local iapPKGFilename="$CONF[BACKBONE]"_"$CONF[NAME]"_"$month""$year"_"$CONF[PURCHASECONTENTFEATURE]".pkg
   python3 - <<EOT
from migrate import openSL, writeContentInfo, writeContentSKUTaxaDBMetadata
writeContentInfo('$contentInfoPlist','$CONF[PURCHASEID]','$CONF[PURCHASECONTENTVERSION]')
handle=openSL("$targetDirZip/$CONF[BACKBONE]_$CONF[NAME]" + "_" + "$CONF[TARGETVERSION]" + ".sqlite")
writeContentSKUTaxaDBMetadata(handle,'$metaDataFile','$CONF[PURCHASEID]','$iapReferenceName','$iapPKGFilename')
EOT
}

function exportapp_insert() {
   for table ('ZSPEC' 'ZRANK' 'ZNAMESIDX' 'ZPERSON'); do
      echo "Exporting "$table" ..."
      rm -f export$table.sql
      pg_dump $CONF[BACKBONE] --schema=public --table="public.\""$table"\"" -a -E UTF-8 --column-inserts --username=$CONF[USERNAMEPOSTGRES] -f export$table.sql
      sed -i '/SELECT/d' export$table.sql
      sed -i '/--/d' export$table.sql
      sed -i '/SET/d' export$table.sql
      sed -i '/^\\/d' export$table.sql
      sed -i "s/public\.//g" export$table.sql
      sed -i '/^[[:space:]]*$/d' export$table.sql
      sed -i '1s/^/DELETE FROM '$table';\n/' export$table.sql
      sed -i '1s/^/PRAGMA synchronous = OFF;\n/' export$table.sql
      sed -i '1s/^/PRAGMA journal_mode = MEMORY;\n/' export$table.sql
      sqlite3 $CONF[DBTARGETFILE] < export$table.sql
   done
}

## insertConfig(handle,update,uuid,Z_ENT,ZNR,ZSTATUS,ZPUBLISHED,ZCITATION,ZNAME,ZNAMELANGS,ZNATIVELANG,ZRANKLANGS,ZROOTTAXA,ZSOURCE,ZVERSION,ZINFO):

function test8() {
   local roottaxa=""
   if [[ ! -z $CONF[ROOTTAXA] ]] 
   then
      roottaxa=$CONF[ROOTTAXA]
   else
      roottaxa=$(sqlite3 "$CONF[ROOTDB]" "select zchilds from ZSPEC where zsci_name='"$CONF[ROOTTAXANAME]"';" ".exit")
      roottaxa=${roottaxa//|/ }
      tmp=${roottaxa#" "}
      roottaxa=${tmp%" "}
   fi
   roottaxa=("${(@s/ /)roottaxa}")
   local roottaxa_strC=${(j:,:)roottaxa}
   echo $roottaxa_strC
}

function config() {
   local targetDirZip=APPDB/"$CONF[BACKBONE]/$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION]"
   local roottaxa=""
   if [[ ! -z $CONF[ROOTTAXA] ]] 
   then
      roottaxa=$CONF[ROOTTAXA]
   else
      roottaxa=$(sqlite3 "$CONF[ROOTDB]" "select zchilds from ZSPEC where zsci_name='"$CONF[ROOTTAXANAME]"';" ".exit")
      roottaxa=${roottaxa//|/ }
      tmp=${roottaxa#" "}
      roottaxa=${tmp%" "}
   fi
   roottaxa=("${(@s/ /)roottaxa}")
   local roottaxa_strC=${(j:,:)roottaxa}
   local uuid=${(U)$(uuidgen)}
   sqlite3 $targetDirZip/"$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION].sqlite" VACUUM;
   local filesize=$(stat -c%s $targetDirZip/"$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION].sqlite")
   if [ $(($CONF[STATUS] & 256)) = 0 ] 
   then
   python3 - <<EOT
from migrate import insertConfig, writeUUID, openSL, updatePrimaryKeys
handle=openSL('$CONF[DBCONFIGFILE]')
uuid=insertConfig(handle,True,'$uuid','$ENT[BACKBONE]','$CONF[NR]','$CONF[STATUS]','$CONF[PUBLISHED]','$CONF[CITATION]','$CONF[NAME]','$CONF[NAMELANGS]','$CONF[NATIVELANG]','$CONF[RANKLANGS]','$roottaxa_strC','$CONF[BACKBONE]','$CONF[TARGETVERSION]','$filesize')
updatePrimaryKeys(handle,'$ENT[BACKBONE]','ZBACKBONE')
handle=openSL("$CONF[BACKBONE]_$CONF[NAME]" + "_" + "$CONF[TARGETVERSION]" + ".sqlite")
writeUUID(handle,uuid,1)
updatePrimaryKeys(handle,'$ENT[SPEC]','ZSPEC')
updatePrimaryKeys(handle,'$ENT[RANK]','ZRANK')
updatePrimaryKeys(handle,'$ENT[NAMESIDX]','ZNAMESIDX')
updatePrimaryKeys(handle,'$ENT[PERSON]','ZPERSON')
EOT
   else
   local newDBInfoFile=$targetDirZip/$CONF[BACKBONE]_$CONF[NAME]_$CONF[TARGETVERSION]_DBInfo.plist
   rm -f "$newDBInfoFile"
   touch "$newDBInfoFile"
   python3 - <<EOT
from migrate import insertConfig, writeUUID, openSL, cleanConfig, updatePrimaryKeys, writeDBInfo
handle=openSL('$CONF[DBCONFIGFILE]')
print('$uuid')
uuid=insertConfig(handle,True,'$uuid','$ENT[BACKBONE]','$CONF[NR]','$CONF[STATUS]','$CONF[PUBLISHED]','$CONF[CITATION]','$CONF[NAME]','$CONF[NAMELANGS]','$CONF[NATIVELANG]','$CONF[RANKLANGS]','$roottaxa_strC','$CONF[BACKBONE]','$CONF[TARGETVERSION]','$filesize')
print(uuid)
updatePrimaryKeys(handle,'$ENT[BACKBONE]','ZBACKBONE')
handle=openSL("$targetDirZip/$CONF[BACKBONE]_$CONF[NAME]" + "_" + "$CONF[TARGETVERSION]" + ".sqlite")
cleanConfig(handle,$ENT[BACKBONE])
writeUUID(handle,uuid,1)
uuid=insertConfig(handle,True,uuid,'$ENT[BACKBONE]','$CONF[NR]','$CONF[STATUS]','$CONF[PUBLISHED]','$CONF[CITATION]','$CONF[NAME]','$CONF[NAMELANGS]','$CONF[NATIVELANG]','$CONF[RANKLANGS]','$roottaxa_strC','$CONF[BACKBONE]','$CONF[TARGETVERSION]','$filesize')
writeDBInfo(handle,"DBInfo.plist",'$newDBInfoFile','$filesize','$CONF[NR]','$CONF[NAME]','$MODELVERSION','$CONF[BACKBONE]','$CONF[NAMELANGS]','$CONF[NATIVELANG]','$CONF[RANKLANGS]','$roottaxa_strC',uuid,'$CONF[CITATION]','$CONF[TARGETVERSION]','$CONF[PUBLISHED]','$CONF[PURCHASEID]')
print(uuid)
updatePrimaryKeys(handle,$ENT[BACKBONE],'ZBACKBONE')
updatePrimaryKeys(handle,'$ENT[SPEC]','ZSPEC')
updatePrimaryKeys(handle,'$ENT[RANK]','ZRANK')
updatePrimaryKeys(handle,'$ENT[NAMESIDX]','ZNAMESIDX')
updatePrimaryKeys(handle,'$ENT[PERSON]','ZPERSON')

EOT
   fi
}

## main ##

if ! python3 -c "import psycopg2" &> /dev/null; then
    echo "Python-Module 'psycopg2' not found."
    echo "Missing switch to Python venv : 'source .venv/bin/activate'?"
    break 2> /dev/null
fi

if [ -z "$args[-conf]" ]
then
   echo "Configuration must be specified"
   break 2> /dev/null
fi

CONFNAME=$args[-conf]
CONF=( ${(kv)${(P)CONFNAME}} ) 

if [ -z "$args[-username]" ]
then
   echo "Postgres DB username must be specified"
   break 2> /dev/null
else
   CONF[USERNAMEPOSTGRES]=$args[-username]
fi

if [ -z "$args[-password]" ]
then
   echo "Postgres DB password must be specified"
   break 2> /dev/null
else
   CONF[PASSWORDPOSTGRES]=$args[-password]
fi

CONF[PURCHASEID]=$CONF[PURCHASEID_RAW]_$CONF[PURCHASECONTENTFEATURE]

local ZSPEC_COPY_FILE=$CONF[BACKBONE]_$CONF[TARGETVERSION]_ZSPEC.copy

local ZRANK_COPY_FILE=$CONF[BACKBONE]_$CONF[TARGETVERSION]_ZRANK.copy

local ZPERSON_COPY_FILE=$CONF[BACKBONE]_$CONF[TARGETVERSION]_ZPERSON.copy

if [ -f "$ZSPEC_COPY_FILE" ] && [ -f "$ZRANK_COPY_FILE" ] && [ -f "$ZPERSON_COPY_FILE" ];
then
echo "\n###################################\nImport from ZSPEC and ZRANK and ZPERSON copy\n###################################"
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   set client_min_messages = warning;

   DROP EXTENSION IF EXISTS pg_trgm CASCADE;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_GIN_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZAGGS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZVALID_NR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZNR_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZRANK_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSCI_NAME_INDEX;

   DROP INDEX IF EXISTS ZSPEC_ZSTATUS_INDEX;

   DROP INDEX IF EXISTS ZSPEC_X_IS_SYNONYM_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZPATTERNLEN_INDEX;

   DROP INDEX IF EXISTS ZNAMESIDX_ZSPECNRCOUNT_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZLEN_INDEX;

   DROP INDEX IF EXISTS ZSPECINDEX_ZPATTERN_INDEX;

   DROP TABLE IF EXISTS "ZSPEC" CASCADE;

   DROP TABLE IF EXISTS "ZRANK" CASCADE;

   DROP TABLE IF EXISTS "ZNAMESIDX" CASCADE;

   DROP TABLE IF EXISTS "ZSPECINDEX" CASCADE;

   DROP TABLE IF EXISTS "ZPERSON" CASCADE;

   DROP SEQUENCE IF EXISTS z_pk_zspec_seq;

   DROP SEQUENCE IF EXISTS z_pk_zrank_seq;

   DROP SEQUENCE IF EXISTS z_pk_znamesidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zpersonidx_seq;

   DROP SEQUENCE IF EXISTS z_pk_zspecindexidx_seq;

   CREATE EXTENSION pg_trgm;

   CREATE SEQUENCE z_pk_zspec_seq;

   CREATE SEQUENCE z_pk_zrank_seq;

   CREATE SEQUENCE z_pk_znamesidx_seq;

   CREATE SEQUENCE z_pk_zpersonidx_seq;

   CREATE SEQUENCE z_pk_zspecindexidx_seq;

   CREATE TABLE "ZSPEC" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspec_seq'), 
      Z_ENT INTEGER DEFAULT 18, 
      Z_OPT INTEGER DEFAULT 0,
      X_IS_SYNONYM INTEGER DEFAULT 0,
      X_KINGDOM INTEGER DEFAULT 0,
      ZICON INTEGER DEFAULT 0,
      ZNR INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZVALID_NR INTEGER DEFAULT 0,
      ZAUTHOR INTEGER DEFAULT -1,
      ZGEOGRAPHIC INTEGER DEFAULT 0,
      ZAGGS VARCHAR DEFAULT '',
      ZAGGSRANKS VARCHAR DEFAULT '',
      ZATTRIBUTES VARCHAR DEFAULT '',
      ZCHILDS VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZIMAGES VARCHAR DEFAULT '',
      ZINFO VARCHAR DEFAULT '',
      ZRANK VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR DEFAULT '',
      ZSYNONYMS VARCHAR DEFAULT '',
      ZUUID VARCHAR DEFAULT '' );

   CREATE TABLE "ZRANK" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zrank_seq'), 
      Z_ENT INTEGER DEFAULT 15, 
      Z_OPT INTEGER DEFAULT 0,
      ZKINGDOM INTEGER DEFAULT 0,
      ZLEVEL INTEGER DEFAULT 0,
      ZSTATUS INTEGER DEFAULT 0,
      ZABBREV VARCHAR DEFAULT '',
      ZCOLOR VARCHAR DEFAULT '',
      ZDE_NAME VARCHAR DEFAULT '',
      ZEN_NAME VARCHAR DEFAULT '',
      ZFR_NAME VARCHAR DEFAULT '',
      ZICON VARCHAR DEFAULT '',
      ZSCI_NAME VARCHAR );

   CREATE TABLE "ZSPECINDEX" (
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zspecindexidx_seq'), 
      Z_ENT INTEGER DEFAULT 20, 
      Z_OPT INTEGER DEFAULT 0,
      ZBBNR INTEGER DEFAULT 0, 
      ZCOLUMN INTEGER DEFAULT 0, 
      ZLEN INTEGER DEFAULT 0, 
      ZNR INTEGER DEFAULT 0, 
      ZPOS INTEGER DEFAULT 0, 
      ZSPECNR INTEGER DEFAULT 0, 
      ZPATTERN VARCHAR DEFAULT '' );

   CREATE TABLE "ZNAMESIDX" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_znamesidx_seq'), 
      Z_ENT INTEGER DEFAULT 11, 
      Z_OPT INTEGER DEFAULT 0,
      ZTYPE INTEGER DEFAULT 1,
      ZPATTERN VARCHAR DEFAULT '',
      ZPATTERNLEN INTEGER DEFAULT 0,
      ZSPECNR VARCHAR DEFAULT '',
      ZSPECNRCOUNT INTEGER DEFAULT 0 );

   CREATE TABLE "ZPERSON" ( 
      Z_PK INTEGER PRIMARY KEY NOT NULL DEFAULT nextval('z_pk_zpersonidx_seq'), 
      Z_ENT INTEGER DEFAULT 14, 
      Z_OPT INTEGER DEFAULT 0,
      X_TSN INTEGER DEFAULT -1,
      ZLANGUAGE INTEGER DEFAULT 0,
      ZOWNER INTEGER DEFAULT -1,
      ZYEAR TIMESTAMP, 
      ZADDRESS VARCHAR DEFAULT '', 
      ZCITEDLONG VARCHAR DEFAULT '', 
      ZCOUNTRY VARCHAR DEFAULT '', 
      ZEMAIL VARCHAR DEFAULT '', 
      ZFIRSTNAME VARCHAR DEFAULT '', 
      ZGENDER VARCHAR DEFAULT '', 
      ZINSTITUTION VARCHAR DEFAULT '', 
      ZLASTNAME VARCHAR DEFAULT '', 
      ZMD VARCHAR DEFAULT '', 
      ZNAME VARCHAR DEFAULT '', 
      ZNOTES VARCHAR DEFAULT '', 
      ZSHORTAUTHOR VARCHAR DEFAULT '', 
      ZTEL VARCHAR DEFAULT '', 
      ZTITLE VARCHAR DEFAULT '' );

   CREATE INDEX ZSPEC_ZAGGS_GIN_INDEX ON "ZSPEC" USING gin (ZAGGS gin_trgm_ops);

   CREATE INDEX ZSPEC_ZAGGS_INDEX ON "ZSPEC" (ZAGGS);

   CREATE INDEX ZSPEC_ZVALID_NR_INDEX ON "ZSPEC" (ZVALID_NR);

   CREATE INDEX ZSPEC_ZNR_INDEX ON "ZSPEC" (ZNR);

   CREATE INDEX ZSPEC_ZRANK_INDEX ON "ZSPEC" (ZRANK);

   CREATE INDEX ZSPEC_ZSCI_NAME_INDEX ON "ZSPEC" (ZSCI_NAME);

   CREATE INDEX ZSPEC_ZSTATUS_INDEX ON "ZSPEC" (ZSTATUS);

   CREATE INDEX ZSPEC_X_IS_SYNONYM_INDEX ON "ZSPEC" (X_IS_SYNONYM);

   CREATE INDEX ZNAMESIDX_ZPATTERN_INDEX ON "ZNAMESIDX" (ZPATTERN);

   CREATE INDEX ZNAMESIDX_ZPATTERNLEN_INDEX ON "ZNAMESIDX" (ZPATTERNLEN);

   CREATE INDEX ZNAMESIDX_ZSPECNRCOUNT_INDEX ON "ZNAMESIDX" (ZSPECNRCOUNT);

   CREATE INDEX ZSPECINDEX_ZLEN_INDEX ON "ZSPECINDEX" (ZLEN);

   CREATE INDEX ZSPECINDEX_ZPATTERN_INDEX ON "ZSPECINDEX" (ZPATTERN);

   \copy "ZSPEC" FROM '$ZSPEC_COPY_FILE';

   \copy "ZRANK" FROM '$ZRANK_COPY_FILE';

   \copy "ZPERSON" FROM '$ZPERSON_COPY_FILE';
EOF
else
echo "\n###################################\nImport from proprietary data source\n###################################"
rawimport
echo "\n###################################\nInsert into Z Tables (postgres)\n###################################"
import
echo "\n###################################\nCopy ZSPEC to File\n###################################"
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   \copy (SELECT * FROM "ZSPEC") TO '$ZSPEC_COPY_FILE';
EOF
echo "\n###################################\nCopy ZRANK to File\n###################################"
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   \copy (SELECT * FROM "ZRANK") TO '$ZRANK_COPY_FILE';
EOF
echo "\n###################################\nCopy ZPERSON to File\n###################################"
   psql $CONF[BACKBONE] $CONF[USERNAMEPOSTGRES] <<EOF
   \copy (SELECT * FROM "ZPERSON") TO '$ZPERSON_COPY_FILE';
EOF
fi

echo "\n###################################\nUpdate for Root Taxa\n###################################"
roottaxa
echo "\n###################################\nGenerate Info data (statistics)\n###################################"
info
echo "\n###################################\nGenerate Info data (synomyms)\n###################################"
synonyms
rm -f tmp1.sql
echo "\n###################################\nPrepare Specindex\n###################################"
specindex_prepare > tmp1.sql
#break 2> /dev/null
echo "\n###################################\nInsert Specindex\n###################################"
specindex_insert tmp1.sql
echo "\n###################################\nInsert Namesindex\n###################################"
namesindex
echo "\n###################################\nPrepare data to insert into Z Tables (sqlite)\n###################################"
exportapp_prepare
echo "\n###################################\nInsert into Z Tables (sqlite)\n###################################"
exportapp_insert

unsetopt nomatch