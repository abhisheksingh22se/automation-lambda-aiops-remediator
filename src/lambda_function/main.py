import json
import logging
import os
from remediation_logic import execute_remediation

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info(f"Received Event: {json.dumps(event)}")

    try:
        #1 Parsing the event
        detail = event.get("detail", {})
        
        #2 Extracting key info
        alarm_name = detail.get("alarmName", "Unknown Alarm")
        state_value = detail.get("state", {}).get("value", "UNKNOWN")
        
        logger.info(f"Processing Alarm: {alarm_name} | State: {state_value}")
        
        #3 Preventing false positives
        if state_value != "ALARM":
            logger.info("Alarm state is not 'ALARM'. Exiting")
            return {"status": "ignored", "reason": "Not in ALARM state"}
        
        #4 Executing remediation
        result = execute_remediation(detail)
        
        return{
            "statusCode": 200,
            "body": json.dumps(result)
        }
        
    except Exception as e:
        logger.error(f"Critical failure in Remediation Engine: {str(e)}")
        return{
            "statusCode": 500,
            "body": json.dumps(f"Error: {str(e)}")
        }