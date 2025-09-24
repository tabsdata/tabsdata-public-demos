# Requirements

* conda or pyenv (python=3.12)

# 1.0 Setup Tabsdata Instance

## 1.0 Clone Github Repo and hop into project directory

```sh
git clone https://github.com/tabsdata/tabsdata-public-demos.git
cd S3_to_Databricks
```

## 1.0 Create a virtual environment of your choice

```sh
conda create -y --name  tabsdata python=3.12
conda activate tabsdata
```
## 1.1 Install Tabsdata

```sh
pip install tabsdata --upgrade
```

## 1.2 Configure Credentials

[source.sh](./source.sh)Set your AWS and Databricks configuration and credentials in [source.sh](./source.sh).

## 1.3 Register Tabsdata Functions

```bash
./setup-tabsdata.sh
```
# 2.0 Run Workflow

## 2.1 Trigger Publisher
```sh
td fn trigger --coll workflow --name s3_pub
```

# Notes

The shell script bundles terminal commands to:
  1. Set your credentials as environmental variables
  2. Start your tabsdata server
  3. Create your collections
  4. Register your functions 

You can run these manually if you would like, but you can use the shell script as a quickstart. Every time you run the shell script, it deletes your existing Tabsdata instance and creates a new one from scratch. 

When you register a function, any environmental variables referenced in the function are evaluated at registration and bundled with the function. TLDR, environmental variables need to be present in your terminal shell at function registration or update. Once the function is registered with the environment variables, it can be triggered from any terminal even if it doesn't have the variables present. 

When updating a function, you must have your environment secrets present. 

For alternative methods of secret management, we also offer [hashicorp vault](https://docs.tabsdata.com/latest/guide/secrets_management/hashicorp/main.html)
