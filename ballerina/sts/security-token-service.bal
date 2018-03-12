package ballerina.sts;

import ballerina.net.http;
import ballerina.io;
import ballerina.auth.utils;
@http:configuration {
    basePath:"/token",
    httpsPort:9095,
    keyStoreFile:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
    keyStorePassword:"ballerina",
    certPassword:"ballerina"
}service<http> stsService {
     @http:resourceConfig {
         methods:["POST"],
         path:"/"
     }    resource token (http:Connection conn, http:InRequest req) {

         TokenRequest tokenRequest;
         TokenResponse tokenResponse;
         ErrorResponse eResp;

         tokenRequest, eResp = validateRequest(req);
         if (eResp == null) {
             tokenResponse, eResp = issue(tokenRequest);
         }

         http:OutResponse res = {};
         if (tokenResponse != null) {
             var j, _ = <json>tokenResponse;
             res.setJsonPayload(j);
             res.statusCode = 200;
         } else {
             res.setStringPayload(eResp.message);
             res.statusCode = eResp.statuesCode;
         }
         _ = conn.respond(res);
     }
 }

function validateRequest (http:InRequest req) (TokenRequest, ErrorResponse) {
    string contentType = req.getHeader(CONTENT_TYPE);
    if (APPLICATION_FORM != contentType) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_request: Content type not supported";
        return null, eResp;
    }
    //Get input data
    var basicAuthHeaderValue, err = utils:extractBasicAuthHeaderValue(req);
    var inClientId, inClientSecret, err = utils:extractBasicAuthCredentials(basicAuthHeaderValue);

    var params, _ = req.getFormParams();
    var inGrantType, _ = (string)params.grant_type;
    var inUserName, _ = (string)params.username;
    var inPassword, _ = (string)params.password;
    var inScope, _ = (string)params.scope;
    var inState, _ = (string)params.state;
    if ("password" != inGrantType || inClientId == null || inUserName == null || inPassword == null) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_request: Request parameters are not valied";
        return null, eResp;
    }

    TokenRequest tokenRequest = {};
    tokenRequest.grantType = inGrantType;
    tokenRequest.client_id = inClientId;
    tokenRequest.userName = inUserName;
    tokenRequest.credential = inPassword;
    tokenRequest.scope = inScope;
    tokenRequest.state = inState;
    return tokenRequest, null;
}
