package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-secrets-manager"
const defaultExampleTerraformDir = "examples/complete-rotation-policy"

const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

const bestRegionYAMLPath = "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml"

var permanentResources map[string]interface{}

func TestMain(m *testing.M) {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupOptions(t *testing.T, prefix string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:            t,
		TerraformDir:       defaultExampleTerraformDir,
		Prefix:             prefix,
		ResourceGroup:      resourceGroup,
		BestRegionYAMLPath: "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml",
		TerraformVars: map[string]interface{}{
			"existing_sm_instance_crn":      permanentResources["secretsManagerCRN"],
			"skip_iam_authorization_policy": true,
			"resource_tags":                 []string{prefix},
		},
	})
	return options
}

func TestRunDefaultExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "iam-svcid-apikey-sm")
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "iam-svcid-apikey-sm-upg")
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestPrivateInSchematics(t *testing.T) {
	t.Parallel()

	var privDir = "examples/complete-no-rotation-policy"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "iam-svcid-apikey-sm-priv",
		TarIncludePatterns: []string{
			"*.tf",
			privDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         privDir,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		BestRegionYAMLPath:     bestRegionYAMLPath,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_sm_instance_crn", Value: permanentResources["privateOnlySecMgrCRN"], DataType: "string"},
		{Name: "skip_iam_authorization_policy", Value: true, DataType: "bool"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
