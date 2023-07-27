module "kms" {
    count           = local.conditions.provision_key ? 1 : 0
    source          = "https://github.com/cumberland-cloud/modules-kms.git?ref=8842d57"

    key             = {
        alias       = "${local.name}-s3"
    }
}