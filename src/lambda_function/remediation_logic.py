import logging
from k8s_ops import delete_pod, scale_deployment

logger = logging.getLogger()

def execute_remediation(alarm_detail):
    
    alarm_name = alarm_detail.get("alarmName", "")
    logger.info(f"Remediation Engine analyzing alarm: {alarm_name}")
    
    # 1. The Deployment Name (Used for Scaling) -> MUST BE "coredns"
    DEPLOYMENT_NAME = "coredns"
    
    # 2. The Label Selector (Used for Finding Pods) 
    POD_LABEL = "k8s-app=kube-dns"
    
    # 3. The Namespace
    NAMESPACE = "kube-system"
    
    response = {"action": "none", "target": DEPLOYMENT_NAME}
    
    # The Logic
    if "high-cpu" in alarm_name.lower():
        logger.info(f"Detected High CPU. Action: Scale Up {DEPLOYMENT_NAME}")
        
        # FIX: Use DEPLOYMENT_NAME ("coredns") here
        k8s_result = scale_deployment(namespace=NAMESPACE, deployment_name=DEPLOYMENT_NAME, replicas=3)
        response["action"] = "scale_up"
        response["details"] = k8s_result
    
    elif "high-memory" in alarm_name.lower():
        logger.info(f"Detected High Memory. Action: Restart Pods with label {POD_LABEL}")
        
        # FIX: Use POD_LABEL ("k8s-app=kube-dns") here
        k8s_result = delete_pod(namespace=NAMESPACE, label_selector=POD_LABEL)
        response["action"] = "pod_restart"
        response["details"] = k8s_result
        
    else:
        logger.warning(f"No remediation rules matched for alarm: {alarm_name}")
        response["message"] = "No rule matched"
    
    return response
    