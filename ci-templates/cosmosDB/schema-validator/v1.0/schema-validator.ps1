param (
    [string]$filePathPrefix
)
pwsh --version
# Attempt to install the Test-Json module
try {
    Install-Module -Name Test-Json -Force -Scope CurrentUser -ErrorAction Stop
}
catch {
    Write-Host "Failed to install Test-Json module. Using alternative approach."
}

Write-Host $filePathPrefix
$jsonFilePath = "$filePathPrefix\database-containers-metadata.json"
$schemaFiles = @(
    "$filePathPrefix\auto-scale-db-schema.json",
    "$filePathPrefix\fixed-db-schema.json",
    "$filePathPrefix\auto-scale-container-schema.json",
    "$filePathPrefix\fixed-container-schema.json"
)

$successCount = 0

$jsonContent = Get-Content $jsonFilePath -Raw

# Validating each Database Object against each Schema File.
foreach ($database in $jsonContent | ConvertFrom-Json | Select-Object -ExpandProperty databases) {
    foreach ($schemaFile in $schemaFiles){
        try {
            $jsonObject = $database | ConvertTo-Json
            # Testing Json with schema file.
            Test-Json -json $jsonObject -SchemaFile $schemaFile
            Write-Host "Validation passed for [$database] against [$schemaFile]."
            $successCount++
        }
        catch {
            Write-Host "Validation failed for [$database] against [$schemaFile]."
            Write-Host "Error details: [$_]"
        }
    }
    if ($successCount -eq 1) {
        Write-Host "Validation passed for only one schema."
    }
    else {
        Write-Host "Validation failed for [$database]."
        exit 1
    }
    $successCount = 0
}
