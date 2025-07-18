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
  but error was still there. 
  tried following steps:
  ```shell
  az acr update -n acrtwinbots --admin-enabled true
  login to registry via
  az acr login -n acrtwinbots -> login failed.
  az acr login -n acrtwinbots --expose-token
  generate key using
  gpg --full-generate-key
  gpg --list-secret-keys
  gpg --list-secret-keys --keyid-format=long
  ```
  pass init <generated key>

  now login again to acr,
  ```shell
  az acr login -n acrtwinbots
  ```
  Finally, push the docker image to acr and it worked.

  - Create yml files for postgres and django app to deploy in kubernetes.
  
