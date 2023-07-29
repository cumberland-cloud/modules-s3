module "kms" {
    #checkov:skip=CKV_TF_1: "Ensure Terraform module sources use a commit hash"

    count           = local.conditions.provision_key ? 1 : 0
    source          = "github.com/cumberland-cloud/modules-kms.git?ref=v1.0.0"

    key             = {
        alias       = "${local.name}-s3"
    }
}