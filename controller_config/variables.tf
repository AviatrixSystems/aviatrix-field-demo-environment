variable "ctrl_username" {
  description = "Aviatrix controller username"
}

variable "ctrl_password" {
  description = "Aviatrix controller admim password"
}

variable "ctrl_fqdn" {
  description = "Aviatrix controller fqdn"
}

variable "skip_version_validation" {
  description = "Aviatrix controller skip version validation"
}

variable "cplt_svc_password" {
  description = "Aviatrix copilot service account password"
}

variable "account_email" {
  description = "Email address to associate with the controller users - admin and copilot service account"
}

variable "aws_operations_account_number" {
  description = "Access account number for the aws account for the operations department"
}

variable "aws_engineering_account_name" {
  description = "Aws access account name for the engineering department"
}

variable "aws_engineering_account_number" {
  description = "Access account number for the aws account for the engineering department"
}

variable "aws_accounting_account_name" {
  description = "Aws access account name for the accounting department"
}

variable "aws_accounting_account_number" {
  description = "Access account number for the aws account for the accounting department"
}

variable "azure_marketing_account_name" {
  description = "Azure access account name for the marketing department"
}

variable "azure_marketing_subscription_id" {
  description = "Access account subscription id for the azure account for the marketing department"
}

variable "azure_operations_account_name" {
  description = "Azure access account name for the operations department"
}

variable "azure_operations_subscription_id" {
  description = "Access account subscription id for the azure account for the operations department"
}

variable "azure_directory_id" {
  description = "Access account directory id for azure accounts"
}

variable "azure_application_id" {
  description = "Access account application id for azure accounts"
}

variable "azure_application_key" {
  description = "Access account application key for azure accounts"
}

variable "gcp_enterprise_data_account_name" {
  description = "Gcp access account name for the enterprise data department"
}

variable "gcp_enterprise_data_project_id" {
  description = "Access account project id for the gcp account for the enterprise data department"
}

variable "gcp_operations_account_name" {
  description = "Gcp access account name for the operations department"
}

variable "gcp_operations_project_id" {
  description = "Access account project id for the gcp account for the operations department"
}

variable "gcp_credentials_filepath" {
  description = "Access account credentials filepath for gcp accounts"
}

variable "oci_operations_account_name" {
  description = "Oci access account name for the operations department"
}

variable "oci_tenant_ocid" {
  description = "Access account tenant ocid for oci accounts"
}

variable "oci_user_ocid" {
  description = "Access account user ocid for oci accounts"
}

variable "oci_operations_compartment_ocid" {
  description = "Access account compartment ocid for the oci account for the operations department"
}

variable "oci_key_filepath" {
  description = "Access account key filepath for oci accounts"
}

variable "controller_label" {
  description = "Text to display in the controller banner"
  default     = "Aviatrix Demo Controller"
}

variable "idp_metadata_url" {
  description = "Aviatrix controller sso idp metadata url"
}
