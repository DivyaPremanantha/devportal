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
            orgAssetId: uuid:createType1AsString(),
            pageType: asset.pageType,
            pageContent: asset.pageContent,
            organizationOrgId: asset.orgId,
            orgName: asset.orgName,
            pageName: asset.pageName,
            filePath: asset.dirName
        };
        orgAssets.push(storeAsset);
    }

    string[] listResult = check dbClient->/organizationassets.post(orgAssets);

    log:printInfo("Asset ID update: " + listResult[0][0]);

    if (listResult.length() == 0) {
        return error("Organization assets creation failed");
    }
    return listResult[0][0];
}

public function updateOrgAssets(models:OrganizationAssets[] orgContent) returns string|error {

    foreach var asset in orgContent {
        stream<store:OrganizationAssets, persist:Error?> storedOrgAssets = dbClient->/organizationassets.get();
        store:OrganizationAssets[] existingAsset = check from var storedAsset in storedOrgAssets
            where storedAsset.pageType == asset.pageType && storedAsset.filePath == asset.dirName && storedAsset.pageName == asset.pageName
            && storedAsset.orgName == asset.orgName
            select storedAsset;
        if (existingAsset.length() != 0) {
            do {
                store:OrganizationAssets org = check dbClient->/organizationassets/[existingAsset[0].orgAssetId].put({
                    organizationOrgId: asset.orgId,
                    pageContent: asset.pageContent
                });
            } on fail var e {
                log:printError("Error while updating org assets: " + e.message());
                return ("Error while updating org assets" + e.message());
            }
        } else {
            store:OrganizationAssetsInsert[] orgAssetRecord = [];
            orgAssetRecord.push({
                organizationOrgId: asset.orgId,
                pageType: asset.pageType,
                orgName: asset.orgName,
                pageContent: asset.pageContent,
                pageName: asset.pageName,
                filePath: asset.dirName,
                orgAssetId: uuid:createType1AsString()
            });
            do {
                string[] listResult = check dbClient->/organizationassets.post(orgAssetRecord);
            } on fail var e {
                log:printError("Error occurred while adding organization assets: " + e.message());
                return ("Error while adding org assets" + e.message());
            }

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
        openApiDefinition: apiMetaData.apiInfo.apiDefinition.toJson(),
        productionUrl: apiMetaData.serverUrl.productionUrl,
        sandboxUrl: apiMetaData.serverUrl.sandboxUrl
    };
    store:ApiMetadata metadataRecord = {
        apiId: apiID,
        orgId: orgId,
        apiName: apiMetaData.apiInfo.apiName,
        metadata: metadata.toJsonString(),
        apiCategory: apiMetaData.apiInfo.apiCategory,
        productionUrl: apiMetaData.serverUrl.productionUrl,
        sandboxUrl: apiMetaData.serverUrl.sandboxUrl,
        organizationName: apiMetaData.apiInfo.orgName,
        authorizedRoles: roles,
        tags: apiMetaData.apiInfo.tags,
        apiVersion: apiMetaData.apiInfo.apiVersion,
        apiDescription: apiMetaData.apiInfo.apiDescription,
        apiDefinition: apiMetaData.apiInfo.apiDefinition ?: "",
        apiType: apiMetaData.apiInfo.apiType
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
        apiDefinition: apiMetaData.apiInfo.apiDefinition,
        apiDescription: apiMetaData.apiInfo.apiDescription,
        apiVersion: apiMetaData.apiInfo.apiVersion,
        apiType: apiMetaData.apiInfo.apiType,
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
            'type: policy.'category ?: "",
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

public function addApiContent(models:APIAssets[] apiAssets, string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    store:ApiContentInsert[] apiContentRecord = [];
    foreach var item in apiAssets {
        apiContentRecord.push({
            apiContent: item.apiContent,
            apiContentId: uuid:createType1AsString(),
            fileName: item.fileName,
            apimetadataApiId: apiID,
            apimetadataOrgId: orgId
        });
    }
    if (apiContentRecord.length() != 0) {
        do {
            string[] listResult = check dbClient->/apicontents.post(apiContentRecord);
        } on fail var e {
            log:printError("Error occurred while adding api content: " + e.message());
            return "API content creation failed";
        }
    }
    return "Content updated";
}

public function updateApiContent(models:APIAssets[] apiAssets, string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);

    foreach var item in apiAssets {
        stream<store:ApiContent, persist:Error?> apiContent = dbClient->/apicontents.get();
        store:ApiContent[] contents = check from var content in apiContent
            where content.apimetadataApiId == apiID && content.apimetadataOrgId == orgId && content.fileName == item.fileName
            select content;
        if (contents.length() !== 0) {
            do {
                store:ApiContent|persist:Error unionResult = dbClient->/apicontents/[contents[0].apiContentId].put(
                    {
                        apiContent: item.apiContent
                    }
                );
            } on fail var e {
                log:printError("Error while updating API content: " + e.message());
                return ("Error while updating org assets" + e.message());
            }
        }
    }
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
            do {
                store:ApiImages updatedImage = check dbClient->/apiimages/[images[0].imageTag]/[apiID]/[orgId].put(
                    {
                        image: apiImage.image
                    }
                );

            } on fail var e {
                log:printError("Error occurred while updating API images: " + e.message());
                return "Error occurred while updating API images";
            }

        }
    }
    return "API Image upload success";
}

