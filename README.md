# twinbots



Step 1:
  - Initialize a project named "web-apps" using uv.
   ```
    uv init web-apps
  ``` 
  - Install Django
    uv add Django
    It will install and add django in pyproject.toml
  - Start main project "coresite" in a dir named "web-apps".
    uv run django-admin startproject coresite web-apps
  - Create Containerfile using a base image and build.
    docker build -t twinbotapi -f Containerfile.
  - Install postgresql daatabase using command line.
    sudo apt install postgresql
  - To interact with web app and database, create compose.yml file.
    docker compose up --build

  Next is to interact with the postgres database.
    
