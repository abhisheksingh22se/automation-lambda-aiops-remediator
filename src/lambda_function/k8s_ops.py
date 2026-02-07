import base64
import logging
import re
import os
import boto3
from botocore.signers import RequestSigner
from kubernetes import client, config

logger = logging.getLogger()

#ENV Variables
CLUSTER_NAME = os.environ.get('CLUSTER_NAME', 'my-eks-cluster')
CLUSTER_ENDPOINT = os.environ.get('CLUSTER_ENDPOINT', '')
CLUSTER_CA = os.environ.get('CLUSTER_CA', '')

import boto3
import base64
import os


import boto3
import base64
import os
from botocore.signers import RequestSigner # <--- NEW IMPORT

def get_bearer_token(cluster_name):
    """
    Generates a secure k8s authentication token by manually signing 
    an STS GetCallerIdentity request with the required EKS headers.
    """
    region = os.environ.get('AWS_REGION', 'us-east-2')
    
    # 1. Setup Session & Client
    session = boto3.Session()
    client = session.client('sts', region_name=region)
    service_id = client.meta.service_model.service_id
    
    # 2. Create the Signer
    # This gives us control to add the specific EKS header
    signer = RequestSigner(
        service_id,
        region,
        'sts',
        'v4',
        session.get_credentials(),
        session.events
    )
    
    # 3. Construct the Request parameters
    # The 'x-k8s-aws-id' header is the critical piece EKS checks!
    params = {
        'method': 'GET',
        'url': f'https://sts.{region}.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15',
        'body': {},
        'headers': {
            'x-k8s-aws-id': cluster_name
        },
        'context': {}
    }
    
    # 4. Generate the Signed URL
    signed_url = signer.generate_presigned_url(
        params,
        region_name=region,
        expires_in=60,
        operation_name=''
    )
    
    # 5. Encode for Kubernetes
    # K8s expects: 'k8s-aws-v1.' + base64(URL) (with no padding '=')
    base64_url = base64.urlsafe_b64encode(signed_url.encode('utf-8')).decode('utf-8').rstrip('=')
    
    return 'k8s-aws-v1.' + base64_url

def load_k8s_config():
    
    token = get_bearer_token(CLUSTER_NAME)
    
    configuration = client.Configuration()
    configuration.host = CLUSTER_ENDPOINT
    configuration.verify_ssl = True
    configuration.ssl_ca_cert = None
    
    import tempfile
    ca_file = tempfile.NamedTemporaryFile(delete=False)
    ca_file.write(base64.b64decode(CLUSTER_CA))
    ca_file.close()
    configuration.ssl_ca_cert = ca_file.name
    
    configuration.api_key = {"authorization": "Bearer " + token}
    
    client.Configuration.set_default(configuration)

def delete_pod(namespace, label_selector):
    
    try:
        load_k8s_config()
        v1 = client.CoreV1Api()
        
        #1 Finding the pod
        logger.info(f"Looking for pods in {namespace} with label {label_selector}...")
        pods = v1.list_namespaced_pod(namespace, label_selector=label_selector)
        
        deleted_pods = []
        
        if not pods.items:
            logger.warning("No pods found to restart.")
            return "No pods found"
        
        #2 Deleting the pods
        for pod in pods.items:
            pod_name = pod.metadata.name
            logger.info(f"Deleting pod: {pod_name}")
            v1.delete_namespaced_pod(name=pod_name, namespace=namespace)
            deleted_pods.append(pod_name)
        
        return f"Successfully restarted: {deleted_pods}"
    
    except Exception as e:
        logger.error(f"Failed to delete pod: {str(e)}")
        return f"Error: {str(e)}"

def scale_deployment(namespace, deployment_name, replicas):
    
    try:
        load_k8s_config()
        apps_v1 = client.AppsV1Api()
        
        # Patching the deployment to scale
        body = {"spec": {"replicas": replicas}}
        
        logger.info(f"Scaling {deployment_name} to {replicas} replicas...")
        response = apps_v1.patch_namespaced_deployment_scale(
            name=deployment_name,
            namespace=namespace,
            body=body
        )
        
        return f"Scaled {deployment_name} to {response.spec.replicas}"
    
    except Exception as e:
        logger.error(f"Failed to scale deployment: {str(e)}")
        return f"Error: {str(e)}"
    