Create ACR (Optional):
```
az acr create --resource-group archipel-prod --name n8narchipelcontainerregistry --sku Basic
```

Login to ACR:
```
az acr login --name n8narchipelcontainerregistry
```

Create Environment:
```
az containerapp env create \
  --name n8n-archipel-container-env \
  --resource-group archipel-prod \
  --location switzerlandnorth
```

Update Environment:
```
az containerapp env update \
  --name n8n-archipel-container-env \
  --resource-group archipel-prod \
  --set-env-vars N8N_BASIC_AUTH_ACTIVE=true 
```

Build the image:
```
docker build -t my-n8n-image .
docker buildx build --platform linux/amd64 -t my-n8n-amd-image:v7 .
```

Tag the image:
```
docker tag my-n8n-amd-image:v7 n8narchipelcontainerregistry.azurecr.io/my-n8n-amd-image:v7

```

Push the image:
```
docker push n8narchipelcontainerregistry.azurecr.io/my-n8n-amd-image:v7
```

Create the container:
```
az containerapp create \
  --name n8napp \
  --resource-group archipel-prod \
  --environment n8n-archipel-container-env \
  --image n8narchipelcontainerregistry.azurecr.io/my-n8n-amd-image:v4 \
  --cpu 0.5 --memory 1.0Gi \
  --target-port 5678 \
  --ingress 'external' \
  --transport 'auto'
  --set-env-vars DB_SQLITE_DATABASE=/data/sqlite/database.sqlite \
  --set-env-vars DB_TYPE=sqlite
  
az containerapp update \
  --name n8napp \
  --resource-group archipel-prod \
  --image n8narchipelcontainerregistry.azurecr.io/my-n8n-amd-image:v8 \
  --min-replicas 1 \
  --max-replicas 1 \
   --health-probe-initial-delay 30 \
  --health-probe-period 30 \
  --health-probe-path "/health" \
  --health-probe-timeout 5 \
  --health-probe-failure-threshold 3 \
  --health-probe-success-threshold 1 
```

SET ENV for APP: 
```bash
az containerapp update \
  --name n8napp \
  --resource-group archipel-prod \
  --set-env-vars PULSE_MEDICAL_URL=https://api.pulsemedica.ch/v2 \
    PULSE_MEDICAL_CLIENT_ID=a9c5190b0dda4a80aa5dd294bd1376fc \
    PULSE_MEDICAL_CLIENT_SECRET=todo-change \
    N8N_USER_MANAGEMENT_JWT_SECRET=todo-change \
    N8N_ENCRYPTION_KEY=todo-change \
    WEBHOOK_URL=https://n8napp.reddesert-b95c3a53.switzerlandnorth.azurecontainerapps.io/ \
    N8N_EDITOR_BASE_URL=https://n8napp.reddesert-b95c3a53.switzerlandnorth.azurecontainerapps.io/ 
    
```


```
az acr update --name n8narchipelcontainerregistry --admin-enabled true
```


```
az containerapp update \
  --name n8napp1 \
  --resource-group archipel-prod \
  --set-env-vars N8N_BASIC_AUTH_ACTIVE=true \
  --set-env-vars N8N_BASIC_AUTH_USER=myuser \
  --set-env-vars N8N_BASIC_AUTH_PASSWORD=mypassword \
  --set-env-vars DB_SQLITE_DATABASE=/data/sqlite/database.sqlite \
  --set-env-vars DB_TYPE=sqlite
```
```
docker run -d \
  -p 5678:5678 \
  -e BASIC_AUTH_ACTIVE=true \
  -e BASIC_AUTH_USER=myuser \
  -e BASIC_AUTH_PASSWORD=mypassword \
  -e DB_SQLITE_DATABASE=/data/sqlite/database.sqlite \
  -e DB_TYPE=sqlite \
  my-n8n-image
```


```bash
az containerapp show --name n8napp --resource-group archipel-prod --query properties.configuration.ingress.fqdn
```


## todo Implement backup process for sqlite database

```bash
az storage account create --name n8nstorageaccount --resource-group archipel-prod --location switzerlandnorth --sku Standard_LRS
```

### Create Blob Storage Container
```bash
az storage container create --name sqlitebackups --account-name n8nstorageaccount
```

### exec into the container
```bash
az container exec --name n8napp --resource-group archipel-prod --container-name n8napp --exec-command "/bin/sh"
```

### Retrieve existing env
```bash
az containerapp env show --name n8n-archipel-container-env --resource-group archipel-prod
```

az containerapp envvars list \
--name n8napp \
--resource-group archipel-prod
