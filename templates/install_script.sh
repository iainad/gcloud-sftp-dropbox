#!/usr/bin/env bash

# startup script template (will be used to create an actual startup script by the deploy script)

# NOTE in this script entries starting `REPLACE_ME_` will be automatically
# replaced with appropriate content when the actual startup script is created

# setup variables
SFTP_USER_GROUP=sftp
SFTP_USER=REPLACE_ME_WITH_SFTP_USER
PATH_TO_GCS_BUCKET="/home/$SFTP_USER/droparea"

# get the dirname this script is in so we know where we are
SCRIPT_DIR=$(dirname "$0")

# add the extras to the sshd_config file if they are not there already
FILE='/etc/ssh/sshd_config'
echo "REPLACE_ME_WITH_SSH_ADDITIONS_FILE" | while read LINE
do
   sudo grep -qxF -- "$LINE" "$FILE" || sudo echo "$LINE" >> "$FILE"
done

# now ensure passwords are allowed
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' $FILE

# now restart the SSH service
sudo service ssh restart

# get the FUSE repo
export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s`
echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# do an update
sudo apt-get update

# install unattended updates
sudo apt-get install -y unattended-upgrades

# install gcsfuse
sudo apt-get -y install gcsfuse

# ensure the SFTP_USER_GROUP group exists
if ! id -g $SFTP_USER_GROUP> /dev/null 2>&1; then
  sudo groupadd $SFTP_USER_GROUP
fi

# create the user if they don't exist
if ! id -u $SFTP_USER> /dev/null 2>&1; then
  sudo useradd -m -g $SFTP_USER_GROUP $SFTP_USER
  # if the user still doesn't eist stop the script
  if ! id -u $SFTP_USER> /dev/null 2>&1; then
    logger "Could not create $SFTP_USER. Script terminating."
    exit 999
  else
    logger "User $SFTP_USER created"
  fi
else
  logger "User $SFTP_USER already exists"
fi

# now set the users password based on the one stored
echo -e "REPLACE_ME_WITH_SFTP_PASSWORD\nREPLACE_ME_WITH_SFTP_PASSWORD" | sudo passwd $SFTP_USER

# become the user & create the mount point
sudo su -c "mkdir -p $PATH_TO_GCS_BUCKET" $SFTP_USER

# mount the bucket (ok to do this on restart also, saves having to add an entry to the /etc/fstab file to auto mlount
sudo su -c "gcsfuse REPLACE_ME_WITH_GCS_BUCKET $PATH_TO_GCS_BUCKET" $SFTP_USER
