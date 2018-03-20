package ballerina.sts;

import ballerina.jwt;
import ballerina.time;
import ballerina.auth.userstore;
import ballerina.auth.basic;
import ballerina.util;

@Description {value:"Represents a oauth2 access token request"}
@Field {value:"scope: Scope of the access token"}
@Field {value:"state: 'state' parameter"}
struct TokenRequest {
    string client_id;
    string grantType;
    string userName;
    string credential;
    string scope;
    string state;
}

@Description {value:"Represents a oauth2 access token response"}
@Field {value:"access_token: [REQUIRED] The access token issued by the authorization server"}
@Field {value:"token_type: [REQUIRED] The type of the token issued"}
@Field {value:"expires_in: [RECOMMENDED] The lifetime in seconds of the access token"}
@Field {value:"scope: [OPTIONAL] The scope of the access token"}
@Field {value:"state: [OPTIONAL] If the 'state' parameter was present in the client authorization request"}
struct TokenResponse {
    string access_token;
    string token_type;
    int expires_in;
    // TODO define scope and state parameters in future.
    // string scope;
    // string state;
}

struct ErrorResponse {
    int statuesCode;
    string message;
}

basic:BasicAuthenticator authenticator;

function issue (TokenRequest tokenRequest) (TokenResponse, ErrorResponse) {
    //var tokenResponse, err = issueJwtToken();
    ApplicationConfig appConfig = loadApplicationConfig();
    if (isAuthenticatedUser(tokenRequest)) {
        var token, e = issueToken(tokenRequest, appConfig);
        if (e != null) {
            ErrorResponse eResp = {};
            eResp.statuesCode = 400;
            if (e.message != null) {
                eResp.message = "invalid_request : " + e.message;
            } else {
                eResp.message = "invalid_request : Invalid input or error while processing the request";
            }
            return null, eResp;
        }
        else {
            TokenResponse tokenResponse = {};
            tokenResponse.access_token = token;
            tokenResponse.expires_in = appConfig.expTime / 1000;
            tokenResponse.token_type = "Bearer";
            return tokenResponse, null;
        }
    } else {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "invalid_grant : Invalid resource owner credentials";
        return null, eResp;
    }
}

function isAuthenticatedUser (TokenRequest tokenRequest) (boolean) {
    if (authenticator == null) {
        userstore:FilebasedUserstore fileBasedUserstore = {};
        userstore:UserStore fileBasedUserStore = (userstore:UserStore)fileBasedUserstore;
        authenticator = {userStore:fileBasedUserStore, authCache:null};
    }
    return authenticator.authenticate(tokenRequest.userName, tokenRequest.credential);
}

function issueToken (TokenRequest tokenRequest, ApplicationConfig appConfig) (string, error) {
    jwt:Header header = createHeader(appConfig);
    jwt:Payload payload = createPayload(tokenRequest, appConfig);

    jwt:JWTIssuerConfig config = {};
    config.certificateAlias = appConfig.keyAlias;
    config.keyPassword = appConfig.keyPassword;
    var jwtString, e = jwt:issue(header, payload, config);
    return jwtString, e;
}

function issueJwtToken () (TokenResponse, ErrorResponse) {
    int tokenExpTime = 300000; // In milliseconds.
    jwt:Header header = {};
    header.alg = "RS256";
    header.typ = "JWT";

    jwt:Payload payload = {};
    payload.sub = "John";
    payload.iss = "wso2";
    payload.aud = ["ballerina", "ballerinaSamples"];
    payload.exp = time:currentTime().time + tokenExpTime;

    jwt:JWTIssuerConfig config = {};
    config.certificateAlias = "wso2carbon";
    config.keyPassword = "wso2carbon";

    var jwtString, e = jwt:issue(header, payload, config);
    if (e != null) {
        ErrorResponse eResp = {};
        eResp.statuesCode = 400;
        eResp.message = "Invalid input or error while processing the request";
        return null, eResp;
    }
    else {
        TokenResponse tokenResponse = {};
        tokenResponse.access_token = jwtString;
        tokenResponse.expires_in = tokenExpTime / 1000;
        tokenResponse.token_type = "Bearer";
        return tokenResponse, null;
    }
}

function createHeader (ApplicationConfig appConfig) (jwt:Header) {
    jwt:Header header = {};
    header.alg = appConfig.signingAlg;
    header.typ = JWT;
    return header;
}

//TODO change the function to process security context and add user claims.
function createPayload (TokenRequest tokenRequest, ApplicationConfig appConfig) (jwt:Payload) {
    jwt:Payload payload = {};

    //TODO Need to get this from securityContext
    payload.sub = tokenRequest.userName;
    payload.iss = appConfig.issuer;
    payload.exp = time:currentTime().time + appConfig.expTime;
    payload.iat = time:currentTime().time;
    payload.nbf = time:currentTime().time;
    payload.jti = util:uuid();
    var audArray, e = (string[])appConfig.apps[tokenRequest.client_id];
    payload.aud = audArray;
    //TODO need to set user claim from security context
    return payload;
}

function createJWTIssueConfig (ApplicationConfig appConfig) (jwt:JWTIssuerConfig) {
    jwt:JWTIssuerConfig config = {};
    config.certificateAlias = appConfig.keyAlias;
    return config;
}