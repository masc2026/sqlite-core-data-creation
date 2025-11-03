# coding:UTF-8

#  Created by Markus Schmid on 28.06.22.
#  Updated by Markus Schmid on 31.10.25.
#  Copyright © 2025 Markus Schmid. All rights reserved.

import json
import re
import sqlite3
import sys
import uuid
import plistlib
import xml.etree.ElementTree as ET
from collections import namedtuple
from datetime import datetime, date

import psycopg2
import psycopg2.extras

ROWNR = 0

"""
ITIS

select nr,sci_name,kingdom,childs from "SPEC" where is_synonym=0 and aggs is null;

nr	    sci_name	kingdom	    childs
50	    Bacteria	1	        956096|956097
202422	Plantae	    3	        846491|954898
202423	Animalia	5	        202430|914153|914154
555705	Fungi	    4	        13762|936287|936288
630577	Protozoa	2	        13700|43780|43781|46211|553099|9601
630578	Chromista	6	        590735|969910|969911
935939	Archaea	    7	        951422|951423

GERMANSL

select nr,sci_name,kingdom,childs from "SPEC" where is_synonym=0 and (aggs is null OR aggs = '0');

nr	    sci_name	    kingdom	    childs		
0	    Planta	        NULL	    0|60002|91947|99000		
60002	Embryophyta	    NULL	    60008|60048|60049|90425		
91947	Flechten	    NULL	    94417|94418		
99000	Algen	        NULL	    90800|90802|90958|90965|91072|91339|91556|91596|91615|92542|92731|94025|94716		

"""

##################
# Helper >       #
##################

def testSQConnection(dbfile):
    try:
        handle = sqlite3.connect(dbfile)
        handle.close()
        return True
    except Exception as error:
        print("Exception has occured:", error)
        print("Exception Type:", type(error))
        print("No SQLite Connection!")
        return False

def testPGConnection(host,dbname,user,passwd):
    try:
        connectStr = "dbname='%s' user='%s' host='%s' password='%s'" % (dbname,user,host,passwd)
        handle = psycopg2.connect(connectStr)
        handle.close()
        return True
    except Exception as error:
        print("Exception has occured:", error)
        print("Exception Type:", type(error))
        print("No Postgres DB Connection!")
        return False

def openPG(host,dbname,user,passwd):
    try:
        connectStr = "dbname='%s' user='%s' host='%s' password='%s'" % (dbname,user,host,passwd)
        handle = psycopg2.connect(connectStr)
        return handle
    except:
        print("No Postgres DB Connection!")
        return None

def openSL(dbfile):
    try:
        handle = sqlite3.connect(dbfile)
        return handle
    except:
        print("No SQLite DB Connection!")
        return None

def genIndex(handle,minpatlen,maxpatlen,startnr):
    try:
        print("COPY \"ZSPECINDEX\" (ZPATTERN, ZSPECNR, ZLEN) FROM stdin;");
        cursor = handle.cursor(cursor_factory=psycopg2.extras.DictCursor)
        ## znr in update Tabelle durchlaufen:
        sql="select x_is_synonym,zvalid_nr,znr,zsci_name,zen_name,zde_name,zfr_name from \"ZSPEC\" where znr>='%d' order by znr" % (startnr)
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            sci_name=row['zsci_name']
            en_name=row['zen_name']
            de_name=row['zde_name']
            fr_name=row['zfr_name']
            specnr=row['znr']
            if row['x_is_synonym'] == 1:
                specnr=row['zvalid_nr']
            if len(sci_name)>0:
                genupdateIndex(specnr,sci_name,minpatlen,maxpatlen)
            if len(en_name)>0:
                genupdateIndex(specnr,en_name,minpatlen,maxpatlen)
            if len(de_name)>0:
                genupdateIndex(specnr,de_name,minpatlen,maxpatlen)
            if len(fr_name)>0:
                genupdateIndex(specnr,fr_name,minpatlen,maxpatlen)
        print("\\.");
    except Exception as e:
        print(repr(e))
        sys.exit()
    return
    
