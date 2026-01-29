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

def get_bearer_token():
    STS_TOKEN_EXPIRES = 60
    session = boto3.session.Session()
    client = session.client('sts')
    service_id = client.meta.service_model.service_id
    
    signer = RequestSigner(
        service_id,
        os.environ.get('AWS_REGION', 'us-east-1'),
        'sts',
        'v4',
        session.get_credentials(),
        session.events
    )