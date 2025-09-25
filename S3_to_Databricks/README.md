# S3 --> Databricks Demo (`S3_to_Databricks`)

In this demo, we setup a simple tabsdata instance that publishes data from S3 and subscribes it into Databricks. 

You may use this setup as a starting point and then iterate from here to customize the function code and instance to your needs

Let’s dive in!

## Requirements

* python (version=3.12)

## 1. Setup Tabsdata Instance

### 1.1. Clone Github Repo and hop into project directory

```sh
git clone https://github.com/tabsdata/tabsdata-public-demos.git
cd tabsdata-public-demos/S3_to_Databricks
```

### 1.2. [OPTIONAL] Create a virtual environment of your choice 

```sh
conda create -y --name  tabsdata python=3.12
conda activate tabsdata
```
### 1.3. Install Tabsdata

```sh
pip install tabsdata --upgrade
pip install 'tabsdata['databricks']'
```
Depending on your terminal, the databricks dependency command might be this if the one above fails

```sh
pip install tabsdata[“databricks”]
```

### 1.4 Configure Credentials

Set your AWS and Databricks configuration and credentials in [source.sh](./source.sh).

### 1.5 [OPTIONAL] Make credentials available in terminal

Your functions will reference the variables within [source.sh](./source.sh) during function registration. These variables must be available in the terminal shell when you register or update your functions. If you plan to run register or update CLI commands that are not covered in this demo, you must make these variable available in the terminal you will run the CLI commands for your functions to be able to access them.

```sh
source ./source.sh
```

### 1.5 Register Tabsdata Functions

The [setup-tabsdata.sh](./source.sh) script bundles all the Tabsdata CLI commands necessary to setup your Tabsdata instance and workflow from S3 --> Databricks.

```bash
./setup-tabsdata.sh
```

If you feel more comfortable manually running the CLI commands, you can pull them out of the shell script and run them manually. 

## 2. Run Workflow

### 2.1 Trigger Publisher
```sh
td fn trigger --coll workflow --name s3_pub
```

## 3. Monitor Results

### 3.1 Sample Data in CLI

```sh
td table sample --coll workflow --name customers_raw
td table sample --coll workflow --name customers_processed
```

### 3.2 Sample Data in UI

Access our [UI](http://localhost:2457/login) and login with the following credentials 

Username:
```admin```

Password:
```tabsdata```

Role:
```sys_admin```


More info on UI is available in our [documentation](https://docs.tabsdata.com/latest/guide/user_interface/main.html)

## Notes

The shell script bundles terminal commands to:
  1. Set your credentials as environmental variables
  2. Start your tabsdata server
  3. Create your collections
  4. Register your functions 

You can run these manually if you would like, but you can use the shell script as a quickstart. Every time you run the shell script, it deletes your existing Tabsdata instance and creates a new one from scratch. 

When you register a function, any environmental variables referenced in the function are evaluated at registration and bundled with the function. TLDR, environmental variables need to be present in your terminal shell at function registration or update. Once the function is registered with the environment variables, it can be triggered from any terminal even if it doesn't have the variables present. 

When updating a function, you must have your environment secrets present. 

For alternative methods of secret management, we also offer [hashicorp vault](https://docs.tabsdata.com/latest/guide/secrets_management/hashicorp/main.html)
