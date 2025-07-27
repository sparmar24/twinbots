# twinbots


For quick start, clone the repository and run following commands.


Step 1:
-------
Create a docker container with a Django app running a SQL database.

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
Deploy preferably on Azure.

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


Step 3:
-------
Create a chatbot who asks the three favourite foods.

  - Create new app named chatbot via
  ```shell
  uv run manage.py startapp chatbot 
```
  - Add app-name in settings.py under INSTALLED_APPS list.
  ```shell
    "chatbot",

```
  - In TEMPLATES list, add path to chatbot/templates.
  ```shell
        "DIRS": [BASE_DIR / "chatbot/templates"],
```
  - In views.py, create a chatbot and return render.
  - Create an html file named "templates/chat.html" in chatbot folder.
  - Add chatbot urls to project dir urls -> coresite/urls.py.

 
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
check tables in database if created or not.

For Azure cloud, add package simulated-conversations via subprocess in chatbot.views.py
```shell
        subprocess.run(["uv", "run", "sim-conv"])  # 10 s
```

Step 5: 
-------
Create an API endpoint which shows the simulated users that are vegetarian/vegan in those 100 simulated conversations and their top 3 favourite foods

  - Create dbt package to manage sql queries. For that run
  ```
shell
uv run dbt
```
A folder with set of files will be created.
Run sql queries in models dir with .sql files. 
For Azure cloud, add following command in chatbot.views.py
```shell
        subprocess.run(
            [
                "uv",
                "run",
                "dbt",
                "run",
                "--select",
                "tag:conversations",
            ]
        )  # 10 s

```
Formatted files are created with list of vegetarians or vegans in 100 simulated conversations.

- Define functions in chatbot/views.py, to create endpoint views.
- Different endpoint views are connected to different html templates.
- All of them are also included in main project url.py.

Step 6: 
-------
Create authentication for this API endpoint and “user” and “password”

- For authentication, Django's default authentication functions are used. 

Create directory "registration" and login.html file.

- One time step,
- In local,
```shell
uv run manage.py migrate
```
Create superuser via
```shell
uv run manage.py createsuperuser
```
- Login to localhost and create normal user with limited access.


- For Azure cloud,
The table auth_user has to be in postgres server to have authentication. It is created via 
```shell
uv run manage.py migrate
```
Thus auth_user is dumped from local instance to cloud instance as it is not present in cloud postgres database.

The command to dump from source database instance is,
```shell
❯ docker exec -t 145045447cd5 pg_dump -U twinbotsdb -d twinbotsdb --data-only -t auth_user  > auth_table_data.sql
```
A .sql file is created and stored in target database instance via.
```shell
❯ psql -h postgres-twinbots.postgres.database.azure.com -U twinbotsdb -d twinbotsdb -f auth_table_data.sql
```

Now, everything is working with a new user of limited access.

Final step endpoint view:
--------------------------

- Go to django-web-app.azurewebsites.net
A home page will open with login option. Login using "username" and "password".
Go to 


