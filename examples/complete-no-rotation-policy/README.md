# Complete with no rotation example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=iam-serviceid-apikey-secrets-manager-complete-no-rotation-policy-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-iam-serviceid-apikey-secrets-manager/tree/main/examples/complete-no-rotation-policy"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


End to end example with the complete Secrets-Manager objects lifecycle including the dynamic IAM secret (without an explicit rotation policy).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.70.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamic_serviceid_apikey1"></a> [dynamic\_serviceid\_apikey1](#module\_dynamic\_serviceid\_apikey1) | ../.. | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.4.7 |
| <a name="module_secrets_manager"></a> [secrets\_manager](#module\_secrets\_manager) | terraform-ibm-modules/secrets-manager/ibm | 2.13.0 |
| <a name="module_secrets_manager_group_acct"></a> [secrets\_manager\_group\_acct](#module\_secrets\_manager\_group\_acct) | terraform-ibm-modules/secrets-manager-secret-group/ibm | 1.4.2 |
| <a name="module_secrets_manager_group_service"></a> [secrets\_manager\_group\_service](#module\_secrets\_manager\_group\_service) | terraform-ibm-modules/secrets-manager-secret-group/ibm | 1.4.2 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_service_id.secret_puller](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_service_id) | resource |
| [ibm_iam_service_policy.secret_puller_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_service_policy) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_existing_sm_instance_crn"></a> [existing\_sm\_instance\_crn](#input\_existing\_sm\_instance\_crn) | Existing Secrets Manager CRN. If not provided a new instance will be provisioned | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | APIkey that's associated with the account to use, set via environment variable TF\_VAR\_ibmcloud\_api\_key or .tfvars file. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for name of all resource created by this example | `string` | `"test-iam-serviceid-apikey"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where resources will be created | `string` | `"au-syd"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | An existing resource group name to use for this example, if unset a new resource group will be created | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to skip the creation of the IAM authorization policies required to enable the IAM credentials engine. If set to false, policies will be created that grants the Secrets Manager instance 'Operator' access to the IAM identity service, and 'Groups Service Member Manage' access to the IAM groups service. | `bool` | `false` | no |
| <a name="input_sm_iam_secret_name"></a> [sm\_iam\_secret\_name](#input\_sm\_iam\_secret\_name) | Name of SM IAM secret (dynamic ServiceID API Key) to be created | `string` | `"sm-iam-secret-puller"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_secrets_manager_crn"></a> [secrets\_manager\_crn](#output\_secrets\_manager\_crn) | CRN of Secrets-Manager instance in which IAM engine was configured |
| <a name="output_service_secret_group_id"></a> [service\_secret\_group\_id](#output\_service\_secret\_group\_id) | Secret-group ID containing IAM secret |
| <a name="output_sm_iam_secret_puller_apikey_secret_id"></a> [sm\_iam\_secret\_puller\_apikey\_secret\_id](#output\_sm\_iam\_secret\_puller\_apikey\_secret\_id) | Secrets-Manager IAM secret ID containing ServiceID API key |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
