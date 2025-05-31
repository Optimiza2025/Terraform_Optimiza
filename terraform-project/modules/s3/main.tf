resource "aws_s3_bucket" "raw" {
  bucket = "raw-optimiza"
  force_destroy = true
}

resource "aws_s3_bucket" "trusted" {
  bucket = "trusted-optimiza"
  force_destroy = true
}
