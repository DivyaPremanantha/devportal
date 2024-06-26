import devportal.models;
import devportal.store;

import ballerina/log;
import ballerina/persist;
import ballerina/uuid;

final store:Client dbClient = check new ();

public function getOrgId(string orgName) returns string|error {

    stream<store:Organization, persist:Error?> organizations = check dbClient->/organizations.get();

    //retrieve the organization id
    store:Organization[] organization = check from var org in organizations
        where org.organizationName == orgName
        select org;

    if (organization.length() == 0) {
        return error("Organization not found");
    }

    return organization[0].orgId;

}

public function getOrgName(string orgId) returns string|error {

    store:Organization organization = check dbClient->/organizations/[orgId];
    return organization.organizationName;

}

public function getOrgDetails(string orgName) returns store:OrganizationWithRelations|error {

    stream<store:Organization, persist:Error?> organizations = check dbClient->/organizations.get();

    //retrieve the organization id
    store:Organization[] organization = check from var org in organizations
        where org.organizationName == orgName
        select org;

    if (organization.length() == 0) {
        return error("Organization not found");
    }

    return organization[0];

}

public function getAPIId(string orgName, string apiName) returns string|error {

    string orgId = check getOrgId(orgName);
    stream<store:ApiMetadata, persist:Error?> apis = dbClient->/apimetadata.get();

    //retrieve the api id
    store:ApiMetadata[] matchedAPI = check from var api in apis
        where api.apiName == apiName && api.orgId == orgId
        select api;

    if (matchedAPI.length() == 0) {
        return error("API not found");
    }
    return matchedAPI[0].apiId;
}

public function getAPIImages(string orgName, string apiName) returns store:ApiImages[]|error {

    string apiId = check getAPIId(orgName, apiName);
    string orgId = check getOrgId(orgName);
    stream<store:ApiImages, persist:Error?> apiImages = dbClient->/apiimages.get();

    //retrieve the api id
    store:ApiImages[] images = check from var image in apiImages
        where image.apiId == apiId && image.orgId == orgId
        select image;

    if (images.length() == 0) {
        return error("API image record not found");
    }
    return images;
}

public function createOrg(models:Organization organization) returns string|error {

    string[] authenticaedPages = organization.authenticatedPages ?: [];
    string pages = string:'join(" ", ...authenticaedPages);

    store:OrganizationInsert org = {
        orgId: uuid:createType1AsString(),
        organizationName: organization.orgName,
        isPublic: organization.isPublic,
        authenticatedPages: pages
    };

    //create an organization record
    string[] orgCreationResult = check dbClient->/organizations.post([org]);

    if (orgCreationResult.length() == 0) {
        return error("Organization creation failed");
    }
    return orgCreationResult[0];
}

public function updateOrg(models:Organization organization) returns string|error {

    string orgId = check getOrgId(organization.orgName);
    string[] authenticaedPages = organization.authenticatedPages ?: [];
    string pages = string:'join(" ", ...authenticaedPages);

    store:Organization org = check dbClient->/organizations/[orgId].put({
        organizationName: organization.orgName,
        isPublic: organization.isPublic,
        authenticatedPages: pages
    });

    return org.orgId;
}

public function createOrgAssets(models:OrganizationAssets[] orgContent) returns string|error {

    store:OrganizationAssets[] orgAssets = [];
    foreach var asset in orgContent {
        store:OrganizationAssets storeAsset = {
            pageType: asset.pageType,
            pageContent: asset.pageContent,
            organizationOrgId: asset.orgId,
            orgName: asset.orgName
        };
        orgAssets.push(storeAsset);
    }

    string[][] listResult = check dbClient->/organizationassets.post(orgAssets);

    log:printInfo("Asset ID update: " + listResult[0][0]);

    if (listResult.length() == 0) {
        return error("Organization assets creation failed");
    }
    return listResult[0][0];
}

