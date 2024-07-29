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
    string fileName;
    string pageName;
    string pageContent;
    string orgId;
    string orgName;
|};

public type Organization record {

    string orgName;
    boolean isPublic;
    PAGES[] authenticatedPages?;
};

public enum PAGES {
    ORGLANDING,
    APILANDING,
    APITRYOUT,
    APPLICATION,
    APILISTING,
    MONETIZATION,
    FORUMS
}

# Assets needed for the api landing page.
#
# + apiImages - field description  
# + apiContent - field description  
# + apiId - field description
public type APIAssets record {|
    string[] apiImages;
    string apiContent;
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
# + orgName - field description  
# + id - field description  
# + name - field description  
# + 'type - field description  
# + issuer - field description  
# + clientId - field description  
# + clientSecret - field description
public type IdentityProvider record {
    string orgName;
    string id;
    string name;
    string 'type; 
    string issuer;
    string clientId;
    string clientSecret;
};



# Response for IdentityProvider creaton.
#
# + id - field description  
# + name - field description  
# + 'type - field description  
# + issuer - field description  
# + clientId - field description  
# + clientSecret - field description
public type IdentityProviderResponse record {
     string id;
    string name;
    string 'type; 
    string issuer;
    string clientId;
    string clientSecret;
};





