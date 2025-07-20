# twinbots


Step 1:
  - Initialize a project named "web-apps" using uv.
   ```shell
    uv init web-apps
  ``` 
  - Install Django
    ```shell
    uv add Django
    ```
    It will install and add django in pyproject.toml
  - Start main project "coresite" in a dir named "web-apps".
  ```shell
    uv run django-admin startproject coresite web-apps
  ```
  - Create Containerfile using a base image and build.
  ```shell
    docker build -t twinbotapi -f Containerfile.
  ```
  - Install postgresql daatabase using command line.
  ```shell
    sudo apt install postgresql
  ```
  - To interact with web app and database, create compose.yml file.
  ```shell
    docker compose up --build
  ```
Step 1.5
-------

```
cp .env.template .env
```
Set up your environment variables in your `.env`.

To activate your `.venv` and export your environment variables stored in `.env`,
```
source .envrc
```

Step 2:
  - Create an azure account with free plan. and login through terminal.
  ```shell 
  az login```
  - We need to create resource group, kubernetes cluster, azure cluster registry. For that Terraform file is created with all resources in it.
  then, run 
  ```shell
  terraform init
  terraform plan
  terraform apply
  ```
  - Next is to build and push the docker image to azure cluster registry (acr).
  run
  check list of all images first using
  ```shell
  docker images
  ```
  Now, tag the image to the acr,
  ```
  docker tag twinbots-web acrtwinbots.azurecr.io/twinbots-web:latest
  ```
  and push
  ```shell
  docker push acrtwinbots.azurecr.io/twinbots-web:latest
  ```
  It gave error saying authentication required. Try to login and push again
  ```shell
  az login
  ```
  But error was still there. 
  tried following steps:
  ```shell
  az acr update -n acrtwinbots --admin-enabled true
 - login to registry via
  az acr login -n acrtwinbots -> login failed.
  az acr login -n acrtwinbots --expose-token
 - generate key using
  gpg --full-generate-key
  gpg --list-secret-keys
  gpg --list-secret-keys --keyid-format=long
  ```
  pass init "generated key"

  Login again to acr,
  ```shell
  az acr login -n acrtwinbots
  ```
  Finally, pushed the docker image to acr and it worked.

  - Create yml files for postgres and django app to deploy in kubernetes.
  
1) django-deployment.yml
  - It will run django app inside the cluster and tells kubernetes about which docker image (the one pushed to ACR) to run.
  how many copies/replicas of the app need to run. And about ports to expose inside the pod/virtual machine.

2) django-service.yml
  - Service file exposes the django app inside the cluster to make it accessible to other app such as, postgres

3) postgres-deployment.yml
  - The deployment file sets up the database with environment variables.

4) postgres-service.yml
  - This service file will expose Postgres to other services, exp: Django app

5) ingress.yml
  - It exposes the app to the internet.

To route traffic to Django app, we need NGINX Ingress controller on AKS(Azure Kubernetes Service).