public function updateApiImagePath(map<string> images, string apiID, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    foreach var propertyKey in images.keys() {
        stream<store:ApiImages, persist:Error?> storedImages = dbClient->/apiimages.get();
        store:ApiImages[] retriedImage = check from var apiImage in storedImages
            where apiImage.orgId == orgId && apiImage.imageTag == propertyKey
            select apiImage;
        if (retriedImage.length() != 0) {
            store:ApiImages|persist:Error apiImages = dbClient->/apiimages/[propertyKey]/[apiID]/[orgId].put(
                {
                    imagePath: <string>images.get(propertyKey)
                }
            );
            if apiImages is error {
                return "Error occurred while updating API images";
            }
        } else {
            // if no recorod for api image
            store:ApiImagesInsert[] apiImagesRecord = [];
            apiImagesRecord.push({
                imageTag: propertyKey,
                imagePath: <string>images.get(propertyKey),
                apiId: apiID,
                orgId: orgId,
                image: []
            });

            if (apiImagesRecord.length() != 0) {
                do {
                    string[][] contentResults = check dbClient->/apiimages.post(apiImagesRecord);
                } on fail var e {
                    log:printError("Error occurred while adding API images: " + e.message());
                }
            }
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
        stream<store:OrgImages, persist:Error?> storedImages = dbClient->/orgimages.get();
        store:OrgImages[] images = check from var orgImage in storedImages
            where orgImage.orgId == orgId && orgImage.fileName == image.imageName
            select orgImage;
        if (images.length() != 0) {
            store:OrgImages|persist:Error org = dbClient->/orgimages/[orgId]/[image.imageName].put({
                image: image.image
            });
            if (org is error) {
                return "Error occurred while updating organization images";
            }
        } else {
            store:OrgImagesInsert[] orgImageRecords = [];
            orgImageRecords.push({
                fileName: image.imageName,
                image: image.image,
                orgId: orgId
            });
            string[][] listResult = check dbClient->/orgimages.post(orgImageRecords);

        }

    }
    return "Organization images updated";
}

public function retrieveAPIImages(string imagePath, string apiID, string orgName) returns byte[]|error {

    string orgId = check getOrgId(orgName);
    stream<store:ApiImages, persist:Error?> apiImages = dbClient->/apiimages.get();
    string filePath = imagePath;
    store:ApiImages[] images = check from var image in apiImages
        where image.apiId == apiID && image.imagePath == filePath && image.orgId == orgId
        select image;
    if (images.length() !== 0) {
        log:printInfo("Image retrieved");
        return images[0].image;
    }
    return [];
}

public function retrieveAPIContent(string apiID, string orgName, string fileName) returns string|error {

    string orgId = check getOrgId(orgName);
    stream<store:ApiContent, persist:Error?> apiContent = dbClient->/apicontents.get();
    store:ApiContent[] contents = check from var content in apiContent
        where content.apimetadataApiId == apiID && content.apimetadataOrgId == orgId && content.fileName == fileName
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

public function retrieveOrgFiles(string fileName, string orgName) returns string|error {

    string orgId = check getOrgId(orgName);
    stream<store:OrganizationAssets, persist:Error?> orgContent = dbClient->/organizationassets.get();
    store:OrganizationAssets[] contents = check from var content in orgContent
        where content.organizationOrgId == orgId && content.pageName == fileName
        select content;
    if (contents.length() == 0) {
        return "File not found";
    } else {
        return contents[0].pageContent;
    }
}

public function retrieveOrgFileType(string fileType, string orgName) returns store:OrganizationAssets[]|error? {

    string orgId = check getOrgId(orgName);
    stream<store:OrganizationAssets, persist:Error?> orgContent = dbClient->/organizationassets.get();
    store:OrganizationAssets[] contents = [];
    contents = check from var content in orgContent
        where content.organizationOrgId == orgId && content.pageType == fileType
        select content;
    if (contents.length() == 0) {
        return contents;
    } else {
        return contents;
    }
}

public function retrieveOrgFilesFromPath(string fileType, string orgName, string filePath) returns store:OrganizationAssets[]|error? {

    string orgId = check getOrgId(orgName);
    stream<store:OrganizationAssets, persist:Error?> orgContent = dbClient->/organizationassets.get();
    store:OrganizationAssets[] contents = [];
    contents = check from var content in orgContent
        where content.organizationOrgId == orgId && content.pageType == fileType && content.filePath == filePath
        select content;
    if (contents.length() == 0) {
        log:printInfo("not found");
        return contents;
    } else {
        return contents;
    }
}

public function retrieveOrgTemplateFile(string filePath, string orgName, string fileName) returns string|error? {

    string orgId = check getOrgId(orgName);
    stream<store:OrganizationAssets, persist:Error?> orgContent = dbClient->/organizationassets.get();
    store:OrganizationAssets[] contents = [];
    contents = check from var content in orgContent
        where content.organizationOrgId == orgId && content.filePath == filePath && content.pageName == fileName
        select content;
    if (contents.length() != 0) {
        return contents[0].pageContent;
    } else {
        return "File not found";
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

public function addIdentityProvider(models:IdentityProvider identityProvider, string orgName) returns string|error {

    log:printInfo(identityProvider.toString());
    string orgId = check getOrgId(orgName);
    store:IdentityProviderInsert idp = {
        idpId: uuid:createType1AsString(),
        organizationOrgId: orgId,
        orgName: orgName,
        issuer: identityProvider.issuer,
        authorizationURL: identityProvider.authorizationURL,
        tokenURL: identityProvider.tokenURL,
        userInfoURL: identityProvider.userInfoURL,
        callbackURL: identityProvider.callbackURL,
        scope: identityProvider.scope,
        signUpURL: identityProvider.signUpURL,
        clientId: identityProvider.clientId,
        logoutRedirectURI: identityProvider.logoutRedirectURI,
        logoutURL: identityProvider.logoutURL
    };
    log:printInfo(idp.toString());
    string[] listResult = check dbClient->/identityproviders.post([idp]);
    return idp.idpId;
}

public function getIdentityProviders(string orgName) returns store:IdentityProviderWithRelations[]|error {

    string orgId = check getOrgId(orgName);

    stream<store:IdentityProviderWithRelations, persist:Error?> identityProviders = dbClient->/identityproviders.get();
    store:IdentityProviderWithRelations[] idpList = check from var idp in identityProviders
        where idp.organizationOrgId == orgId
        select idp;
    return idpList;
}

public function addSubscriptionPlan(models:SubscriptionPlan subscriptionPlan, string orgId) returns string|error {

    store:SubscriptionPlanInsert plan = {
        subscriptionPlanID: uuid:createType1AsString(),
        policyName: subscriptionPlan.policyName,
        displayName: subscriptionPlan.displayName,
        description: subscriptionPlan.description,
        orgId: orgId
    };
    log:printInfo("Adding identity provider");
    log:printInfo( plan.toString());

    [string, string][] listResult = check dbClient->/subscriptionplans.post([plan]);
    return plan.subscriptionPlanID;
}
