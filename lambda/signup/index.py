import boto3
import json
import os

client = boto3.client("cognito-idp")

def lambda_handler(event, context):
    body = json.loads(event["body"])

    cpf = body["cpf"]          # 11-char unique ID
    name = body["name"]
    email = body["email"]
    cellphone = body["cellphone"]
    password = body["password"]

    try:
        resp = client.sign_up(
            ClientId=os.environ["USER_POOL_CLIENT"],
            Username=cpf,
            Password=cpf,
            UserAttributes=[
                {"Name": "custom:cpf", "Value": cpf},
                {"Name": "name", "Value": name},
                {"Name": "email", "Value": email},
                {"Name": "custom:cellphone", "Value": cellphone},
                {"Name": "custom:password", "Value": password}
            ]
        )

        # Optionally auto-confirm the user (requires admin permissions)
        client.admin_confirm_sign_up(
            UserPoolId=os.environ["USER_POOL_ID"],
            Username=cpf
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "User created",
                "userSub": resp["UserSub"]
            })
        }

    except client.exceptions.UsernameExistsException:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "User already exists"})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": str(e)})
        }
