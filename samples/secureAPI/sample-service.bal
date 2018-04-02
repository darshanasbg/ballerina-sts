package secureAPI;

import ballerina/http;
import ballerina/io;
import ballerina/auth;

endpoint http:ApiEndpoint echoEP {
    port:9096,
    secureSocket:
    {
        keyStore:
        {
            filePath:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password:"ballerina"
        }
    }
};

@http:ServiceConfig {
    basePath:"/echo"
    //endpoints:[echoEP]
}
@auth:Config {
    authentication:{enabled:true},
    scopes:["scope1"]
}service<http:Service> helloWorld bind echoEP {
     @http:ResourceConfig {
         methods:["GET"],
         path:"/"
     }
     @auth:Config {
         scopes:["scope1"]
     }
     sayHello (endpoint outboundEP, http:Request req) {
         http:Response res = {};
         res.setStringPayload("Hello ballerina\n");
         _ = outboundEP -> respond(res);
     }
 }
