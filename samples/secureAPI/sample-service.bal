package secureAPI;

import ballerina/net.http;
import ballerina/net.http.endpoints;
import ballerina/io;
import ballerina/auth;

endpoint endpoints:ApiEndpoint echoEP {
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
    authentication:{enabled:true}
    //scope:"xxx"
}service<http:Service> helloWorld bind echoEP {
     @http:ResourceConfig {
         methods:["GET"],
         path:"/"
     }
     @auth:Config {
         //scope:"scope2"
     }
     sayHello (endpoint outboundEP, http:Request req) {
         http:Response res = {};
         res.setStringPayload("Hello ballerina\n");
         _ = outboundEP -> respond(res);
     }
 }
