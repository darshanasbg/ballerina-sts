# Ballerina security token service [STS]
Ballerina security token service is a lightweight Identity provider which is capable of issuing self contained access tokens for small scale deployments.

![alt text](https://github.com/isharak/ballerina-sts/blob/master/Bal-STS.png)

## Configurations
ballerina.conf file includes all configuration required to configure security token service and echo service.
Follow the provided inline instruction in configuration file.

## Run sts service :
Inside the ballerina-sts folder
```
ballerina run ballerina/sts
```

Run sample echo service :
Inside the ballerina-sts folder
```
cd samples/
ballerina run secureAPI
```

## Sample token request
```
curl -v -X POST -H "content-type:application/x-www-form-urlencoded" --basic -u <client_id>:<client_secret optional> -k
-d "grant_type=password&username=<userName>&password=<password>&scope=<scopes optional>" https://localhost:9095/token

curl -v -X POST -H "content-type:application/x-www-form-urlencoded" --basic -u 10001:klk -k -d "grant_type=password&username=ishara&password=abc&scope=112" https://localhost:9095/token
```
## Sample auth request
```
curl -k -H "Authorization:Bearer <token>" https://localhost:9096/echo

curl -k --basic -u ishara:abc https://localhost:9096/echo
```