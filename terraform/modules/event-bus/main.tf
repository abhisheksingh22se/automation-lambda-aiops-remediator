#1 Listening for the "Alarm Ringing" Event
resource "aws_cloudwatch_event_rule" "remediation_trigger" {
  name = "aiops-remediation-rule"
  description = "Trigger remediation when Specific alarms go into ALARM state"

  event_pattern = jsonencode({
    source = ["aws.cloudwatch"]
    detail-type = ["CloudWatch Alarm State Change"]
    detail = {
        state = {
            value = ["ALARM"]
        }
        alarmName = var.trigger_alarm_names
    }
  })
}

#2 Point the Rule to the Lambda Function
resource "aws_cloudwatch_event_target" "send_to_lambda" {
  rule = aws_cloudwatch_event_rule.remediation_trigger.name
  target_id = "SendToRemediationLambda"
  arn = var.target_lambda_arn
}

#3 Allow EventBridge to click the button
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id = "AllowExecutionFromEventBridge"
  action = "lambda:InvokeFunction"
  function_name = var.target_lambda_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.remediation_trigger.arn
}