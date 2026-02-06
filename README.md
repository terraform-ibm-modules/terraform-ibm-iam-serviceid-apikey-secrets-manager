# IAM Service ID API key Secrets Manager

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-iam-serviceid-apikey-secrets-manager?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-iam-serviceid-apikey-secrets-manager/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

Use this module to create a services ID API key (associated with an existing service ID) and stores it as a dynamic secret (existing or new) in an existing IBM Secrets Manager instance.
Use this module to creates a services ID API key (associated with an existing service ID) and stores it as a dynamic secret (existing or new) in an existing IBM Secrets Manager instance.

Dynamic secrets, unlike (arbitrary) static secrets, create IAM service ID API key credentials that are automatically rotated by Secrets Manager engine every time the secret payload is read or accessed when the lease duration is met. The credential changes are controlled by two input variables that you specify when you create the secret: `sm_iam_secret_ttl` (sometimes referred to as _time to live_, _TTL_, or _lease duration_) and `sm_iam_secret_api_key_persistence` (sometimes referred to as _reuse IAM credentials_).

In addition to rotation when the TTL or lease expires, you can create a rotation policy to trigger rotation before the leasing time expires. Triggering rotation before expiration provides transition time between the older and the new credentials. You enable this setting by setting `sm_iam_secret_auto_rotation` to `true` and configuring the related rotation variables `sm_iam_secret_auto_rotation_unit` and `sm_iam_secret_auto_rotation_interval`.

<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-iam-serviceid-apikey-secrets-manager](#terraform-ibm-iam-serviceid-apikey-secrets-manager)
* [Examples](./examples)
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
    * <a href="./examples/complete-no-rotation-policy">Complete with no rotation example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=iam-serviceid-apikey-secrets-manager-complete-no-rotation-policy-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-iam-serviceid-apikey-secrets-manager/tree/main/examples/complete-no-rotation-policy"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/complete-rotation-policy">Complete with rotation policy example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=iam-serviceid-apikey-secrets-manager-complete-rotation-policy-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-iam-serviceid-apikey-secrets-manager/tree/main/examples/complete-rotation-policy"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-iam-serviceid-apikey-secrets-manager

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key     = "XXXXXXXXXXXXXX"
  region               = "us-south"
}
module "dynamic_serviceid_apikey1" {
  source                               = "terraform-ibm-modules/iam-serviceid-apikey-secrets-manager/ibm"
  version                              = "X.X.X"  # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id                    = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                               = "us-south"
  sm_iam_secret_name                   = "example-arbitrary-secret"
  sm_iam_secret_description            = "Example of dynamic IAM secret"
  secrets_manager_guid                 = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  serviceid_id                         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
  secret_group_id                      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
}
```

### Required IAM access policies

You need the following permissions to run this module.
- Account Management
    - **IAM Access Groups** service
        - `Editor` platform access
    - **IAM Identity** service
        - `Operator` platform access
        - `Service ID creator` service access if the service id creation is disabled in the iam settings
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **Secrets Manager** service
        - `Administrator` platform access
        - `Manager` service access




<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.70.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_sm_iam_credentials_secret.sm_iam_credentials_secret](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_iam_credentials_secret) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The ID of the target account in which the IAM credentials are created. Use this field only if the target account is not the same as the account of the Secrets Manager instance. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels that can be used to search for secrets within the instance. Up to 30 labels can be created. Labels can be between 2 and 64 characters. | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region of the Secrets Manager instance. If not provided defaults to the region defined in the IBM provider configuration. | `string` | n/a | yes |
| <a name="input_secret_group_id"></a> [secret\_group\_id](#input\_secret\_group\_id) | Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in default secret-group | `string` | `null` | no |
| <a name="input_secrets_manager_guid"></a> [secrets\_manager\_guid](#input\_secrets\_manager\_guid) | Instance ID of Secrets Manager instance in where secret is stored | `string` | n/a | yes |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | The service endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private` | `string` | `"public"` | no |
| <a name="input_serviceid_id"></a> [serviceid\_id](#input\_serviceid\_id) | ID of ServiceID the dynamic secret/API key authenticates | `string` | n/a | yes |
| <a name="input_sm_iam_secret_api_key_persistence"></a> [sm\_iam\_secret\_api\_key\_persistence](#input\_sm\_iam\_secret\_api\_key\_persistence) | Whether to use the same service ID and API key for future read operations. Set this to `true` if IAM credentials are managed by the Terraform code. | `bool` | `true` | no |
| <a name="input_sm_iam_secret_auto_rotation"></a> [sm\_iam\_secret\_auto\_rotation](#input\_sm\_iam\_secret\_auto\_rotation) | Set to `true` to configure automatic rotation policy. | `bool` | `false` | no |
| <a name="input_sm_iam_secret_auto_rotation_interval"></a> [sm\_iam\_secret\_auto\_rotation\_interval](#input\_sm\_iam\_secret\_auto\_rotation\_interval) | Specifies the rotation interval for the rotation policy. | `number` | `60` | no |
| <a name="input_sm_iam_secret_auto_rotation_unit"></a> [sm\_iam\_secret\_auto\_rotation\_unit](#input\_sm\_iam\_secret\_auto\_rotation\_unit) | Specifies the unit of time for rotation policy. Acceptable values are `day` or `month`. | `string` | `"day"` | no |
| <a name="input_sm_iam_secret_description"></a> [sm\_iam\_secret\_description](#input\_sm\_iam\_secret\_description) | Description of SM IAM secret (dynamic ServiceID API Key) to be created | `string` | n/a | yes |
| <a name="input_sm_iam_secret_name"></a> [sm\_iam\_secret\_name](#input\_sm\_iam\_secret\_name) | Name of SM IAM secret (dynamic ServiceID API Key) to be created | `string` | n/a | yes |
| <a name="input_sm_iam_secret_ttl"></a> [sm\_iam\_secret\_ttl](#input\_sm\_iam\_secret\_ttl) | Specify validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively) | `string` | `"7776000"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secrets-Manager IAM secret ID containing ServiceID API key |
| <a name="output_sm_iam_secret_next_rotation_date"></a> [sm\_iam\_secret\_next\_rotation\_date](#output\_sm\_iam\_secret\_next\_rotation\_date) | Next rotation date for iam\_credential secret |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
