const amplifyconfig = ''' {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "Chat_Example": {
                    "endpointType": "GraphQL",
                    "endpoint": "YOURENDPOINT",
                    "region": "us-west-2",
                    "authorizationType": "API_KEY",
                    "apiKey": "YOURAPIKEY"
                }
            }
        }
    }
}''';
