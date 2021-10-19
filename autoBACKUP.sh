#!/usr/bin/bash

containername=$1
databasename=$2

if [ -z $containername ]
then
	echo "Usage: $0 [container name] [database name]"
	exit 1
fi

if [ -z $databasename ]
then
	echo "Usage: $0 [container name] [database name]"
	exit 1
fi

#bash will exit if command fails
set -e
set -o pipefail

#create a filename for the backup using date YYYY-mm-dd_HH:MM:SS
filename=$( date +%Y-%m-%d_%H:%M:%S .$databasename.bak )

#to ensure back up folder exists & create if it doesnt exist
mkdir -p "./backups"

echo "Backing up database '$databasename' from container '$containername'..."

#creating a database using sqlcmd

docker exec -it "$containername" /opt/mssql-tools/bin/sqlcmd -b -V16 -S localhost -U SA -Q "BACKUP DATABASE [$databasename] TO DISK=N'/var/opt/mssql/backups/$filename' with NOFORMAT, NOINIT, NAME = '$databasename-full', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

echo ""
echo "exporting file from container..."

#copy the created file out of the container to the host file system
docker cp $containername:/var/opt/mssql/backups/$filename ./backups/$filename

echo "Backed up database '$databasename' to ./backups/$filename"
echo "Done!"


