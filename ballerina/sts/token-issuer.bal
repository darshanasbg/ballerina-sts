package ballerina.sts;

import ballerina.jwt;
import ballerina.time;

function issueJwtToken () (string) {
    jwt:Header header = {};
    header.alg = "RS256";
    header.typ = "JWT";

    jwt:Payload payload = {};
    payload.sub = "John";
    payload.iss = "wso2";
    payload.aud = ["ballerina", "ballerinaSamples"];
    payload.exp = time:currentTime().time + 30000;

    jwt:JWTIssuerConfig config = {};
    config.certificateAlias = "wso2carbon";
    config.keyPassword = "wso2carbon";

    var jwtString, e = jwt:issue(header, payload, config);
    return jwtString;
}