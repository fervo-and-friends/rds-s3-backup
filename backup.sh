#!/bin/bash

########
# MySQL RDS -> S3 backup
#
# This commands runs mysqldump, bzips the dump and saves it to S3 in a timestamped file. It always connects over SSL.
#
# Arguments:
# * databasename
#
# Environment variables
#
# * MYSQL_HOST
# * MYSQL_USER
# * MYSQL_PASSWORD
# * S3_PATH
# * AWS_ACCESS_KEY_ID – AWS access key.
# * AWS_SECRET_ACCESS_KEY – AWS secret key.
# * AWS_DEFAULT_REGION – AWS region.
#
########

# Basic variables
db="$1"

# Timestamp (sortable AND readable)
stamp=`date +"%s - %A %d %B %Y @ %H%M"`

# Define our filenames
filename="$db - $stamp.sql.bz2"
tmpfile="/tmp/$filename"
object="$S3_PATH/$stamp/$filename"

# Feedback
echo -e "\e[1;34m$db\e[00m"

# Dump and zip
echo -e "  creating \e[0;35m$tmpfile\e[00m"
mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_HOST --ssl-ca=/app/rds-combined-ca-bundle.pem --force --opt --databases "$db" | bzip2 -c > "$tmpfile"

# Upload
echo -e "  uploading..."
aws cp "$tmpfile" "$object"

# Delete
rm -f "$tmpfile"

# Jobs a goodun
echo -e "\e[1;32mDone\e[00m"