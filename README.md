# twinbots


Step 1:
-------
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
-------
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

  - Create yml files for postgres and django web-app to deploy in kubernetes.
  
1) django-deployment.yml
  - It will run django app inside the cluster and tells kubernetes about which docker image (the one pushed to ACR) to run.
  how many copies/replicas of the app need to run. And about ports to expose inside the pod/virtual machine.

1) django-service.yml
  - Service file exposes the django app inside the cluster to make it accessible to other app such as, postgres

1) postgres-deployment.yml
  - The deployment file sets up the database with environment variables.

1) postgres-service.yml
  - This service file will expose Postgres to other services, exp: Django app

1) ingress.yml
  - It exposes the app to the internet.

To route traffic to Django app, we need NGINX Ingress controller on AKS(Azure Kubernetes Service).

Step 3:
-------
Create a chatbot who asks the three favourite foods.

  - Create new app named chatbot using
  ```shell
  uv run manage.py startapp app-name 
```
  - Add app-name in settings.py under INSTALLED_APPS list.
  ```shell
    "app-name",

```
  - In TEMPLATES list, add path to chatbot/templates.
  ```shell
        "DIRS": [BASE_DIR / "chatbot/templates"],
```
  - In views.py, create a chatbot and return render.
  - Create an html file named "templates/chat.html" in chatbot folder.
  - Add chatbot urls to coresite/urls.py.

 
 Step 4: 
--------
 Simulate conversation between two chatbots where "chatbotA" will question to "chatbotB" about what are your three favourite foods are.

  Create a python package for this part via.
```shell
  uv init --package packages/simulated-conversations
```
  - Install openai and psycopg via 
  ```shell
  uv add openai
  uv add psycopg[binary]
```
  - Add openai_api_key to env variables file.
  - In __init__.py, create chatbots who will get response from gpt model with instructions and input message.
  - Run via
  ```shell
  uv run sim-conv
```
  - The simulated conversations are stored in a postgres database using psycopg.
  - Connect postgres database container with the python package.
  - Create table and store the data in the database.

- You can check this in interactive mode by running "uv run sim-conv" in the django web app container.
  - Entry point is,
  ```shell
  docker compose exec web bash
  ```
  The bash shell will start. Run "uv run sim-conv" there.
  The table will be stored in database and you can check it using,
  ```shell
  docker run -it --rm --network twinbots_default postgres:15 psql -h db -U myuser -d mydb -p 5432
  ```
- the prompt will be like, mydb#>
check tables and database.


Step 5: 
-------

