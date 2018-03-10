package samples.sts;

import ballerina.net.http;
import ballerina.auth.jwtAuth;

@http:configuration {
    basePath:"/echo",
    httpsPort:9096,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina"
}service<http> helloWorld {
     @http:resourceConfig {
         methods:["GET"],
         path:"/"
     }    resource sayHello (http:Connection conn, http:InRequest req) {
         jwtAuth:HttpJwtAuthnHandler handler = {};
         boolean isAuthenticated = false;
         if (handler.canHandle(req)) {
             isAuthenticated = handler.handle(req);
         }
         http:OutResponse res = {};
         if (isAuthenticated) {
             res.setStringPayload("Hello ballerina\n");
         } else {
             res.setStringPayload("Invalid autentication\n");
         }
         _ = conn.respond(res);
     }
 }
