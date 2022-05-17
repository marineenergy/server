#!/bin/bash
  
DATABASE=gis
DB_HOST=postgis
DB_USER=admin
DB_PASS=`head -n 1 /share/.password_mhk-env.us`

# Capture starting timestamp
TIMESLOT=`date +%Y_%m_%d.%H_%M`
printf "[$TIMESLOT] START ...................... pg_backup\n"
printf "[$TIMESLOT] TIMESLOT ................... $TIMESLOT\n"

# Location to place local backup
BACKUP_DIR=/home/admin/pg_backup_tmp/backups
printf "[$TIMESLOT] BACKUP_DIR ................. $BACKUP_DIR\n"

# Locations to place the backup tarball
TARBALL_FOLDER=$BACKUP_DIR/pg_tarballs
printf "[$TIMESLOT] TARBALL_FOLDER ..... $TARBALL_FOLDER\n"

# cd to the backup dir 
cd $BACKUP_DIR

printf "[$TIMESLOT] Processing db .............. $DATABASE\n"
TIMEINFO=`date '+%T'`
export PGPASSWORD=$DB_PASS; /usr/bin/pg_dump -Fc -U $DB_USER -h $DB_HOST $DATABASE > $TIMESLOT.$DATABASE.pgdb
printf "[$TIMESLOT] Backup complete ............ at $TIMEINFO\n"
printf "[$TIMESLOT] Temp dump created as ....... $TIMESLOT.$DATABASE.pgdb\n"
printf "[$TIMESLOT]\n"

# Tar-up the database dump
printf "[$TIMESLOT] Creating tarball ........... $TIMESLOT.tar.gz\n"
tar -zcvf $TIMESLOT.tar.gz $TIMESLOT.*
printf "[$TIMESLOT]\n"

# If the tarball exists...
if [ ! -f $TIMESLOT.tar.gz ]; then
    printf "[$TIMESLOT] ERROR: Unable to create the tarball\n"
else
    TARBALL_ATTRIBUTES=`ls -l --color='never' $TIMESLOT.tar.gz`
    printf "[$TIMESLOT] Tarball created ............ $TARBALL_ATTRIBUTES\n"

    # Remove the tmp backup files
    printf "[$TIMESLOT] Removing tmp files ......... *.pgdb\n"
    rm *.pgdb

    # Copy tarball to backup destination
    printf "[$TIMESLOT] Copying tarball to ......... $TARBALL_FOLDER\n"
    START_CP=`date +%Y_%m_%d.%H_%M_%S`
    printf "[$TIMESLOT] Start tarball cp ........... $START_CP\n"
    cp $TIMESLOT.tar.gz $TARBALL_FOLDER
    END_CP=`date +%Y_%m_%d.%H_%M_%S`
    printf "[$TIMESLOT] End tarball cp ............. $END_CP\n"

    # If the tarball cp failed...
    if [ ! -f $TARBALL_FOLDER/$TIMESLOT.tar.gz ]; then
        printf "[$TIMESLOT] ERROR: Unable to cp the backup tarball to destination\n"
    else
        # tarball cp successful
        printf "[$TIMESLOT] Tarball cp ................. successful\n"

        # remove from temp dir
        printf "[$TIMESLOT] Removing tarball from temp directory\n"
        rm $TIMESLOT.tar.gz
    fi
fi