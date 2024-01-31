# The script aims to retrieve the image tag generated during an application build process and published as a build artifact to be used as deployable image tag in respective env during CD pipeline execution.
# Confluence Page: https://lennar.atlassian.net/wiki/spaces/PLAT/pages/761397263/read-tag-artifact+v1.0

#!/bin/bash

# Initialising variable.
buildArtifactPath="buildArtifact/TagArtifact/tag.txt"

while [ "$#" -gt 0 ]; do
  case "$1" in
    -buildArtifactPath)
      shift
      buildArtifactPath="$1"
      ;;
    *)
      echo "Unknown option: [$1]. Optional Arguments: [-buildArtifactPath]"
      exit 1
      ;;
  esac
  shift
done

# Checking whether build artifact path follows the convention or not.
if [ "$buildArtifactPath" != "buildArtifact/TagArtifact/tag.txt" ]; then
    echo "The standard convention of having build artifact path: [buildArtifact/TagArtifact/tag.txt] is not being followed."
fi

echo "Reading the image tag from [$buildArtifactPath]."

# Reading the image tag from the artifact and setting it to the variable to use it for later steps.
tagFilePath="$SYSTEM_DEFAULTWORKINGDIRECTORY/$buildArtifactPath"
tag=$(cat "$tagFilePath")
finalTagValue="##vso[task.setvariable variable=ReleaseTag]$tag"
echo "$finalTagValue"