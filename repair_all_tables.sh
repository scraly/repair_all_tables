#!/bin/sh
###########################################################
## RFI : 2004-12-24
# Script qui repare toutes les tables de 
# toutes les databases d'une base de donnees
############################################################
###########Pre-requis######################################
#- atchik_profile avec la variable ${HOME} 
#- repertoire tmp dans le home sirectory du compte qui lance le script
#- repertoire logs dans le home directory du compte qui lance le script
################################################################ 

DATABASE_FILE=${HOME}/tmp/tmp_database215454.txt
TABLE_FILE=${HOME}/tmp/tmp_table215454.txt
LOG_FILE=${HOME}/logs/repair_all_tables.log

### Parametre MYSQL ####
MYSQL_HOST="localhost"
#MYSQL_SOCKET="/home/goncalvesj/tmp/atchik_mysqld.sock"
MYSQL_PORT="3306"
MYSQL_USER="root"
MYSQL_PASSWORD="tbc2spome4u"



####### FUNCTIONS#############

Show_databases () {
	if [ "x""${MYSQL_SOCKET}" == "x" ]
        then
       	   mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -N -e "show databases" > ${DATABASE_FILE}
	else
           mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} --socket=${MYSQL_SOCKET} -N -e "show databases" > ${DATABASE_FILE}
	fi
}


Repair_tables_in_database () {

   for DATABASE in `cat ${DATABASE_FILE}`
   do
      if [ "x""${MYSQL_SOCKET}" == "x" ]
      then
	mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -N -e "use ${DATABASE}; show tables" > ${TABLE_FILE}
      else
        mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} --socket=${MYSQL_SOCKET} -N -e "use ${DATABASE}; show tables" > ${TABLE_FILE}
      fi
      for TABLE in `cat ${TABLE_FILE}` 
      do
 	if [ "x""${MYSQL_SOCKET}" == "x" ]
        then
        echo "`date +'%d%m%y %H:%M:%S'` : " `mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -h ${MYSQL_HOST} -P ${MYSQL_PORT} -N -e "use ${DATABASE}; repair table ${TABLE}"` >> ${LOG_FILE}
	else
        echo "`date +'%d%m%y %H:%M:%S'` : " `mysql -u ${MYSQL_USER} -p${MYSQL_PASSWORD} --socket=${MYSQL_SOCKET} -h ${MYSQL_HOST} -N -e "use ${DATABASE}; repair table ${TABLE}"` >> ${LOG_FILE}
	fi
      done 		
   done
}

Remove_all_tmp_files () {
	rm -f ${TABLE_FILE} ${DATABASE_FILE}
}


#########MAIN##############

echo "******* DEBUT : `date` *******" >> ${LOG_FILE}
Show_databases
Repair_tables_in_database
Remove_all_tmp_files
echo "******* FIN : `date` *********" >> ${LOG_FILE}
