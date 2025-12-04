#############################################
# Prefixo aleatório para nome único da Lambda
#############################################
resource "random_id" "lambda_prefix" {
  byte_length = 4
}

#############################################
# Nome da função Lambda
#############################################
locals {
  lambda_function_name = "${random_id.lambda_prefix.hex}-etl-csv"
}

#############################################
# BUSCAR A ROLE EXISTENTE DINAMICAMENTE
# (Isso evita o erro de conta errada)
#############################################
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

#############################################
# Função Lambda para processamento de CSVs
#############################################
resource "aws_lambda_function" "process_csv" {
  function_name    = local.lambda_function_name
  handler          = "lambda_handler.lambda_handler"
  runtime          = "python3.9"

  role             = data.aws_iam_role.lab_role.arn

  filename         = "${path.module}/lambda_function/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function/lambda.zip")
  timeout          = 90

  # Camada Pandas compatível com Python 3.9
  layers = [
    "arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:28"
  ]

  # Variáveis de ambiente
  environment {
    variables = {
      BUCKET_DESTINO = var.trusted_name
      SNS_TOPIC_ARN  = var.topic_arn
      EMAIL_LIST     = jsonencode(var.email_list)
    }
  }
}

#############################################
# Permitir que o S3 invoque a Lambda
#############################################
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_csv.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_arn
}

#############################################
# Notificação S3 → Trigger Lambda (.csv)
#############################################
resource "aws_s3_bucket_notification" "bucket_trigger" {
  bucket = var.raw_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_csv.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}