def genupdateIndex(specnr,text,minpatlen,maxpatlen):
    try:
        text = re.sub(r' sp\.| spec\. | species| gat\.| gen\.| subsp\.| ssp\.| auct\.| var\.| s\. l\.| s\.l\.| s\. str\.| s\.str\.|', '', text)
        ## Words<minpatlen
        try:
            words=re.findall(r'[a-zA-ZöäüÖÄÜßâêûôîÂÊÛÔÎéúóáíÉÚÓÁÍèùòàìÈÙÒÀÌîÎçÇËëïÏñõÕãÃ„]+',text)
            #print("words",words)
            for word in words:
                try:
                    #word=unicode(word,"ISO8859-1")
                    #print(len(word),"#",minpatlen+1)
                    for sidx in range(0, len(word)-minpatlen+1):
                        for wlen in range(minpatlen, max(maxpatlen+1,len(word))):
                            if wlen+sidx<len(word)+1 and len(word[sidx:wlen+sidx])<maxpatlen+1:
                                print(word[sidx:wlen+sidx].lower(),'\t',specnr,'\t',len(word[sidx:wlen+sidx]))
                except Exception as e:
                    print(repr(e))
        except Exception as e:
            print(repr(e))
    except Exception as e:
        print(repr(e))
    return

def genupdateIndexTest(text,minpatlen,maxpatlen):
    try:
        text = re.sub(r' sp\.| spec\. | species| gat\.| gen\.| subsp\.| ssp\.| auct\.| var\.| s\. l\.| s\.l\.| s\. str\.| s\.str\.|', '', text)
        ## Words<minpatlen
        try:
            words=re.findall(r'[a-zA-ZöäüÖÄÜßâêûôîÂÊÛÔÎéúóáíÉÚÓÁÍèùòàìÈÙÒÀÌîÎçÇËëïÏñõÕãÃ„]+',text)
            print("words",words)
            for word in words:
                try:
                    #word=unicode(word,"ISO8859-1")
                    print(len(word),"#",minpatlen+1)
                    for sidx in range(0, len(word)-minpatlen+1):
                        for wlen in range(minpatlen, max(maxpatlen+1,len(word))):
                            if wlen+sidx<len(word)+1 and len(word[sidx:wlen+sidx])<maxpatlen+1:
                                print('m1: ',word[sidx:wlen+sidx].lower(),',',len(word[sidx:wlen+sidx]))
                except Exception as e:
                    print(repr(e))
        except Exception as e:
            print(repr(e))
    except Exception as e:
        print(repr(e))
    return

def childsStatisticsJSON(handle,nr):
    try:
        #handle.row_factory = sqlite3.Row
        cursor = handle.cursor(cursor_factory=psycopg2.extras.DictCursor)
        sql="select ZRANK as rang,count(*) as anzahl from \"ZSPEC\" where (length(ZRANK)>0) and (ZAGGS like '%d|%%' or ZAGGS like '%%|%d|%%' or ZAGGS like '%%|%d' or ZAGGS = '%d') group by ZRANK" % (nr,nr,nr,nr)
        #print("%s" % (sql))
        cursor.execute(sql)
        rows = cursor.fetchall()
        rowcount = len(rows)
    except Exception as e:
        print(repr(e))
        return """{"ch":{}}"""
    total = 0
    if rowcount>0:
        res = """{"ch":{"""
    else:
        return """{"ch":{}}"""
    i=1
    for row in rows:
        res = res + "\"%s" % row['rang'] + "\":\"%s" % row['anzahl'] + "\""
        total = total + (int(row['anzahl']))
        if i<rowcount:
            res = res + ","
        i = i+1
    handle.commit()
    res = res + ",\"tt\":" + "\"%d" % total + "\"" + "}}"
    return res

def updateInfo(handle,startnr):
    try:
        #handle.row_factory = sqlite3.Row
        cursor = handle.cursor(cursor_factory=psycopg2.extras.DictCursor)
        ## znr in update Tabelle durchlaufen:
        sql="select ZNR from \"ZSPEC\" where ZNR>='%d' and (length(zchilds)>0) and ((ZINFO is null) or length(ZINFO)=0) order by ZNR" % (startnr)
        #print(sql)
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            nr=row['znr']
            #print("Update für %s" % (nr))
            info = childsStatisticsJSON(handle,nr)
            #print(info)
            info = u"""{"if":{"ct":""" + info + u"""}}"""
            sql="update \"ZSPEC\" set ZINFO = '%s' where ZNR = %d" % (info,nr)
            cursor.execute(sql)
            handle.commit()
    except Exception as e:
        print(repr(e))
    handle.commit()
    return

