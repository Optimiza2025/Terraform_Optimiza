resource "aws_s3_bucket" "raw" {
  bucket = "raw-optimiza-2025-2"
  force_destroy = true
}

resource "aws_s3_bucket" "trusted" {
  bucket = "trusted-optimiza-2025-2"
  force_destroy = true
}
