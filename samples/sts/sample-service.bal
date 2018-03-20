package samples.sts;

import ballerina.net.http;
import ballerina.net.http.authadaptor;

endpoint http:ServiceEndpoint echoEP {
    port:9096,
    secureSocket:{
        keyStore: {
            filePath:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password:"ballerina"
        }
    }
};

@http:ServiceConfig {
    basePath:"/echo",
    endpoints: [echoEP]
} service<http:Service> helloWorld bind echoEP {
     @http:ResourceConfig {
         methods:["GET"],
         path:"/"
     }
     sayHello (endpoint outboundEP, http:Request req) {
         authadaptor:HttpJwtAuthnHandler handler = {};
         boolean isAuthenticated = false;
         if (handler.canHandle(req)) {
             isAuthenticated = handler.handle(req);
         }
         http:Response res = {};
         if (isAuthenticated) {
             res.setStringPayload("Hello ballerina\n");
         } else {
             res.setStringPayload("Invalid autentication\n");
         }
         _ = outboundEP -> respond(res);
     }
 }
