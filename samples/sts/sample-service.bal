package samples.sts;

import ballerina.net.http;
import ballerina.auth.jwtAuth;

endpoint<http:Service> echoEP {
    port:9096,
    ssl:{
        keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
        keyStorePassword:"ballerina",
        certPassword:"ballerina"
    }
}

@http:serviceConfig {
    basePath:"/echo",
    endpoints: [echoEP]
} service<http:Service> helloWorld {
     @http:resourceConfig {
         methods:["GET"],
         path:"/"
     }
     resource sayHello (http:ServerConnector conn, http:Request req) {
         jwtAuth:HttpJwtAuthnHandler handler = {};
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
         _ = conn -> respond(res);
     }
 }
