# Alarm 1: The Frozen Server Detector "High CPU"
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name = "${var.cluster_name}-high-cpu-alarm"
  alarm_description = "Triggers when CPU exceeds threshold for 2 minutes"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  period = 60
  statistic = "Average"

  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"
  threshold = var.cpu_threshold

  dimensions = {
    AutoScalingGroupName = "eks-${var.cluster_name}-workers-asg"
  }
}

# Alarm 2: The Memory Leak Detector "High Memory"
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name = "${var.cluster_name}-high-memory-alarm"
  alarm_description = "Triggers when Memory Utilization is critical"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods =2 
  period = 60
  statistic = "Average"
  threshold = 85

  namespace = "ContainerInsights"
  metric_name = "node_memory_utilization"

  dimensions = {
    ClusterName = var.cluster_name
  }
}