public function updateOrgAssets(models:OrganizationAssets[] orgContent) returns string|error {

    foreach var asset in orgContent {
        store:OrganizationAssets|persist:Error org = dbClient->/organizationassets/[asset.pageType]/[asset.orgName].put({
            organizationOrgId: asset.orgId,
            pageContent: asset.pageContent
        });
        if (org is error) {
            return "Error occurred while updating organization assets";
        }
    }
    return "Organization assets upated";
}

public function createAPIMetadata(models:ApiMetadata apiMetaData) returns string|error {

    string roles = "";
    if (apiMetaData.apiInfo.hasKey("authorizedRoles")) {

        string[] authenticatedRoles = apiMetaData.apiInfo.authorizedRoles ?: [];
        roles = string:'join(" ", ...authenticatedRoles);
    }

    string apiID = apiMetaData.apiInfo.apiName;
    string orgName = apiMetaData.apiInfo.orgName;
    string orgId = check getOrgId(apiMetaData.apiInfo.orgName);
    json metadata = {
        apiName: apiMetaData.apiInfo.apiName,
        apiCategory: apiMetaData.apiInfo.apiCategory,
        openApiDefinition: apiMetaData.apiInfo.openApiDefinition.toJson(),
        productionUrl: apiMetaData.serverUrl.productionUrl,
        sandboxUrl: apiMetaData.serverUrl.sandboxUrl
    };
    store:ApiMetadata metadataRecord = {
        apiId: apiID,
        orgId: orgId,
        apiName: apiMetaData.apiInfo.apiName,
        metadata: metadata.toJsonString(),
        apiCategory: apiMetaData.apiInfo.apiCategory,
        openApiDefinition: apiMetaData.apiInfo.openApiDefinition.toJsonString(),
        productionUrl: apiMetaData.serverUrl.productionUrl,
        sandboxUrl: apiMetaData.serverUrl.sandboxUrl,
        organizationName: apiMetaData.apiInfo.orgName,
        authorizedRoles: roles
    };

    string[][] listResult = check dbClient->/apimetadata.post([metadataRecord]);

    check addAdditionalProperties(apiMetaData.apiInfo.additionalProperties, apiID, orgName);
    check addThrottlingPolicy(apiMetaData.throttlingPolicies ?: [], apiID, orgName);

    if (listResult.length() == 0) {
        return error("API creation failed");
    }
    return listResult[0][0];
}

public function updateAPIMetadata(models:ApiMetadata apiMetaData, string apiID, string orgName) returns string|error {

    check addThrottlingPolicy(apiMetaData.throttlingPolicies ?: [], apiID, orgName);
    check addAdditionalProperties(apiMetaData.apiInfo.additionalProperties, apiID, orgName);
    string roles = "";
    if (apiMetaData.apiInfo.hasKey("authorizedRoles")) {

        string[] authenticatedRoles = apiMetaData.apiInfo.authorizedRoles ?: [];
        roles = string:'join(" ", ...authenticatedRoles);
    }
    string orgId = check getOrgId(apiMetaData.apiInfo.orgName);
    store:ApiMetadataUpdate metadataRecord = {
        apiName: apiMetaData.apiInfo.apiName,
        apiCategory: apiMetaData.apiInfo.apiCategory,
        openApiDefinition: apiMetaData.apiInfo.openApiDefinition.toJsonString(),
        productionUrl: apiMetaData.serverUrl.productionUrl,
        sandboxUrl: apiMetaData.serverUrl.sandboxUrl,
        authorizedRoles: roles
    };

    store:ApiMetadata listResult = check dbClient->/apimetadata/[apiID]/[orgId].put(metadataRecord);

    if (listResult.length() == 0) {
        return error("API metadata update failed");
    }
    return listResult.apiId;
}

