# GCS Storage Bucket SFTP Server

Script to build and deploy an SFTP server which can be used to drop files onto or pull files from a Google Cloud bucket


`.env` or `.env.<environment-name>` file needs the following variables defined to run successfully:

```
SFTP_USER=<user we'll use to sftp into the box as>
SFTP_PASSWORD=<password to be used by the user>
DROPBOX_NAME=<name of the app used to name gcloud resources>
PROJECT_NAME=<gcloud project name>
REGION=<region>
ZONE=<zone>
MACHINE_TYPE=<machine type> 
```

To create and deploy the VM use the following command from the root folder:

```
bin/deploy <environment-name>
```

To deploy a staging instance, use 

```
bin/deploy
```

If the environemnt is `production` the deploy script also reserves an IP address for the instance use so it can remain static after the deploy and if redeployed. To deploy a production version use:

```
bin/deploy production
```

Note keeping the IP address can cause SSH fingerprint issues with systems that can't clear info in their `known_hosts` files so if this is the case the reserved IP will have to be dropped if the production instance is deleted and recreated.

The deploy script will also update the startup script and re-run with any changes that have been made if the instance already exists.
