param ($yamlFilePath, $apimResourceGroup, $apimName, $apiId)

Install-Module powershell-yaml -force
Import-Module powershell-yaml


# Read the contents of the YAML file
$yamlContent = Get-Content $yamlFilePath -Raw
$yamlObjects = ConvertFrom-Yaml $yamlContent

# Now $yamlObjects will contain the extracted objects from the YAML file
Write-Host "Extracted objects from the YAML file:"
$yamlObjects

# Example: Access specific properties of the objects
foreach ($object in $yamlObjects) {
    # Create Context for API Management Policy command, can be interpreted as APIM ID Generator
    $apimContext = New-AzApiManagementContext -ResourceGroupName $apimResourceGroup -ServiceName $apimName
    #
    # Attach API Operation Level Policy
    Set-AzApiManagementPolicy -Context $apimContext -ApiId $apiId -OperationId $($object.operationId) -Format $($object.format) -PolicyFilePath $($object.filePath)
}


