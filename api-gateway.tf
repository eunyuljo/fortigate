# 1. Lambda Function 생성 (Hello World)
resource "aws_lambda_function" "hello_lambda" {
  filename      = "lambda.zip"  # 패키지화된 Lambda 코드 (사전에 빌드 필요)
  function_name = "HelloLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
}

# Lambda 실행을 위한 IAM Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# 2. API Gateway 생성
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "ExampleAPI"
  description = "Example API Gateway with Lambda Integration"
}

# 3. API Gateway 리소스 생성 (/hello)
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "hello"
}


# 4. GET 메서드 추가
resource "aws_api_gateway_method" "get_hello" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}


# 5. Lambda 연동
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.hello_lambda.invoke_arn
}

# 7. Lambda 실행 권한 부여
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*"
}

# 8. 출력 값 (API Gateway의 Invoke URL)
output "api_gateway_url" {
  value = "https://${aws_api_gateway_rest_api.example_api.id}.execute-api.${var.region}.amazonaws.com/dev/hello"
}
