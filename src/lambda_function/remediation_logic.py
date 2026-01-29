import logging
from k8s_ops import delete_pod, scale_deployment

logger = logging.getLogger()

def execute_remediation(alarm_detail):
    
    alarm_name = alarm_detail.get("alarmName", "")
    
    #Mocking the remediation logic based on alarm name
    target_app = "frontend-service"
    target_namespace = "default"
    
    response = {"action": "none", "target": target_app}
    
    #Decision tree
    if "CPU-Anomaly" in alarm_name:
        logger.info(f"Detected CPU Anomaly on {target_app}. Action: Restart Pod")
        
        #Restarting the pod
        k8s_result = delete_pod(namespace=target_namespace, label_selector=f"app={target_app}")
        response["action"] = "pod_restart"
        response["details"] = k8s_result
    
    elif "Memory-Anomaly" in alarm_name:
        logger.info(f"Detected Memory Leak on {target_app}. Action: Scale Up")
        
        #Scaling up the pods
        k8s_result = scale_deployment(namespace=target_namespace, deployment_name=target_app, replicas=3)
        response["action"] = "scale_up"
        response["details"] = k8s_result
        
    else:
        logger.warning(f"No remediation rules matched for alarm: {alarm_name}")
        response["message"] = "No rule matched"
    
    return response
    