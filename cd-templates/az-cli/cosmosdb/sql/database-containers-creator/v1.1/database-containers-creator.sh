#!/bin/bash

# Initialize variables
# Command to invoke the script: 
# database-containers-creator.sh -DB_CONTAINER_METADATA_JSON_FILE_PATH <db container metadata json file path> -SUBSCRIPTION_ID <subscription id> -RESOURCE_GROUP_NAME <resource group name> -COSMOSDB_ACCOUNT_NAME <cosmosDB account name> -POLICY_FILE_PATH_PREFIX <policy file path prefix>

# All the paths to be given as relative path
DB_CONTAINER_METADATA_JSON_FILE_PATH=""
SUBSCRIPTION_ID=""
RESOURCE_GROUP_NAME=""
COSMOSDB_ACCOUNT_NAME=""
# POLICY_FILE_PATH_PREFIX=""

# Loop through the arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -DB_CONTAINER_METADATA_JSON_FILE_PATH)
      shift
      DB_CONTAINER_METADATA_JSON_FILE_PATH="$1"
      ;;
    -SUBSCRIPTION_ID)
      shift
      SUBSCRIPTION_ID="$1"
      ;;
    -RESOURCE_GROUP_NAME)
      shift
      RESOURCE_GROUP_NAME="$1"
      ;;
    -COSMOSDB_ACCOUNT_NAME)
      shift
      COSMOSDB_ACCOUNT_NAME="$1"
      ;;
    *)
      echo "Unknown option: [$1]. Following are the arguments expected =>  '-DB_CONTAINER_METADATA_JSON_FILE_PATH', '-SUBSCRIPTION_ID', '-RESOURCE_GROUP_NAME', '-COSMOSDB_ACCOUNT_NAME'"
      exit 1
      ;;
  esac
  shift
done

echo "dBContainerMetadatajsonFilePath = [$DB_CONTAINER_METADATA_JSON_FILE_PATH]"
echo "subscriptionId = [$SUBSCRIPTION_ID]"
echo "resourceGroupName = [$RESOURCE_GROUP_NAME]"
echo "cosmosDBAccountName = [$COSMOSDB_ACCOUNT_NAME]"
# echo "policyFilePathPrefix= [$POLICY_FILE_PATH_PREFIX]"

# Set the active subscription
az account set --subscription $SUBSCRIPTION_ID

# Read the JSON file
dbContainerMetadata=$(cat $DB_CONTAINER_METADATA_JSON_FILE_PATH)

# Extract the databases array
databases=$(echo "${dbContainerMetadata}" | jq -r '.databases[] | @base64')

