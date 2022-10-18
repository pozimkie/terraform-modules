resource "aws_apigatewayv2_api" "main" {
  name          = var.name
  protocol_type = "HTTP"

  cors_configuration {
    allow_credentials = var.cors_allow_credentials
    allow_headers     = var.cors_allow_headers
    allow_methods     = var.cors_allow_methods
    allow_origins     = var.cors_allow_origins
    expose_headers    = var.cors_expose_headers
    max_age           = var.cors_max_age
  }

}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.main.id

  name        = "$default"
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      responseLatency         = "$context.responseLatency"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      path                    = "$context.path"
      httpHost                = "$context.domainName"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      userAgent               = "$context.identity.userAgent"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

  default_route_settings {
    throttling_burst_limit = var.default_throttling_burst_limit
    throttling_rate_limit = var.default_throttling_rate_limit
  }
}

resource "aws_lambda_permission" "api_gw_permission" {
  for_each = var.integrations

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value["lambda_function_name"]
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}


resource "aws_apigatewayv2_integration" "integration" {
  for_each = var.integrations

  api_id = aws_apigatewayv2_api.main.id

  integration_uri    = each.value["lambda_arn"]
  integration_type   = "AWS_PROXY"
  integration_method = "ANY"

}

locals {
  routes = flatten([
    for integration_key, integration in var.integrations : [
      for route in integration.routes : {

        integration_key = integration_key
        route_id_key    = "${route.method}_${route.path}"
        route_path      = route.path
        route_method    = route.method
      }
    ]
  ])
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = {
    for ct in local.routes : "${ct.route_id_key}" => ct
  }

  api_id = aws_apigatewayv2_api.main.id

  route_key = "${each.value["route_method"]} ${each.value["route_path"]}"
  target    = "integrations/${aws_apigatewayv2_integration.integration[each.value["integration_key"]].id}"
}


resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.main.name}"

  retention_in_days = var.logs_retention
}
