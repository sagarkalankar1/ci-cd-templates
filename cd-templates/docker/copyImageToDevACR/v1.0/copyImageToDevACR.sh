# The purpose of this script is to Copy Image from SandBox ACR [lnosdevops] to DevTest ACR [lnosdvopscrdev]. The 'sourceACRHost' is pointing to the Sandbox ACR and 'destinationACRHost' is pointing to the DevTest ACR.

# Initialising Variables.
sourceACRHost="lnosdevops.azurecr.io"
destinationACRHost="lnosdvopscrdev.azurecr.io"

sourceImageRepo=""
sourceImageTag=""
destinationImageRepo=""
destinationImageTag=""


while [ "$#" -gt 0 ]; do
  case "$1" in
    -sourceImageRepo)
      shift
      sourceImageRepo="$1"
      ;;
    -sourceImageTag)
      shift
      sourceImageTag="$1"
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
      echo "Unknown option: [$1]. Following are the arguments expected => '-sourceImageRepo', '-sourceImageTag'. optional: '[-destinationImageRepo]' , '[-destinationImageTag]'"
      exit 1
      ;;
  esac
  shift
done

validInput=("sourceImageRepo" "sourceImageTag")

for input in "${validInput[@]}"; do
  if [ -z "${!input}" ]; then
    echo "Error: $input flag is required"
    exit 1
  fi
done

# Handling default values for "destinationImageRepo" and "destinationImageTag".
if [ -z "$destinationImageRepo" ]; then
  destinationImageRepo="${sourceImageRepo}"
fi
if [ -z "$destinationImageTag" ]; then
  destinationImageTag="${sourceImageTag}"
fi

echo "Destination Image Tag: $destinationImageTag"

# Invoking Generic script "copyImage.sh".
source ci-cd-templates/cd-templates/docker/acr/copyImage/v1.0/copyImage.sh \
    -sourceACRHost "$sourceACRHost" \
    -sourceImageRepo "$sourceImageRepo" \
    -sourceImageTag "$sourceImageTag" \
    -destinationACRHost "$destinationACRHost" \
    -destinationImageRepo "$destinationImageRepo" \
    -destinationImageTag "$destinationImageTag" \