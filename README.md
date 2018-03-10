This is a sample service to issue JWT token.
## Setup
Configure correct configuration parameters in ballerina.conf
Run sts service
ballerina run ballerina/sts

Run sample echo service
ballerina run samples/sts

## Sample token request
curl -v -X POST --basic -u username:Password -k  -d "grant_type=password&client-key=1234APItest@&scope=112"  https://localhost:9095/token

## Sample auth request
curl -k -H "Authorization:Bearer <token>" https://localhost:9096/echo