# Loop through the databases array and extract the database name and containers array
for db in $databases; do
    dbName=$(echo ${db} | base64 --decode | jq -r '.name')
    sharedThroughput=$(echo ${db} | base64 --decode | jq -e '.sharedThroughput')
    autoscale=$(echo ${db} | base64 --decode | jq -e '.autoscale // empty')

    # Default values if not provided
    throughput="--throughput 400 "
    maxThroughput="--max-throughput 4000 "

    if [ "$sharedThroughput" = "true" ]; then
        echo "Shared Throughput is set to true."
        if [ "$autoscale" = "true" ]; then
            if [ -n "$(echo ${db} | base64 --decode | jq -r '.maxThroughput // empty')" ]; then
                maxThroughput="--max-throughput $(echo ${db} | base64 --decode | jq -r '.maxThroughput') "
            fi
            throughput=""
            echo "Creating database [${dbName}] with max-throughput [$maxThroughput] as autoscale is set to true"
        else
            if [ -n "$(echo ${db} | base64 --decode | jq -r '.throughput // empty')" ]; then
                throughput="--throughput $(echo ${db} | base64 --decode | jq -r '.throughput') "
            fi
            maxThroughput=""
            echo "Creating database [${dbName}] with throughput [$throughput] as autoscale is set to false"
        fi
        az cosmosdb sql database create --resource-group $RESOURCE_GROUP_NAME --account-name $COSMOSDB_ACCOUNT_NAME --name $dbName $maxThroughput$throughput
    else
        if [ "$autoscale" = "true" ]; then
            if [ -n "$(echo ${db} | base64 --decode | jq -r '.maxThroughput // empty')" ]; then
                echo "Shared Throughput is set to false, no need to provide autoscale and maxThroughput"
            fi
        else
            if [ -n "$(echo ${db} | base64 --decode | jq -r '.throughput // empty')" ]; then
                echo "Shared Throughput is set to false, no need to provide throughput"
            fi
        fi
        echo "Creating database [${dbName}] without throughput or maxThroughput as sharedThroughput is set to false."
        az cosmosdb sql database create --resource-group $RESOURCE_GROUP_NAME --account-name $COSMOSDB_ACCOUNT_NAME --name $dbName
    fi

    containers=$(echo ${db} | base64 --decode | jq -r '.containers[] | @base64')

    for container in $containers; do
        containerName=$(echo ${container} | base64 --decode | jq -r '.name')
        partitionKeyPath=$(echo ${container} | base64 --decode | jq -r '.partitionKeyPath')
        containerAutoscale=$(echo ${container} | base64 --decode | jq -e '.autoscale // empty')
        containerThroughput="--throughput 400 "
        containerMaxThroughput="--max-throughput 4000 "
        indexingPolicy=$(echo ${container} | base64 --decode | jq -e 'has("indexingPolicy") // empty')

        if [ "$sharedThroughput" = "false" ]; then
            echo "Shared Throughput was set to false."
            if [ "$containerAutoscale" = "true" ]; then
                if [ -n "$(echo ${container} | base64 --decode | jq -r '.maxThroughput // empty')" ]; then
                    containerMaxThroughput="--max-throughput $(echo ${container} | base64 --decode | jq -r '.maxThroughput') "
                    containerThroughput=""
                fi
                echo "Creating container [${containerName}] with max-throughput [$containerMaxThroughput] as autoscale is set to true"
            else
                if [ -n "$(echo ${container} | base64 --decode | jq -r '.throughput // empty')" ]; then
                    containerThroughput="--throughput $(echo ${container} | base64 --decode | jq -r '.throughput') "
                    containerMaxThroughput=""
                fi
                echo "Creating container [${containerName}] with throughput [$containerThroughput] as autoscale is set to false"
            fi
            if [ "$indexingPolicy" = "true" ]; then
                indexingPolicy="--idx $(echo ${container} | base64 --decode | jq -r '.indexingPolicy | tostring') "
                echo "Creating container with inline indexing Policy: [${containerName}] in database: [${dbName}]"
            else
                echo "No indexing policy found, creating container without indexing policy"
                indexingPolicy=""
            fi
            az cosmosdb sql container create --account-name $COSMOSDB_ACCOUNT_NAME --database-name $dbName --resource-group $RESOURCE_GROUP_NAME --name $containerName --partition-key-path $partitionKeyPath $containerMaxThroughput$containerThroughput$indexingPolicy
        else
            echo "Shared Throughput was set to true, ignoring values for autoscale, maxThroughput, and throughput for the container."
            if [ "$indexingPolicy" = "true" ]; then
                indexingPolicy="--idx $(echo ${container} | base64 --decode | jq -r '.indexingPolicy | tostring') "
                echo "Creating container with inline indexing Policy: [${containerName}] in database: [${dbName}]"
            else
                echo "No indexing policy found, creating container without indexing policy"
                indexingPolicy=""
            fi
            az cosmosdb sql container create --account-name $COSMOSDB_ACCOUNT_NAME --database-name $dbName --resource-group $RESOURCE_GROUP_NAME --name $containerName --partition-key-path $partitionKeyPath $indexingPolicy
        fi

        echo "**********************"
        echo "Container Name: [${containerName}]"
        echo "Partition Key Path: [${partitionKeyPath}]"
        echo "Container Throughput: [${containerThroughput}]"
        echo "**********************"
    done
done
