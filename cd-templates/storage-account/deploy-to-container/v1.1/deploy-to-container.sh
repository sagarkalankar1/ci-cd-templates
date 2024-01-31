#!/bin/bash

# Purpose: 
#   Deploy a any kind of file to an Azure Storage Account Blob container.

# Parameters:
#   - storageAccountName (String): Azure Storage Account Name
#   - storageAccountResourceGroup (String): Azure resource group name
#   - containerName (String): Storage container for script upload
#   - fileName (String): Name for the script in the Storage Account
#   - sourcePath (String): Absolute file path of the file.

# Usage:
#   deploy-script.sh --storageAccountName <name> --storageAccountResourceGroup <group> --containerName <container> --fileName <name> --sourcePath <path>


# All the paths to be given as relative path
storageAccountResourceGroup=""
storageAccountName=""
containerName=""
sourcePath=""
fileName=""


# Loop through the arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -storageAccountName)
      shift
      storageAccountName="$1"
      ;;
    -storageAccountResourceGroup )
      shift
      storageAccountResourceGroup="$1"
      ;;
    -containerName)
      shift
      containerName="$1"
      ;;
    -fileName)
      shift
      fileName="$1"
      ;;
    -sourcePath)
      shift
      sourcePath="$1"
      ;;
    *)
      echo "Unknown option: [$1]. Following are the arguments expected =>  '--storageAccountName', '--storageAccountResourceGroup ', '--containerName', '--fileName', '--sourcePath'"
      exit 1
      ;;
  esac
  shift
done

echo "Resource Group: [$storageAccountResourceGroup]"
echo "Storage Account Name: [$storageAccountName]"
echo "Container Name: [$containerName]"
echo "Source Path of file: [$sourcePath]"
echo "File Name: [$fileName]"

# Retrieve Storage Account Key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$storageAccountResourceGroup" \
  --account-name "$storageAccountName" \
  --query "[0].value" \
  --output tsv | tr -d '"')

# Upload the Bash script file to the storage account blob
az storage blob upload \
  --account-name "$storageAccountName" \
  --account-key "$STORAGE_ACCOUNT_KEY" \
  --container-name "$containerName" \
  --name "$fileName" \
  --type block \
  --content-type "text/plain" \
  --file "$sourcePath"

# Display the upload message
echo "File upload complete."
