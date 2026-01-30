import json
import boto3
import os

cognito = boto3.client("cognito-idp", region_name=os.environ["AWS_REGION"])

def lambda_handler(event, context):
    try:
        # API Gateway + Cognito Authorizer: user claims are in requestContext
        claims = event.get("requestContext", {}).get("authorizer", {}).get("claims")

        if claims:
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "username": claims.get("cognito:username"),
                    "email": claims.get("email"),
                    "sub": claims.get("sub")
                })
            }

        # Fallback: use token directly
        headers = event.get("headers", {})
        auth_header = headers.get("Authorization") or headers.get("authorization")
        if not auth_header:
            return {"statusCode": 401, "body": json.dumps({"error": "Missing Authorization header"})}

        token = auth_header.replace("Bearer ", "")
        resp = cognito.get_user(AccessToken=token)

        return {"statusCode": 200, "body": json.dumps(resp)}

    except Exception as e:
        print("Error:", str(e))
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
