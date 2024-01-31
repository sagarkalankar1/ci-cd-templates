# Azure pipeline templates
As a development team, we have noticed that our CD process in Azure YAML pipeline is not standardized, leading to inconsistencies and errors. We need to define an approach to standardize the CD process by creating a YAML template that can be used across all our pipelines.

We have created below Azure pipeline templates

- [bicep-deployment-template](#bicep-deployment-template)
- [deploy-parameter-processor](#deploy-parameter-processor)
- [plan-parameter-processor](#plan-parameter-processor)


---
## bicep-deployment-template

This Azure pipeline template will be used for deploying Bicep templates on Azure Cloud

Below are the parameters accepted by the pipeline template

Parameters        |     Description           |   Required/Option  |   Type | Default value    
--- | --- | --- | --- | ---
`resourceGroup` | The target resource group where you want to deploy the resources. | Optional | String | always$(TARGET_RESOURCE_GROUP_NAME) (From Variable Group)
`overrideParameters` | Parameters to be overriden from template file. | Optional | String | sharedVnetName: $(SHARED_VNET_NAME) sharedResourceGroupName: $(SHARED_RESOURCE_GROUP_NAME) vnetIntSubnetName: $(SHARED_VNET_INTEGRATION_SUBNET_NAME) privEndpointSubnetName: $(SHARED_PRIV_ENDPOINT_SUBNET_NAME) subscriptionId: $(TARGET_SUBSCRIPTION_ID)
`csmFile` | Path to bicep template file (main.bicep) | Optional | String | iac-demo-app1-deployment-config/infra-as-code/bicep/sandbox/main.bicep
`location` | Location to deploy the resources into (region) | Optional | String | 'East US'
`deploymentScope` | At what scope should the deployment take place | Optional | String | Resource Group
`deploymentMode` | Type of deployment of resources | Optional | String | Incremental

### Examples
Please find the example of usage below
```yaml
- template: bicep-deployment-template.yaml
  parameters:
    deploymentMode: 'Validation'
    csmFile: 'example/main.bicep'
```

---

## deploy-parameter-processor

This Azure pipeline template will be used for outputing the override parameters in the deployment task (Azure resource manager) format. 
ie: -parameter <value>
ex: -sharedVnetName example-vnet
  
This pipeline template is invoked by the bicep-deployment-template.yaml pipeline.

Below are the parameters accepted by the pipeline template

Parameters        |     Description           |   Required/Option  |   Type | Default value    
--- | --- | --- | --- | ---
`overrideParameters` | Parameters to be overriden from template file.  | Required | String | (Pass the 'overrideParameters' parameter from bicep-deployment-template)

### Examples
Please find the example of usage below
```yaml
- template: deploy-parameter-processor.yaml
  parameters:
    overrideParameters: ${{ parameters.overrideParameters }}
```

---

## plan-parameter-processor

This Azure pipeline template will be used for outputing the override parameters in the plan task (Azure cli) format. 
ie: parameter= <value>
ex: sharedVnetName= example-vnet
  
This pipeline template is invoked by the bicep-deployment-template.yaml pipeline.

Below are the parameters accepted by the pipeline template

Parameters        |     Description           |   Required/Option  |   Type | Default value    
--- | --- | --- | --- | ---
`overrideParameters` | Parameters to be overriden from template file.  | Required | String | (Pass the 'overrideParameters' parameter from bicep-deployment-template)

### Examples
Please find the example of usage below
```yaml
- template: deploy-parameter-processor.yaml
  parameters:
    overrideParameters: ${{ parameters.overrideParameters }}
```
