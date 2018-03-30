package sts;

import ballerina/mime;
import ballerina/net.http;
import ballerina/auth.utils;
import ballerina/net.http.authadaptor;

endpoint http:ServiceEndpoint tokenEP {
    port:9095,
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
    basePath:"/token",
    endpoints:[tokenEP]
}
service<http:Service> stsService bind tokenEP {
    @http:ResourceConfig {
        methods:["POST"],
        path:"/"
    }
    token (endpoint outboundEP, http:Request req) {

        TokenRequest tokenRequest = {};
        TokenResponse tokenResponse = {};
        ErrorResponse eResp = {};

        match validateRequest(req) {
            TokenRequest tRequest => {
                match issue(tRequest) {
                    TokenResponse tResponse => tokenResponse = tResponse;
                    ErrorResponse eResponse => eResp = eResponse;
                }
            }
            ErrorResponse eResponse => eResp = eResponse;
        }

        http:Response res = {};
        if (tokenResponse.access_token != null) {
            var j =? <json>tokenResponse;
            res.setJsonPayload(j);
            res.statusCode = 200;
        } else {
            res.setStringPayload(eResp.message);
            res.statusCode = eResp.statuesCode;
        }
        _ = outboundEP -> respond(res);
    }
}

function validateRequest (http:Request req) returns (TokenRequest|ErrorResponse) {
    string contentType = req.getHeader(CONTENT_TYPE);
    if (APPLICATION_FORM != contentType) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_request: Content type not supported";
        return eResp;
    }

    string basicAuthHeaderValue;
    match authadaptor:extractBasicAuthHeaderValue(req) {
        string basicAuthHeaderStr => {
            basicAuthHeaderValue = basicAuthHeaderStr;
        }
        any|null => {
            ErrorResponse eResp = {};
            eResp.statuesCode = 401;
            eResp.message = "invalid_client: Client authentication failed";
            return eResp;
        }
    }

    string inClientId;
    string inClientSecret;
    match utils:extractBasicAuthCredentials(basicAuthHeaderValue) {
        (string, string) creds => {
            var (id, secret) = creds;
            inClientId = id;
            inClientSecret = secret;
        }
        error err => {
            ErrorResponse eResp = {};
            eResp.statuesCode = 401;
            eResp.message = "invalid_client: Client authentication failed";
            return eResp;
        }
    }

    string inGrantType;
    string inUserName;
    string inPassword;
    string inScope;
    string inState;
    match req.getFormParams() {
        map p => {
            inGrantType = <string>p.grant_type;
            inUserName = <string>p.username;
            inPassword = <string>p.password;
            inScope = <string>p.scope;
            inState = <string>p.state;
        }
        mime:EntityError err => {
            ErrorResponse eResp = {};
            eResp.statuesCode = 400;
            eResp.message = "invalid_request: Request parameters are not valied";
            return eResp;
        }
    }

    if ("password" != inGrantType || inClientId == null || inUserName == null || inPassword == null) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_request: Request parameters are not valied";
        return eResp;
    }

    TokenRequest tokenRequest = {};
    tokenRequest.grantType = inGrantType;
    tokenRequest.client_id = inClientId;
    tokenRequest.userName = inUserName;
    tokenRequest.credential = inPassword;
    tokenRequest.scope = inScope;
    tokenRequest.state = inState;
    return tokenRequest;
}
