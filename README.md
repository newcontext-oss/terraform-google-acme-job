# tf_module_glcoud_job

Terraform module for building out job server on Google Cloud Services

It builds compute instance(s) to run job services

## Use

Call it as a module from another Terraform repository.

```sh
module "job" {
  source = "tf_module_gcloud_job"_

  db_internal_ip = "x.x.x.x"

  network_name   = "test-org"
  engineer_cidrs = "${var.engineer_cidrs}"

  ssh_public_key_filepath = "ubuntu.pub"
}
```

## Testing

To build, validate and then destroy run these commands below:

```sh
bundle exec kitchen converge
bundle exec kitchen verify
bundle exec kitchen destroy job
bundle exec kitchen destroy db
bundle exec kitchen destroy network
```

### Prerequisites

- Ruby 2.2 or greater
- Terraform 0.10 or greater
- gcloud command line utility (https://cloud.google.com/sdk/)
- Google Cloud Project with a service account
- Download service account credentials to: `credentials.json`
- Create the module files directory: `mkdir test/fixtures/tf_module/files`
- Create the SSH key: `ssh-keygen -f test/fixtures/tf_module/files/insecure`
- Create an environment file: `.env`, add this content:

```sh
export TF_VAR_engineer_cidrs="[\"$(dig +short myip.opendns.com @resolver1.opendns.com)/32\"]"
export GOOGLE_APPLICATION_CREDENTIALS="credentials.json"
export GCLOUD_PROJECT="<project-id>
export GCLOUD_REGION="us-west1"
```
