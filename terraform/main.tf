

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "my-org-logs"
  force_destroy = true
}

resource "aws_cloudtrail" "main" {
  name                          = "orgTrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}

resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "aws_config_configuration_recorder" "main" {
  name     = "configRecorder"
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported = true
  }
}

resource "aws_config_delivery_channel" "main" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

resource "aws_iam_role" "config_role" {
  name = "aws-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "config.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "config_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}



### Terraform: SNS + CloudWatch Alarm

resource "aws_sns_topic" "alerts" {
  name = "alert-topic"
}

resource "aws_cloudwatch_metric_alarm" "root_login" {
  alarm_name          = "RootLoginAlarm"
  metric_name         = "ConsoleLogin"
  namespace           = "AWS/CloudTrail"
  statistic           = "Sum"
  period              = 300
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  alarm_actions       = [aws_sns_topic.alerts.arn]
}


resource "aws_securityhub_account" "main" {}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}
