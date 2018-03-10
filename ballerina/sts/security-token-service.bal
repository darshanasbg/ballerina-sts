package ballerina.sts;

import ballerina.net.http;
@http:configuration {
    basePath:"/token",
    httpsPort:9095,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina"
}service<http> helloWorld {
     @http:resourceConfig {
         methods:["POST"],
         path:"/"
     }    resource sayHello (http:Connection conn, http:InRequest req) {
         http:OutResponse res = {};
         res.setStringPayload(issueJwtToken());
         _ = conn.respond(res);
     }
 }

