resource "random_id" "lambda_prefix" {
  byte_length = 4
}

locals {
  lambda_function_name = "${random_id.lambda_prefix.hex}-etl-csv"
}

resource "aws_lambda_function" "process_csv" {
  function_name = local.lambda_function_name
  handler       = "lambda_handler.lambda_handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::654654309976:role/LabRole" #colocar o arn da role de Lab
  filename      = "${path.module}/lambda_function/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function/lambda.zip")
  timeout       = 90

  # camada do pandas
  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:28"
  ]

  environment {
    variables = {
        BUCKET_DESTINO = var.trusted_name
        SNS_TOPIC_ARN = var.topic_arn
        EMAIL_LIST = jsonencode(var.email_list)
    }
  }

}

# Permitir que o S3 invoque a Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_csv.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_arn
}

# Trigger: evento no S3 aciona o Lambda
resource "aws_s3_bucket_notification" "bucket_trigger" {
  bucket = var.raw_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_csv.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
