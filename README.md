# terraform-school

## Homework 1
* *Manually* create s3 bucket with any cloud provider (e.g. aws, azure)
* Declare this bucket in main.tf
* terraform init
* (optional) terraform import
* Provide output of terraform graph as a result

I have these backets on my aws account:

    aws s3 ls
    2021-04-08 13:14:35 ilya-s3-logs
    2021-04-06 13:48:39 terra-back-1339
    2021-04-19 21:30:26 terraform-20210419183023834800000001
    2021-04-20 10:48:52 terraform-20210420074850077400000001

`terra-back-1339` I use as backend along with DynamoDB for terraform locks files. Other was created for tests. 

Declaring bucket in `main.tf`

    resource "aws_s3_bucket" "already_declared_bucket" {
    bucket = "terraform-20210419183023834800000001"
    }

`terraform plan` shows that it need to create 1 object:

    Plan: 1 to add, 0 to change, 0 to destroy.

`terrafrom apply` shows an error:

    aws_s3_bucket.already_declared_bucket: Creating...

    Error: Error creating S3 bucket: BucketAlreadyOwnedByYou: Your previous request to create the named bucket succeeded and you already own it.
            status code: 409, request id: 6ZN4NK86409CNB2X, host id: XYQVrFL7jAw4Dmq3wlZTelKZXF1GHF5Iwffo5wqEHy1DTbaGLKT/MhfA3OKbdxPNWg8T4DIuOws=

Trying `terraform import`, at first we should create an resource object in `main.tf`:

    resource "aws_s3_bucket" "foo" {
    # (resource arguments)
    }

at second we should import s3 bucket to terraform:

    terraform import aws_s3_bucket.foo terraform-2021041918302383480000000

The output was:

    aws_s3_bucket.foo: Importing from ID "terraform-20210419183023834800000001"...
    aws_s3_bucket.foo: Import prepared!
    Prepared aws_s3_bucket for import
    aws_s3_bucket.foo: Refreshing state... [id=terraform-20210419183023834800000001]

    Import successful!

    The resources that were imported are shown above. These resources are now in
    your Terraform state and will henceforth be managed by Terraform.

Now it's time to check it, by executing `terraform apply`, the output was:

    Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

So, bucket already managed by terrafrom. 

## Provide output of terraform graph as a result

The output of `terraform graph` is: 

    digraph {
            compound = "true"
            newrank = "true"
            subgraph "root" {
                    "[root] aws_instance.example" [label = "aws_instance.example", shape = "box"]
                    "[root] aws_s3_bucket.foo" [label = "aws_s3_bucket.foo", shape = "box"]
                    "[root] aws_s3_bucket.name" [label = "aws_s3_bucket.name", shape = "box"]
                    "[root] data.aws_ami.ubuntu" [label = "data.aws_ami.ubuntu", shape = "box"]
                    "[root] output.aws_s3_bucket_id" [label = "output.aws_s3_bucket_id", shape = "note"]
                    "[root] provider.aws" [label = "provider.aws", shape = "diamond"]
                    "[root] aws_instance.example" -> "[root] data.aws_ami.ubuntu"
                    "[root] aws_s3_bucket.foo" -> "[root] provider.aws"
                    "[root] aws_s3_bucket.name" -> "[root] provider.aws"
                    "[root] data.aws_ami.ubuntu" -> "[root] provider.aws"
                    "[root] meta.count-boundary (EachMode fixup)" -> "[root] aws_instance.example"
                    "[root] meta.count-boundary (EachMode fixup)" -> "[root] aws_s3_bucket.foo"
                    "[root] meta.count-boundary (EachMode fixup)" -> "[root] output.aws_s3_bucket_id"
                    "[root] output.aws_s3_bucket_id" -> "[root] aws_s3_bucket.name"
                    "[root] provider.aws (close)" -> "[root] aws_instance.example"
                    "[root] provider.aws (close)" -> "[root] aws_s3_bucket.foo"
                    "[root] provider.aws (close)" -> "[root] aws_s3_bucket.name"
                    "[root] root" -> "[root] meta.count-boundary (EachMode fixup)"
                    "[root] root" -> "[root] provider.aws (close)"
            }
    }

and svg file, created by `terraform graph | dot -Tsvg > graph.svg` is:

![graph.svg](./graph.svg)

Now it's time to `terraform destroy`, please notice that terraform have destroyed imported bucket as well as declared in `main.tf`:

    aws s3 ls
    2021-04-08 13:14:35 ilya-s3-logs
    2021-04-06 13:48:39 terra-back-1339
