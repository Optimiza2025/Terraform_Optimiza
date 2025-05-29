# criação de um id randômico para criação dos buckets
resource "random_id" "bucket_suffix" {
  byte_length = 4
}
locals {
  timestamp_suffix = formatdate("YYYYMMDDHHmm", timestamp())
}

resource "aws_s3_bucket" "raw" {
  bucket = "${var.bucket_prefix}-raw-${local.timestamp_suffix}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket" "trusted" {
  bucket = "${var.bucket_prefix}-trusted-${local.timestamp_suffix}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}