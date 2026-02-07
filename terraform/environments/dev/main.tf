#1 Anomaly Detection Module
module "aiops_remediation" {
    source = "../../modules/anomaly-detection"

    #Inputs
    env_name = "dev"
    cluster_name = "eks-infra-cluster" # Must match your real cluster name
    aws_region = "us-east-2"

    #Network
    vpc_id = "vpc-08f1d469a600cdeaa" # Replace
    subnet_ids = [
        "subnet-028b0ecec490fa1e9",
        "subnet-05393186f1c0cc0d3",
        "subnet-073a86efe322ae7f3",
        "subnet-07c32a55e05be3af3"
    ] # Replace

    #Tuning
    cpu_threshold = 90
    log_retention = 7
}

#2 Event Bus Module
module "event_bus" {
  source = "../../modules/event-bus"

  target_lambda_arn = module.aiops_remediation.lambda_arn
  target_lambda_name = module.aiops_remediation.lambda_name

  trigger_alarm_names = [
    "eks-infra-cluster-high-cpu-alarm",
    "eks-infra-cluster-high-memory-alarm"
  ]
}