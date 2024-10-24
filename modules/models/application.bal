# Represents content to be included in the application section.
#
# + appId - application id  
# + applicationName - application name  
# + appProperties - list of properties as application information  
# + addedAPIs - list of added APIs for the application  
# + accessControl - access control for the application  
public type Application record {|

    readonly string appId;
    string applicationName;
    string description;
    ApplicationProperties[] appProperties;
    string addedAPIs;
    ApplicationUser[] accessControl;
    ApplicationKeys[] appKeys;
    IdentityProvider idp;
|};

public type ApplicationKeys record {|

    string clientId;
    string clientSecret;
    string idpId;
    string keyType;
    Application application;

|};

public type APISubscription record {|
    readonly string subscriptionId;
    string apiId;
    string orgId;
    string userId;
    string policyID;
    string orgName;
|};

public type ApplicationProperties record {
    string name;
    string value;
};

public type ApplicationUser record {|
    string role;
    string userName;
    boolean appOwner;
|};

public type API record {|
    string id;
    string name;
|};

public type Review record {|
    readonly string reviewId;
    string orgName;
    string comment;
    int rating;
    string reviewedBy;
    string apiId;
    string apiName;
|};