public function addThrottlingPolicy(models:ThrottlingPolicy[] throttlingPolicies, string apiID, string orgName) returns error? {

    store:ThrottlingPolicy[] throttlingPolicyRecords = [];
    string orgId = check getOrgId(orgName);
    foreach var policy in throttlingPolicies {
        throttlingPolicyRecords.push({
            apimetadataApiId: apiID,
            policyId: uuid:createType1AsString(),
            'type: policy.'type,
            policyName: policy.policyName,
            description: policy.description,
            apimetadataOrgId: orgId
        });
    }

    if (throttlingPolicyRecords.length() != 0) {
        do {
            string[] propResults = check dbClient->/throttlingpolicies.post(throttlingPolicyRecords);
        } on fail var e {
            log:printError("Error occurred while adding throttling policies: " + e.message());
        }
    }
}

public function addAdditionalProperties(map<string> additionalProperties, string apiID, string orgName) returns error? {

    store:AdditionalPropertiesInsert[] additionalPropertiesRecords = [];
    string orgId = check getOrgId(orgName);
    foreach var propertyKey in additionalProperties.keys() {
        additionalPropertiesRecords.push({
            'key: propertyKey,
            value: <string>additionalProperties.get(propertyKey),
            apiId: apiID,
            orgId: orgId
        });
    }
    if (additionalPropertiesRecords.length() != 0) {
        do {
            string[][] propResults = check dbClient->/additionalproperties.post(additionalPropertiesRecords);
        } on fail var e {
            log:printError("Error occurred while adding additional properties: " + e.message());
        }
    }
}

public function addApiContent(models:APIAssets apiAssets, string apiID, string orgName) returns error? {

    string orgId = check getOrgId(orgName);
    store:ApiContentInsert[] apiContentRecord = [];

    apiContentRecord.push({
        apiId: apiID,
        orgId: orgId,
        apiContent: apiAssets.apiContent
    });

    if (apiContentRecord.length() != 0) {
        string[][] contentResults = check dbClient->/apicontents.post(apiContentRecord);
    }
}

public function updateApiContent(models:APIAssets apiAssets, string apiID, string orgName) returns string|error? {

    string orgId = check getOrgId(orgName);
    _ = check dbClient->/apicontents/[apiID]/[orgId].put(
        {
            apiContent: apiAssets.apiContent
        }
    );
    return "API Image upload success";
}

public function addApiImages(map<string> images, string apiID, string orgName) returns error? {

    store:ApiImagesInsert[] apiImagesRecord = [];
    string orgId = check getOrgId(orgName);
    foreach var propertyKey in images.keys() {
        apiImagesRecord.push({
            imageTag: propertyKey,
            imagePath: <string>images.get(propertyKey),
            apiId: apiID,
            orgId: orgId,
            image: []
        });
    }
    if (apiImagesRecord.length() != 0) {
        do {
            string[][] contentResults = check dbClient->/apiimages.post(apiImagesRecord);
        } on fail var e {
            log:printError("Error occurred while adding API images: " + e.message());
        }
    }
}

public function updateApiImages(models:APIImages[] imageRecords, string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    foreach var apiImage in imageRecords {
        stream<store:ApiImages, persist:Error?> apiImages = dbClient->/apiimages.get();
        store:ApiImages[] images = check from var image in apiImages
            where image.apiId == apiID && image.imagePath == apiImage.imageName && image.orgId == orgId
            select image;
        if (images.length() != 0) {
            store:ApiImages|persist:Error updatedImage = dbClient->/apiimages/[images[0].imageTag]/[apiID]/[orgId].put(
                {
                    image: apiImage.image
                }
            );
            if updatedImage is error {
                return "Error occurred while updating API images";
            }
        }
    }
    return "API Image upload success";
}

public function updateApiImagePath(map<string> images, string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    foreach var propertyKey in images.keys() {

        store:ApiImages|persist:Error apiImages = dbClient->/apiimages/[propertyKey]/[apiID]/[orgId].put(
            {
                imagePath: <string>images.get(propertyKey)
            }
        );
        if apiImages is error {
            return "Error occurred while updating API images";
        }
    }
    return "API Image upload success";
}

