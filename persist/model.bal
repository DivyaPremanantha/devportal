import ballerina/persist as _;
import ballerina/persist as _;
import ballerinax/persist.sql;
# Description.
#
# + policyId - field description  
# + 'type - field description  
# + policyName - field description  
# + description - field description
public type ThrottlingPolicy record {|
    readonly string policyId;
    string 'type;
    string policyName;
    string description;
    ApiMetadata apimetadata;
    Subscription? subscription;
|};

# Description.
# + policyId - field description 
# + policyName - field description  
# + policyInfo - field description
public type RateLimitingPolicy record {|
    readonly string policyId;
    string policyName;
    string policyInfo;
|};

# Description.
#
# + reviewId - field description  
# + rating - field description  
# + comment - field description  
# + apiFeedback - field description  
# + reviewedBy - field description
public type Review record {|
    readonly string reviewId;
    int rating;
    string comment;
    ApiMetadata apiFeedback;
    User reviewedBy;
|};

# Description.
#
# + apiId - api id  
# + orgId - organization id  
# + apiName - field description  
# + metadata - field description  
# + organizationName - field description  
# + apiCategory - field description  
# + apiVersion - field description  
# + apiDescription - field description  
# + tags - field description  
# + apiDefinition - field description  
# + additionalProperties - field description  
# + throttlingPolicies - details about the throttling policies  
# + productionUrl - field description  
# + sandboxUrl - field description  
# + reviews - field description  
# + subscriptions - field description  
# + apiContent - field description  
# + apiImages - field description  
# + authorizedRoles - field description
public type ApiMetadata record {|
    readonly string apiId;
    readonly string orgId;
    string apiName;
    string metadata;
    string organizationName;
    string apiCategory;
    string apiVersion;
    string apiDescription;
    string apiType;
    string tags;
    string apiDefinition;
    AdditionalProperties[] additionalProperties;
    ThrottlingPolicy[] throttlingPolicies;
    string productionUrl;
    string sandboxUrl;
    Review[] reviews;
    Subscription[] subscriptions;
    ApiContent[] apiContent;
    ApiImages[] apiImages;
    string? authorizedRoles;
|};


public type ApiContent record {|
    readonly string apiContentId;
    ApiMetadata apimetadata;
    string apiContent;
	string fileName;
|};

public type ApiImages record {|
    readonly string imageTag;
    readonly string apiId;
    readonly string orgId;
    @sql:Relation {keys: ["apiId", "orgId"]}
	ApiMetadata apimetadata;
    string imagePath;
    byte[] image;
|};

public type OrgImages record {|
    readonly string orgId;
    @sql:Relation {keys: ["orgId"]}
	Organization organization;
    readonly string fileName;
    byte[] image;
|};

public type AdditionalProperties record {|
    readonly string apiId;
    readonly string orgId;
    @sql:Relation {keys: ["apiId", "orgId"]}
	ApiMetadata apimetadata;
    readonly string key;
    string value;
|};

# Identity Provider configured for dev portal.
#
# + idpID - field description  
# + id - field description  
# + name - field description  
# + 'type - field description  
# + issuer - field description  
# + clientId - field description  
# + clientSecret - field description  
# + organization - field description
public type IdentityProvider record {|
    readonly string idpId;
    string orgName;
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
    Organization organization;
|};

# Represents content to be included in the application section.
#
# + appId - application id  
# + applicationName - application name  
# + sandBoxKey - field description  
# + productionKey - field description  
# + appProperties - list of properties as application information  
# + addedAPIs - list of added APIs for the application  
# + accessControl - access control for the application  
# + idpId - field description
public type Application record {|
    readonly string appId;
    string applicationName;
    string sandBoxKey;
    string productionKey;
    ApplicationProperties[] appProperties;
    string addedAPIs;
    User[] accessControl;
    string idpId;
|};

public type Organization record {|
    readonly string orgId;
    string organizationName;
    boolean isPublic; 
    string authenticatedPages;
    OrganizationAssets[] organizationAssets;
    IdentityProvider[] identityProvider;
    Subscription[] subscriptions;
    OrgImages[] orgImages;
|};


# Assets needed for the org landing page.
#
# + pageName - field description  
# + orgName - field description  
# + pageType - field description  
# + filePath - field description  
# + pageContent - field description  
# + organization - field description
public type OrganizationAssets record {|
    readonly string orgAssetId;
    string pageName;
    string orgName;
    string pageType;
    string filePath;
    string pageContent;
    Organization organization;
|};


public type ApplicationProperties record {|
    readonly string propertyId;
    string name;
    string value;
    Application application;
|};

public type User record {|
    readonly string userId;
    string role;
    string userName;
    Application application;
    Review[] reviews;
    Subscription[] subscriptions;
|};

public type Subscription record {|
    readonly string subscriptionId;
    ApiMetadata api;
    User user;
    Organization organization;
    ThrottlingPolicy subscriptionPolicy;
|};

