public type ApiArtifactsResponse record {
    string[] apiContent;
    map<string> apiImages;
};
public type ApiArtifacts record {
    map<string> apiImages;
};
public type ApiInfo record {
    string orgName;
    string apiName;
    string apiCategory;
    string tags;
    string apiDescription;
    string apiVersion;
    string apiType;
    string  apiDefinition?;
    map<string> additionalProperties;
    string[] authorizedRoles?;
    ApiArtifacts apiArtifacts;
};

public type ApiInfoResponse record {
    string orgName;
    string apiName;
    string apiCategory;
    string[] tags;
    string apiDescription;
    string apiVersion;
    string apiType;
    string[] authorizedRoles?;
    map<string> additionalProperties;
    ApiArtifactsResponse apiArtifacts;
};

# Description.
#
# + 'category - field description  
# + policyName - field description  
# + description - field description
public type ThrottlingPolicy record {
    string 'category?;
    string policyName;
    string description;
};

# Description.
#
# + sandboxUrl - field description  
# + productionUrl - field description
public type ServerUrl record {
    string sandboxUrl;
    string productionUrl;
};

# Description.
#
# + apiInfo - api information  
# + throttlingPolicies - details about the throttling policies  
# + serverUrl - Gateway server urls
public type ApiMetadata record {
    ApiInfo apiInfo;
    ThrottlingPolicy[] throttlingPolicies?;
    #Subscription[] subscriptions;
    ServerUrl serverUrl;
    string[] subscriptionPlans?;
};

public type ApiMetadataResponse record {
    ApiInfoResponse apiInfo;
    ThrottlingPolicy[]? throttlingPolicies;
    ServerUrl serverUrl;
    SubscriptionPlan[] subscriptionPlans?;
};

public type SubscriptionPlanMapping record {|
    readonly string mappingId;
    string subscriptionPlanID;
    string apiId;
|};

public type SubscriptionPlanMappingResponse record {|
    string subscriptionPlanID;
|};