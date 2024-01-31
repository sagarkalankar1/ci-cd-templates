# Purpose: This script accepts the source Image and destination Image details, pulls image from source ACR and tags it to the destination ACR.

# Initialising Variables.
sourceACRHost=""
sourceImageRepo=""
sourceImageTag=""
destinationACRHost=""
destinationImageRepo=""
destinationImageTag=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -sourceACRHost)
      shift
      sourceACRHost="$1"
      ;;
    -sourceImageRepo)
      shift
      sourceImageRepo="$1"
      ;;
    -sourceImageTag)
      shift
      sourceImageTag="$1"
      ;;
    -destinationACRHost)
      shift
      destinationACRHost="$1"
      ;;
    -destinationImageRepo)
      shift
      destinationImageRepo="$1"
      ;;
    -destinationImageTag)
      shift
      destinationImageTag="$1"
      ;;
    *)
      echo "Unknown option: [$1]. Following are the arguments expected =>  '-sourceACRHost', '-sourceImageRepo', '-sourceImageTag', '-destinationACRHost' '-destinationImageRepo' '-destinationImageTag'"
      exit 1
      ;;
  esac
  shift
done

# ["sourceACRHost" "sourceImageRepo" "sourceImageTag" "destinationACRHost" "destinationImageRepo" "destinationImageTag"] => these flags are mandatory
validInput=("sourceACRHost" "sourceImageRepo" "sourceImageTag" "destinationACRHost" "destinationImageRepo" "destinationImageTag")

for input in "${validInput[@]}"; do
  if [ -z "${!input}" ]; then
    echo "Error: $input flag is required"
    exit 1
  fi
done

echo "Source ACR set to [$sourceACRHost]"
echo "Source Image Repository set to [$sourceImageRepo]"
echo "Source Image Tag set to [$sourceImageTag]"
echo "Destination ACR Host set to [$destinationACRHost]"
echo "Destination Image Repository set to [$destinationImageRepo]"
echo "Destination Image Tag set to [$destinationImageTag]"

sourceImage="${sourceACRHost}/${sourceImageRepo}:${sourceImageTag}"

echo "Source Image: $sourceImage"

# Pull image from Source ACR
docker pull "$sourceImage"

destinationImage="${destinationACRHost}/${destinationImageRepo}:${destinationImageTag}"
echo "Destination Image: $destinationImage"

# Set pipeline variable for later steps
echo "##vso[task.setvariable variable=destinationImageRepo]$destinationImageRepo"
echo "##vso[task.setvariable variable=destinationImageTag]$destinationImageTag"

echo "Creating new Docker tag"
docker tag "$sourceImage" "$destinationImage"
echo "New Docker Tag created"