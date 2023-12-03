import os
import re
import json
import boto3

from aws_lambda_powertools import Tracer, Logger
from aws_lambda_powertools.utilities.data_classes import APIGatewayProxyEvent
from aws_xray_sdk.core import patch_all

patch_all()

logger = Logger()
tracer = Tracer()

# Outside of the lambda handler we get the parameter so that it will be persisted in Warm Starts.
ssm = boto3.client('ssm')
STRINGS_MAPPING_PARAMETER_NAME = os.environ["STRINGS_MAPPING_PARAMETER_NAME"]
strings_mapping: dict = json.loads(ssm.get_parameter(Name=STRINGS_MAPPING_PARAMETER_NAME)['Parameter']['Value'])


def case_insensitive_replace(text, pattern, replacement):
    """Takes as input a text and substitue the patterns ignoring casing"""

    regex_pattern = r"\b" + re.escape(pattern) + r"\b"
    replaced_text = re.sub(regex_pattern, replacement, text, flags=re.IGNORECASE)

    return replaced_text


@tracer.capture_lambda_handler
@logger.inject_lambda_context
def lambda_handler(event, _):
    """Replace all occurrences (from the 'content' attribute in body) of the keys in 
    the string_mapping (case insentive) with the corresponding values.

    POST /string/replace
    """
    logger.debug(event)

    event = APIGatewayProxyEvent(event)

    body = event.json_body
    content: str = body['content']
    polished = content

    for key, value in strings_mapping.items():
        logger.info({"message", f"Searching for {key} -> {value}"})
        polished = case_insensitive_replace(polished, key, value)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': polished
        })
    }
