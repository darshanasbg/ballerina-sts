package ballerina.sts;

import ballerina.config;

const string STS_CONFIG = "STS_Configurations";
const string ISSUER = "issuer";
const string KEY_ALIAS = "signingKeyAlias";
const string KEY_PASSWORD ="signingKeyPassword";
const string SIGNING_ALG = "signingAlg";
const string DEFAULT_TOKEN_EXPIRY_TIME = "defaultTokenExpiryTime";
const string APP_ID = "appID";
const string AUDIENCE = "audience";
const string JWT = "JWT";

struct ApplicationConfig {
    string issuer;
    string signingAlg;
    string keyAlias;
    string keyPassword;
    int expTime;
    map apps;
}

function loadApplicationConfig () (ApplicationConfig) {
    ApplicationConfig sts = {};
    sts.issuer = config:getInstanceValue(STS_CONFIG, ISSUER);
    sts.signingAlg = config:getInstanceValue(STS_CONFIG, SIGNING_ALG);
    sts.keyAlias = config:getInstanceValue(STS_CONFIG, KEY_ALIAS);
    sts.keyPassword = config:getInstanceValue(STS_CONFIG, KEY_PASSWORD);
    var exp, e = <int>config:getInstanceValue(STS_CONFIG, DEFAULT_TOKEN_EXPIRY_TIME);
    sts.expTime = exp;
    map applicationMap = {};
    string applications = config:getInstanceValue(STS_CONFIG, APP_ID);
    if (applications != null) {
        string[] applicationList = applications.split(" ");
        foreach app in applicationList {
            string audList = config:getInstanceValue(app, AUDIENCE);
            if(audList != null){
                applicationMap[app] = audList.split(" ");
            }
        }
    }
    sts.apps = applicationMap;
    return sts;
}