def roottaxaUpdate(handle,roottaxa):
    try:
        cursor = handle.cursor(cursor_factory=psycopg2.extras.DictCursor)
        roottaxaarray = roottaxa.split(",")
        ## znr in update Tabelle durchlaufen:
        sql="select znr,zaggsranks,zaggs FROM \"ZSPEC\" where znr in (%s)" % (roottaxa)
        cursor.execute(sql)
        rows = cursor.fetchall()
        zaggsdict={}
        zaggsranksdict={}
        count = cursor.rowcount
        for row in rows:
            znr=row['znr']
            zaggsdict[row['zaggs']]=1
            zaggsranksdict[row['zaggsranks'].partition('|')[-1]]=1
        i = 1
        # 1.delete
        sql='delete FROM "ZSPEC" WHERE x_is_synonym=0 AND NOT ('
        for row in rows:
            znr=row['znr']
            zaggsranks=row['zaggsranks']
            zaggs=row['zaggs']
            #print(znr)
            #print(zaggsranks)
            #print(zaggs)
            sql_zaggs_part1 = ''
            sql_zaggs_part2 = ''
            if (len(zaggs) > 0):
                sql_zaggs_part1 = "zaggs='" + zaggs + "' and "
                sql_zaggs_part2 = "|"
            sql = sql + "(" + sql_zaggs_part1 + "znr in (" + roottaxa + "))" + " or zaggs like '%|" + str(znr) + sql_zaggs_part2 +  zaggs + "' or zaggs = '" + str(znr) + sql_zaggs_part2 +  zaggs + "'"
            if (i == count):
                sql = sql + ");"
            else:
                sql = sql + " or\n"
            i=i+1
        cursor.execute(sql)
        handle.commit()
        if (len(zaggs) > 0):
            sql = ""
            # 2.update
            for zagg in zaggsdict.keys():
                sql = sql  +"\nupdate \"ZSPEC\" set zaggs=LEFT(zaggs,-LENGTH('" + zagg + "')) where zaggs = '" + zagg + "';"
                sql = sql  +"\nupdate \"ZSPEC\" set zaggs=LEFT(zaggs,-LENGTH('|" + zagg + "')) where zaggs like '%|" + zagg + "';"
            # 3.sql
            for zaggsrank in zaggsranksdict.keys():
                sql = sql  +"\nupdate \"ZSPEC\" set zaggsranks=LEFT(zaggsranks,-LENGTH('" + zaggsrank + "')) where zaggsranks = '" + zaggsrank + "';"
                sql = sql  +"\nupdate \"ZSPEC\" set zaggsranks=LEFT(zaggsranks,-LENGTH('|" + zaggsrank + "')) where zaggsranks like '%|" + zaggsrank + "';"
            #print(sql)
            cursor.execute(sql)
            handle.commit()
    except Exception as e:
        print(repr(e))
    handle.commit()
    return

