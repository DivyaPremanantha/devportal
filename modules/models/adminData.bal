# Response for content storage.
#
# + assetMappings - field description  
# + timeUploaded - field description
public type OrgContentResponse record {
    OrganizationAssets assetMappings;
    string timeUploaded;
};

# Response for organization creation.
#
# + assetMappings - field description  
# + timeUploaded - field description
public type OrgCreationResponse record {
    
    string orgName;
    string orgId;
    boolean isPublic;
    string[] authenticatedPages;
};

# Response for API content storage.
#
# + assetMappings - field description  
# + timeUploaded - field description
public type APIContentResponse record {
    APIAssets assetMappings;
    string timeUploaded;
};



# Assets needed for the org landing page.
# pageType - field description
# pageContent - field description
# + orgId - field description
public type OrganizationAssets record {|
    string pageType;
    string dirName;
    string pageName;
    string pageContent;
    string orgId;
    string orgName;
|};

public type Organization record {

    string orgName;
    boolean isPublic;
    string[] authenticatedPages?;
};

# Assets needed for the api landing page.
#
# + apiImages - field description  
# + apiContent - field description  
# + apiId - field description
public type APIAssets record {|
    string[] apiImages;
    string apiContent;
    string fileName;
    string apiId;
|};

public type APIImages record {|
    string imageName;
    string imageTag;
    byte[] image;
|};

public type OrgImages record {|
    string imageName;
    byte[] image;
|};

# Description.
#
# + themeId - field description  
# + orgId - field description  
# + createdAt - field description
public type ThemeResponse record {
    string themeId;
    string orgId;
    string createdAt;
};

# Identity Provider configured for dev portal.
#
# + issuer - field description  
# + authorizationURL - field description  
# + tokenURL - field description  
# + userInfoURL - field description  
# + clientId - field description  
# + callbackURL - field description  
# + scope - field description  
# + signUpURL - field description
public type IdentityProvider record {
    string issuer;
    string authorizationURL;
    string tokenURL; 
    string userInfoURL;
    string clientId;
    string callbackURL;
    string scope;
    string signUpURL;
    string logoutURL;
    string logoutRedirectURI;
};



# Response for IdentityProvider creaton.
#
# + id - field description  
# + name - field description  
# + 'type - field description  
# + issuer - field description  
# + clientId - field description  
public type IdentityProviderResponse record {
    string id;
    string clientId;
    string orgName;
    string issuer;
    string authorizationURL;
    string tokenURL; 
    string userInfoURL;
    string callbackURL;
    string scope;
    string signUpURL;
    string logoutURL;
    string logoutRedirectURI;
};

public type SubscriptionPlanMappingResponse record {|
    readonly string mappingId;
    SubscriptionPlanResponse subscriptionPlan;
    ApiMetadata apimetadata;
|};

public type SubscriptionPlan record {|
    string policyName;
    string displayName;
    string description;
|};

public type SubscriptionPlanResponse record {|
    readonly string subscriptionPlanID;
    string policyName;
    string displayName;
    string description;
    string orgId;
|};

public type SubscriptionResponse record {|
    readonly string subscriptionId;
    string userName;
	Organization organization;
    SubscriptionPlanResponse subscriptionPlan;
    ApiMetadata apimetadata;
|};




