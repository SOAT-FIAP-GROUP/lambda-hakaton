import boto3
import json
import os

client = boto3.client("cognito-idp")

def lambda_handler(event, context):
    body = json.loads(event["body"])

    cpf = body["cpf"]    # login with identity only
    password = body["password"]

    try:
        resp = client.initiate_auth(
            ClientId=os.environ["USER_POOL_CLIENT"],
            AuthFlow="USER_PASSWORD_AUTH",
            AuthParameters={
                "USERNAME": cpf,
                "PASSWORD": password
            }
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "idToken": resp["AuthenticationResult"]["IdToken"],
                "accessToken": resp["AuthenticationResult"]["AccessToken"],
                "refreshToken": resp["AuthenticationResult"]["RefreshToken"]
            })
        }

    except client.exceptions.NotAuthorizedException:
        return {
            "statusCode": 401,
            "body": json.dumps({"message": "Incorrect username or password"})
        }
    except client.exceptions.UserNotFoundException:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "User not found"})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": str(e)})
        }
