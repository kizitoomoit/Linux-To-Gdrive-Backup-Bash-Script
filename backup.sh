#!/bin/bash

# Variables which are set on the environment variables
WEBSITE_DIR="$WEBSITE_DIR"
BACKUP_DIR="$BACKUP_DIR"
DATE="$(date +\%Y-\%m-\%d_\%H:\%M:\%S)"
WEBSITE_NAME="$WEBSITE_NAME"
ZIP_FILENAME="$WEBSITE_NAME _website_backup_$DATE.zip"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
DB_DUMP_FILENAME="database_backup_$DATE.sql"

# Function to check if a command is available

command_exist() {
  command -v "$1" >/dev/null 2>$1
}

# Check if zip is installed, and install it if not
if command_exist zip; then
  echo "Zip is installed!" | curl -d @- ntfy.sh/My-Backups

 if ! command_exist zip; then
   echo "Zip is not installed Installing..."
   curl -d "zip is not installed on $WEBSITE_NAME Server Installing..." ntfy.sh/My-Backups
   if [ -x "$(command -v apt-get)" ]; then
     # Debian/Ubuntu
     sudo apt-get update
     sudo apt-get instll -y zip
   elif [ -x "$(command -v yum)" ]; then
     # CentOS/RHEL
     sudo yum install -y zip
   elif [ -x "$(command -v brew)" ]; then
     # macOS with Homebrew
     brew install zip
   else
     echo "Unsupported package manager. Please install zip manually." | curl -d @- ntfy.sh/My-Backups
     #curl -d "Unsupported package manager. Please install zip manually." ntfy.sh/My-Backups
   fi
 fi
fi


# Create the backup directory if it does not exist
mkdir -p "$BACKUP_DIR"

# Dump the MYSQL database
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_DIR/$DB_DUMP_FILENAME"

# Move website files to the backup directory
cp -r "$WEBSITE_DIR" "$BACKUP_DIR"


# Archive both website files and the SQL dump file
zip -r "$BACKUP_DIR/$ZIP_FILENAME" "$BACKUP_DIR/$(basename $WEBSITE_DIR)" "$BACKUP_DIR/$DB_DUMP_FILENAME"

# Zip the website directory
#cd "$WEBSITE_DIR" && zip -r "$BACKUP_DIR/$ZIP_FILENAME" . "$BACKUP_DIR/$DB_DUMP_FILENAME"

# Print a message
echo "Website directory and database ziped as $ZIP_FILENAME" | curl -d @- ntfy.sh/My-Backups


gdrive files upload --parent ID "$BACKUP_DIR/$ZIP_FILENAME"
curl -d "$WEBSITE_NAME website Backup Successful on $DATE" ntfy.sh/My-Backups
