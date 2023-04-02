module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name = "akm-enterprises-dynamodb-tf-state"

  hash_key   = "LockID"
  range_key  = "SortID"
  attributes = [
    {
      name = "LockID"
      type = "S"
    },
    {
      name = "SortID"
      type = "S"
    },
  ]

  global_secondary_indexes = [
    {
      name               = "SortID-index"
      hash_key           = "SortID"
      range_key          = "LockID"
      write_capacity     = 5
      read_capacity      = 5
      projection_type    = "INCLUDE"
      non_key_attributes = ["Digest"]
    },
  ]

  read_capacity  = 5
  write_capacity = 5
}

output "dynamodb_table_arn" {
  value = module.dynamodb_table.this_dynamodb_table_arn
}

output "dynamodb_table_id" {
  value = module.dynamodb_table.this_dynamodb_table_id
}