def insertSynonyms(handle):
    cursor = handle.cursor(cursor_factory=psycopg2.extras.DictCursor)
    data = []
    sql="SELECT ZNR,ZEN_NAME,ZDE_NAME,ZFR_NAME,ZINFO,ZSYNONYMS FROM \"ZSPEC\" WHERE length(ZRANK)>0 and length(ZSYNONYMS)>0"
    cursor.execute(sql)
    rows = cursor.fetchall()
    handle.commit()
    newInfo = u'';
    rowNr=0
    for row in rows:
        synnrs = row['zsynonyms'].replace('|',',')
        rowNr = row['znr']
        select = 'SELECT ZSCI_NAME,ZEN_NAME,ZDE_NAME,ZFR_NAME FROM "ZSPEC" WHERE ZNR IN (%s)' % synnrs
        cursor.execute(select)
        synspecs = cursor.fetchall()
        handle.commit()
        langsyn={};
        # orig spec
        if len(row['zen_name'])>0:
            if(langsyn.get("en") == None):
                langsyn["en"]=[]
            names = []
            names = row['zen_name'].split('|')
            for name in names:
                langsyn["en"].append(name)
        if len(row['zde_name'])>0:
            if(langsyn.get("de") == None):
                langsyn["de"]=[]
            names = []
            names = row['zde_name'].split('|')
            for name in names:
                langsyn["de"].append(name)
        if len(row['zfr_name'])>0:
            if(langsyn.get("fr") == None):
                langsyn["fr"]=[]
            names = []
            names = row['zfr_name'].split('|')
            for name in names:
                langsyn["fr"].append(name)
        # synonym specs
        for rowsyns in synspecs:
            if len(rowsyns['zsci_name'])>0:
                if(langsyn.get("sci") == None):
                    langsyn["sci"]=[]
                langsyn["sci"].append(rowsyns['zsci_name'])
            if len(rowsyns['zen_name'])>0:
                if(langsyn.get("en") == None):
                    langsyn["en"]=[]
                names = []
                names = rowsyns['zen_name'].split('|')
                for name in names:
                    langsyn["en"].append(name)
            if len(rowsyns['zde_name'])>0:
                if(langsyn.get("de") == None):
                    langsyn["de"]=[]
                names = []
                names = rowsyns['zde_name'].split('|')
                for name in names:
                    langsyn["de"].append(name)
            if len(rowsyns['zfr_name'])>0:
                if(langsyn.get("fr") == None):
                    langsyn["fr"]=[]
                names = []
                names = rowsyns['zfr_name'].split('|')
                for name in names:
                    langsyn["fr"].append(name)
        if len(row['zinfo'])>0:
            #print("Old info: ", row['ZINFO'])
            decoDict=json.JSONDecoder().decode(row['zinfo'])
            decoDict['if']['sy']=langsyn
            newInfo=json.dumps(decoDict,separators=(',',':'), ensure_ascii=False)
        else:
            decoDict=json.JSONDecoder().decode('{"if":{}}')
            #print("No Info")
            decoDict['if']['sy']=langsyn
            newInfo=json.dumps(decoDict,separators=(',',':'), ensure_ascii=False)
        #print("New Info = %s in SpecNr = %d : " % (newInfo,int(rowNr)))
        cursor.execute("update \"ZSPEC\" set ZINFO = %s where ZNR = %s",(newInfo,rowNr))
        handle.commit()
    cursor.execute("update \"ZSPEC\" set ZEN_NAME = trim(split_part(ZEN_NAME,'|',1))")
    cursor.execute("update \"ZSPEC\" set ZFR_NAME = trim(split_part(ZFR_NAME,'|',1))")
    cursor.execute("update \"ZSPEC\" set ZDE_NAME = trim(split_part(ZDE_NAME,'|',1))")
    handle.commit()


##################
# < Helper       #
##################

def deleteBOOKMARKS(handle):
    cursor = handle.cursor()
    cursor.execute('DELETE FROM ZBOOKMARK')
    handle.commit()
    return

def getBOOKMARKS(handle,rank):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    data = []
    sql='SELECT ZNR,ZRANK,ZINFO FROM ZSPEC WHERE ZIS_SYNONYM=0 AND ZRANK="%s"' % (rank)
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        jData = json.loads(row['ZINFO'], object_hook=lambda d: namedtuple('X', d.keys(), rename=True)(*d.values()))
        datarow = (3,0,0,int(row['ZNR']),0,int(jData._0.ct.ch.tt),u"")
        data.append(datarow)
    handle.commit()
    return data

def writeUUID(handle,uuid,metadataversion):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    sql="UPDATE Z_METADATA set (Z_UUID) = (\'" + uuid + "\') WHERE Z_VERSION = " + str(metadataversion)
    try:
        cursor.execute(sql) 
        handle.commit()
    except Exception as e:
        print(repr(e))
    return

def cleanConfig(handle,Z_ENT):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    try:
        sql='DELETE FROM ZBACKBONE'
        cursor.execute(sql)
        handle.commit()
    except Exception as e:
        print(repr(e))
    return

def updatePrimaryKeys(handle,Z_ENT,tablename):
    maxpk=0
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    try:
        sql='SELECT MAX(Z_PK) as maxpk FROM "%s"' % (tablename)
        cursor.execute(sql)
        rows = cursor.fetchall()
        for row in rows:
            maxpk=row[0]
        sql="UPDATE Z_PRIMARYKEY set (Z_MAX) = (" + str(maxpk) + ") WHERE Z_ENT = " + str(Z_ENT)
        cursor.execute(sql)
        handle.commit()
    except Exception as e:
        print(repr(e))
    return