public function storeOrgImages(models:OrgImages[] orgImages, string orgId) returns string|error {

    store:OrgImagesInsert[] orgImageRecords = [];
    foreach var image in orgImages {
        orgImageRecords.push({
            fileName: image.imageName,
            image: image.image,
            orgId: orgId
        });
    }
    string[][] listResult = check dbClient->/orgimages.post(orgImageRecords);
    log:printInfo("Organization images stored");

    if (listResult.length() == 0) {
        return error("Organization image creation failed");
    }
    return listResult[0][0];
}

public function updateOrgImages(models:OrgImages[] orgImages, string orgId) returns string|error {

    foreach var image in orgImages {
        store:OrgImages|persist:Error org = dbClient->/orgimages/[orgId]/[image.imageName].put({
            image: image.image
        });
        if (org is error) {
            return "Error occurred while updating organization images";
        }
    }
    return "Organization images updated";
}

public function retrieveAPIImages(string imagePath, string apiID, string orgName) returns byte[]|error {

    string orgId = check getOrgId(orgName);
    stream<store:ApiImages, persist:Error?> apiImages = dbClient->/apiimages.get();
    string filePath = "/resources/images/" + imagePath;
    store:ApiImages[] images = check from var image in apiImages
        where image.apiId == apiID && image.imagePath == filePath && image.orgId == orgId
        select image;
    if (images.length() !== 0) {
        log:printInfo("Image retrieved");
        return images[0].image;
    }
    return [];
}

public function retrieveAPIContent(string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    stream<store:ApiContent, persist:Error?> apiContent = dbClient->/apicontents.get();
    store:ApiContent[] contents = check from var content in apiContent
        where content.apiId == apiID && content.orgId == orgId
        select content;
    if (contents.length() !== 0) {
        return contents[0].apiContent;
    } else {
        return "API content not found";
    }
}

public function deleteAPI(string apiID, string orgName) returns string|error? {

    // store:ApiMetadata apiImages = check dbClient->/additionalproperties/["path"].delete;

    store:ApiMetadata apiImages = check dbClient->/apimetadata/[apiID]/[orgName].delete();

    return "API deleted successfully";

}

public function retrieveOrgFiles(string fileName, string orgName) returns string|error? {

    string orgId = check getOrgId(orgName);
    stream<store:OrganizationAssets, persist:Error?> orgContent = dbClient->/organizationassets.get();
    store:OrganizationAssets[] contents = check from var content in orgContent
        where content.organizationOrgId == orgId && content.pageType == fileName
        select content;
    if (contents.length() == 0) {
        return "File not found";
    } else {
        return contents[0].pageContent;
    }
}

public function retrieveOrgImages(string fileName, string orgId) returns byte[]|string|error? {

    stream<store:OrgImages, persist:Error?> orgContent = dbClient->/orgimages.get();
    store:OrgImages[] orgImages = check from var content in orgContent
        where content.orgId == orgId && content.fileName == fileName
        select content;
    if (orgImages.length() == 0) {
        return "File not found";
    } else {
        return orgImages[0].image;
    }
}

public function addIdentityProvider(models:IdentityProvider identityProvider) returns string|error {

    string orgId = check getOrgId(identityProvider.orgName);
    store:IdentityProviderInsert idp = {
        organizationOrgId: orgId,
        idpID: uuid:createType1AsString(),
        name: identityProvider.name,
        issuer: identityProvider.issuer,
        clientId: identityProvider.clientId,
        clientSecret: identityProvider.clientSecret,
        id: identityProvider.id,
        'type: identityProvider.'type
    };
    string[] listResult = check dbClient->/identityproviders.post([idp]);
    return listResult[0];
}

public function getIdentityProviders(string orgName) returns store:IdentityProviderWithRelations[]|error {

    string orgId = check getOrgId(orgName);

    stream<store:IdentityProviderWithRelations, persist:Error?> identityProviders = dbClient->/identityproviders.get();
    store:IdentityProviderWithRelations[] idpList = check from var idp in identityProviders
        where idp.organizationOrgId == orgId
        select idp;
    return idpList;
}
