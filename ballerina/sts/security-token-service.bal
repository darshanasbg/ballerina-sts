package ballerina.sts;

import ballerina.net.http;
import ballerina.auth.utils;
import ballerina.net.http.authadaptor;

endpoint http:ServiceEndpoint tokenEP {
    port:9095,
    secureSocket:{
        keyStore: {
            filePath:"${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password:"ballerina"
        }
    }
};

@http:ServiceConfig {
      basePath:"/token",
      endpoints: [tokenEP]
}
service<http:Service> stsService bind tokenEP {
     @http:ResourceConfig {
         methods:["POST"],
         path:"/"
     }
     token (endpoint outboundEP, http:Request req) {

         TokenRequest tokenRequest;
         TokenResponse tokenResponse;
         ErrorResponse eResp;

         tokenRequest, eResp = validateRequest(req);
         if (eResp == null) {
             tokenResponse, eResp = issue(tokenRequest);
         }

         http:Response res = {};
         if (tokenResponse != null) {
             var j, _ = <json>tokenResponse;
             res.setJsonPayload(j);
             res.statusCode = 200;
         } else {
             res.setStringPayload(eResp.message);
             res.statusCode = eResp.statuesCode;
         }
         _ = outboundEP -> respond(res);
     }
 }

function validateRequest (http:Request req) (TokenRequest, ErrorResponse) {
    string contentType = req.getHeader(CONTENT_TYPE);
    if (APPLICATION_FORM != contentType) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_request: Content type not supported";
        return null, eResp;
    }
    //Get input data
    var basicAuthHeaderValue, err = authadaptor:extractBasicAuthHeaderValue(req);
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
