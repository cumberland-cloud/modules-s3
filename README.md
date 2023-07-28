# Terraform Modules: s3

[![terraform workflows](https://github.com/cumberland-cloud/modules-s3/actions/workflows/action.yaml/badge.svg)](https://github.com/cumberland-cloud/modules-s3/actions/workflows/action.yaml)

A Terraform module for deploying a secure S3 bucket and associated resources.

Refer to [hosted docs]() for more information regarding this module.

## Important

This module will provision several buckets by default: the original _source_ bucket, a _logging_ bucket to log access events on the _source_ bucket and atleast one _replica_ bucket whose content will be replicated from the _source_ bucket anytime content is added or removed.