def insertConfig(handle,update,uuid,Z_ENT,ZNR,ZSTATUS,ZPUBLISHED,ZCITATION,ZNAME,ZNAMELANGS,ZNATIVELANG,ZRANKLANGS,ZROOTTAXA,ZSOURCE,ZVERSION,ZINFO):
    localuuid=uuid
    exists = False
    print("old localuuid = %s: " % (localuuid))
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    # select ZUUID
    sql='SELECT ZUUID FROM ZBACKBONE WHERE ZNR="%s"' % (ZNR)
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        localuuid=row['ZUUID']
        print("row localuuid = %s: " % (localuuid))
        print("row row['ZUUID'] = %s: " % (row['ZUUID']))
        exists = True
    # select ZPK
    sql='SELECT Z_MAX FROM Z_PRIMARYKEY WHERE Z_ENT="%s"' % (Z_ENT)
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        nextpk=int(row['Z_MAX'])
    nextpk=nextpk+1
    if not(exists):
        print("not exists localuuid = %s: " % (localuuid))
        try:
            sqltval = str(nextpk) + "," + str(Z_ENT) + "," + "0" + "," + str(ZNR) + "," + str(ZSTATUS) + "," + "strftime(\'%s\',\'" + ZPUBLISHED + "\')-strftime(\'%s\',\'2001-01-01\')" + "," + "\'" + ZCITATION + "\'," + "\'zip\'," + str(ZINFO) + ",\'" + ZNAME + "\',\'" + ZNAMELANGS + "\',\'" + ZNATIVELANG + "\',\'" + ZRANKLANGS + "\',\'" + ZROOTTAXA + "\',\'" + ZSOURCE + "\',\'\'," + "0" + ",\'" + localuuid + "\',\'" + ZVERSION + "\'"
            sql="INSERT INTO ZBACKBONE(Z_PK,Z_ENT,Z_OPT,ZNR,ZSTATUS,ZPUBLISHED,ZCITATION,ZFILETYPE,ZINFO,ZNAME,ZNAMELANGS,ZNATIVELANG,ZRANKLANGS,ZROOTTAXA,ZSOURCE,ZSOURCETYPE,ZSPECSCOUNTER,ZUUID,ZVERSION) VALUES  (" + sqltval + ")"
            cursor.execute(sql) 
            handle.commit()
        except Exception as e:
            print(repr(e))
    if (exists and update):
        print("exists and update localuuid = %s: " % (localuuid))
        try:
            sqltval = str(ZSTATUS) + "," + "strftime(\'%s\',\'" + ZPUBLISHED + "\')-strftime(\'%s\',\'2001-01-01\')" + "," + "\'" + ZCITATION + "\'," + "\'zip\'," + str(ZINFO) + ",\'" + ZNAME + "\',\'" + ZNAMELANGS + "\',\'" + ZNATIVELANG + "\',\'" + ZRANKLANGS + "\',\'" + ZROOTTAXA + "\',\'" + ZSOURCE + "\',\'\'," + "0" + ",\'" + localuuid + "\',\'" + ZVERSION + "\'"
            sql="UPDATE ZBACKBONE set (ZSTATUS,ZPUBLISHED,ZCITATION,ZFILETYPE,ZINFO,ZNAME,ZNAMELANGS,ZNATIVELANG,ZRANKLANGS,ZROOTTAXA,ZSOURCE,ZSOURCETYPE,ZSPECSCOUNTER,ZUUID,ZVERSION) = (" + sqltval + ") WHERE ZNR = " + str(ZNR)
            cursor.execute(sql) 
            handle.commit()
        except Exception as e:
            print(repr(e))
    return localuuid

