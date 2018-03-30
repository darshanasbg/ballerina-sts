package sts;

import ballerina/config;
import ballerina/io;

const string STS_CONFIG = "STS_Configurations";
const string ISSUER = "issuer";
const string KEY_ALIAS = "signingKeyAlias";
const string KEY_PASSWORD = "signingKeyPassword";
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

function loadApplicationConfig () returns (ApplicationConfig) {
    ApplicationConfig sts = {};
    sts.issuer = getStringConfigValue(STS_CONFIG, ISSUER);
    sts.signingAlg = getStringConfigValue(STS_CONFIG, SIGNING_ALG);
    sts.keyAlias = getStringConfigValue(STS_CONFIG, KEY_ALIAS);
    sts.keyPassword = getStringConfigValue(STS_CONFIG, KEY_PASSWORD);
    string exp = getStringConfigValue(STS_CONFIG, DEFAULT_TOKEN_EXPIRY_TIME);
    if (exp != "") {
        sts.expTime =? <int>exp;
    }
    map applicationMap = {};
    string applications = getStringConfigValue(STS_CONFIG, APP_ID);
    if (applications != null) {
        string[] applicationList = applications.split(" ");
        foreach app in applicationList {
            string audList = getStringConfigValue(app, AUDIENCE);
            if (audList != null) {
                applicationMap[app] = audList.split(" ");
            }
        }
    }
    sts.apps = applicationMap;
    return sts;
}

function getStringConfigValue (string instanceId, string property) returns (string) {
    match config:getAsString(instanceId + "." + property) {
        string value => {
            return value == null ? "" : value;
        }
        any|null => return "";
    }
}