def writeContentSKUTaxaDBMetadata(handle,metadatafile,iapproductidentifier,iapreferencename,iappkgfilename):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    # select coalesce(sum(json_array_length(zinfo, '$.if.sy.sci')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.en')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.de')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.fr')),0) as synonymscommonnames from "ZSPEC" where length(zinfo)>0;
    sql="select (coalesce(sum(json_array_length(zinfo, '$.if.sy.sci')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.en')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.de')),0) + coalesce(sum(json_array_length(zinfo, '$.if.sy.fr')),0)) as synonymscommonnames from ZSPEC where length(zinfo)>0"
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        synonymscommonnames=row['synonymscommonnames']
    # select count(zsci_name) - 1 as taxa from "ZSPEC";
    sql="select count(zsci_name) - 1 as taxa from ZSPEC"
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        taxa=row['taxa']
    # 611122 Taxa, 259601 Synonyms &amp; Common Names
    iapdescription = str(taxa) + " Taxa, " + str(synonymscommonnames) + " Synonyms & Common Names"
    ET.register_namespace('', "http://apple.com/itunes/importer")
    metadata = ET.parse(metadatafile)
    metadataroot = metadata.getroot()
    metadataroot.find('{http://apple.com/itunes/importer}software/{http://apple.com/itunes/importer}software_metadata/{http://apple.com/itunes/importer}in_app_purchases/{http://apple.com/itunes/importer}in_app_purchase/{http://apple.com/itunes/importer}product_id').text = iapproductidentifier
    metadataroot.find('{http://apple.com/itunes/importer}software/{http://apple.com/itunes/importer}software_metadata/{http://apple.com/itunes/importer}in_app_purchases/{http://apple.com/itunes/importer}in_app_purchase/{http://apple.com/itunes/importer}reference_name').text = iapreferencename
    metadataroot.find('{http://apple.com/itunes/importer}software/{http://apple.com/itunes/importer}software_metadata/{http://apple.com/itunes/importer}in_app_purchases/{http://apple.com/itunes/importer}in_app_purchase/{http://apple.com/itunes/importer}locales/{http://apple.com/itunes/importer}locale[@name="de-DE"]/{http://apple.com/itunes/importer}title').text = iapreferencename
    metadataroot.find('{http://apple.com/itunes/importer}software/{http://apple.com/itunes/importer}software_metadata/{http://apple.com/itunes/importer}in_app_purchases/{http://apple.com/itunes/importer}in_app_purchase/{http://apple.com/itunes/importer}locales/{http://apple.com/itunes/importer}locale[@name="de-DE"]/{http://apple.com/itunes/importer}description').text = iapdescription
    metadataroot.find('{http://apple.com/itunes/importer}software/{http://apple.com/itunes/importer}software_metadata/{http://apple.com/itunes/importer}in_app_purchases/{http://apple.com/itunes/importer}in_app_purchase/{http://apple.com/itunes/importer}software_assets/{http://apple.com/itunes/importer}asset/{http://apple.com/itunes/importer}data_file/{http://apple.com/itunes/importer}file_name').text = iappkgfilename
    metadata.write(metadatafile,xml_declaration=True)

def writeContentInfo(conteninfofile,iapproductidentifier,iapcontentversion):
    info = {}
    with open(conteninfofile, 'rb') as source:
        info = plistlib.load(source,fmt=plistlib.FMT_XML)
        info["ContentVersion"]=iapcontentversion
        info["IAPProductIdentifier"]=iapproductidentifier
        source.close()
    with open(conteninfofile, 'wb') as target:
        plistlib.dump(info,target,fmt=plistlib.FMT_XML,sort_keys=True)
        target.close()
    return

def writeDBInfo(handle,dbinfofile,targetdbinfofile,size,nr,name,modelversion,tsource,namelangs,nativelangs,ranklangs,roottaxa,uuid,citation,version,published,purchaseid):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    # select COUNT(SPEC)
    sql='SELECT COUNT(*) AS taxa FROM ZSPEC'
    cursor.execute(sql)
    rows = cursor.fetchall()
    for row in rows:
        taxa=row['taxa']

    with open(dbinfofile, 'rb') as source, open(targetdbinfofile, 'wb') as target:
        info = plistlib.load(source,fmt=plistlib.FMT_XML)
        info["nr"]=nr
        info["name"]=name
        info["modelversion"]=str(modelversion)
        info["source"]=tsource
        info["namelangs"]=namelangs
        info["nativelang"]=nativelangs
        info["ranklangs"]=ranklangs
        info["roottaxa"]=roottaxa
        info["uuid"]=uuid
        info["citation"]=citation
        info["version"]=str(version)
        info["published"]=published
        info["taxa"]=taxa
        info["size"]=size
        info["purchaseid"]=purchaseid
        plistlib.dump(info,target,fmt=plistlib.FMT_XML,sort_keys=True)
        source.close()
        target.close()
    return

def insertBOOKMARK(handle,data):
    handle.row_factory = sqlite3.Row
    cursor = handle.cursor()
    for row in data:
        cursor.execute('INSERT INTO ZBOOKMARK(Z_ENT, Z_OPT, ZHERBAR, ZNR, ZSELECTED, ZTOTAL, ZAGGS) VALUES (?, ?, ?, ?, ?, ?, ?)', row)
    handle.commit()
    return

##################
# ITIS >         #
##################

##################
# < ITIS         #
##################

##################
# GERMANSL >     #
##################

##################
# < GERMANSL     #
##################