import devportal.models;
import devportal.store;
import devportal.utils;

import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/regex;

import ballerinacentral/zip;

// # A service representing a network-accessible API
// # bound to port `8080`.

final store:Client adminClient = check new ();

type Origins record {|
    string[] allowedOrigins;
|};

configurable Origins origins = ?;
configurable string storage = ?;
configurable string adminURL = ?;

service /admin on new http:Listener(8080) {

    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function post organisation(models:Organization organization) returns models:OrgCreationResponse|error {

        string orgId = check utils:createOrg(organization);
        models:OrgCreationResponse org = {
            orgName: organization.orgName,
            orgId: orgId,
            isPublic: organization.isPublic,
            authenticatedPages: organization.authenticatedPages ?: []
        };
        return org;
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function put organisation(models:Organization organization) returns models:OrgCreationResponse|error {

        string orgId = check utils:updateOrg(organization);
        models:OrgCreationResponse org = {
            orgName: organization.orgName,
            orgId: orgId,
            isPublic: organization.isPublic,
            authenticatedPages: organization.authenticatedPages ?: []
        };
        return org;
    }

    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function get organisation(string orgName) returns models:OrgCreationResponse|error {

        store:OrganizationWithRelations organization = check utils:getOrgDetails(orgName);

        models:OrgCreationResponse org = {
            orgName: organization.organizationName ?: "",
            orgId: organization.orgId ?: "",
            isPublic: organization.isPublic ?: false,
            authenticatedPages: regex:split(organization.authenticatedPages ?: "", " ")
        };
        return org;
    }

    # Description.
    #
    # + orgName - parameter description
    # + return - return value description
    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function post orgContent(http:Request request, string orgName) returns string|error {

        string orgId = check utils:getOrgId(orgName);

        byte[] binaryPayload = check request.getBinaryPayload();

        string tmpDir = check file:createTempDir();

        string path = tmpDir + "/tmp";
        string targetPath = tmpDir + "/" + orgName;

        check io:fileWriteBytes(path, binaryPayload);

        error? result = check zip:extract(path, targetPath);

        //types- template/layout/markdown/partial

        file:MetaData[] imageDir = check file:readDir(targetPath + "/images");

        file:MetaData[] stylesheetDir = [];
        models:OrganizationAssets[] assetMappings = [];

        if (storage.equalsIgnoreCaseAscii("DB")) {
            models:OrgImages[] orgImages = [];

            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.lastIndexOf("/") + 1), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii(".DS_Store")) {
                    orgImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName
                    });
                }
            }
            check file:remove(targetPath + "/images", file:RECURSIVE);
            file:MetaData[] dirContent = check file:readDir(targetPath);

            _ = check utils:getAssetmapping(dirContent, assetMappings, orgId, orgName, adminURL);

            string _ = check utils:createOrgAssets(assetMappings);
            string _ = check utils:storeOrgImages(orgImages, orgId);
        } else {
            check utils:pushContentS3(imageDir, "text/plain");
            check utils:pushContentS3(stylesheetDir, "text/css");
            log:printInfo("Added content to S3 successfully");
        }

        check file:remove(targetPath, file:RECURSIVE);
        io:println("Organization content uploaded");
        return "Organization content uploaded successfully";
    }

    # Store the organization landing page content.
    #
    # + request - parameter description  
    # + orgName - parameter description
    # + return - return value description
    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function put orgContent(http:Request request, string orgName) returns string|error {

        string orgId = check utils:getOrgId(orgName);
        byte[] binaryPayload = check request.getBinaryPayload();
        string tmpDir = check file:createTempDir();
        string path = tmpDir + "/tmp";
        string targetPath = tmpDir + "/" + orgName;

        check io:fileWriteBytes(path, binaryPayload);

        error? result = check zip:extract(path, targetPath);

        //types- template/layout/markdown/partial

        file:MetaData[] imageDir = check file:readDir(targetPath + "/images");

        file:MetaData[] stylesheetDir = [];
        models:OrganizationAssets[] assetMappings = [];

        if (storage.equalsIgnoreCaseAscii("DB")) {
            models:OrgImages[] orgImages = [];

            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.lastIndexOf("/") + 1), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii(".DS_Store")) {
                    orgImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName
                    });
                }
            }
            check file:remove(targetPath + "/images", file:RECURSIVE);
            file:MetaData[] dirContent = check file:readDir(targetPath);

            _ = check utils:getAssetmapping(dirContent, assetMappings, orgId, orgName, adminURL);

            string _ = check utils:updateOrgAssets(assetMappings);
            string _ = check utils:updateOrgImages(orgImages, orgId);
        } else {
            check utils:pushContentS3(imageDir, "text/plain");
            check utils:pushContentS3(stylesheetDir, "text/css");
            log:printInfo("Added content to S3 successfully");
        }

        check file:remove(targetPath, file:RECURSIVE);
        io:println("Organization content uploaded");
        return "Organization content uploaded successfully";

    }

    resource function post additionalAPIContent(http:Request request, string orgName, string apiName) returns string|error {

        string apiId = check utils:getAPIId(orgName, apiName);

        byte[] binaryPayload = check request.getBinaryPayload();

        string tmpDir = check file:createTempDir();
        string path = tmpDir + "/tmp";
        string targetPath = tmpDir + "/" + orgName;
        check io:fileWriteBytes(path, binaryPayload);
        error? result = check zip:extract(path, targetPath);

        file:MetaData[] directories = check file:readDir(targetPath + "/" + apiName + "/content");

        models:APIAssets[] apiAssets = [];
        apiAssets = check utils:readAPIContent(directories, orgName, apiId, apiAssets);

        boolean dirExists = check file:test(targetPath + "/" + apiName + "/images", file:EXISTS);

        if (dirExists) {
            file:MetaData[] imageDir = check file:readDir(targetPath + "/" + apiName + "/images");

            models:APIImages[] apiImages = [];
            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = regex:split(imageName, "/images/")[1];
                if (!imageName.equalsIgnoreCaseAscii("/images/.DS_Store")) {
                    string relativePath = check file:relativePath(file:getCurrentDir(), file.absPath);
                    apiImages.push({
                        image: check io:fileReadBytes(relativePath),
                        imageName: imageName,
                        imageTag: ""
                    }
                    );
                }
            }
            if (storage.equalsIgnoreCaseAscii("DB")) {
                _ = check utils:updateApiImages(apiImages, apiId, orgName);
            } else {
                check utils:pushContentS3(imageDir, "text/plain");
            }
        }

        check file:remove(targetPath, file:RECURSIVE);
        string|error apiContent = utils:addApiContent(apiAssets, apiId, orgName);

        if apiContent is error {
            return "Asset update failed";
        }
        io:println("API content added successfully");
        return "API asset updated";
    }

    # Retrieve landing pages.
    #
    # + fileName - parameter description  
    # + orgName - parameter description  
    # + request - parameter description
    # + return - return value description
    @http:ResourceConfig {
        cors: {
            allowOrigins: origins.allowedOrigins
        }
    }
    resource function get orgFiles(string orgName, string fileName, http:Request request) returns error|http:Response {

        string orgId = check utils:getOrgId(orgName);
        mime:Entity file = new;
        http:Response response = new;
        if (fileName.endsWith("html") || fileName.endsWith("css") || fileName.endsWith("hbs") || fileName.endsWith("md")) {
            string|error? fileContent = utils:retrieveOrgFiles(fileName, orgName);
            if (!(fileContent is error)) {
                file.setBody(fileContent);
                response.setEntity(file);
                check response.setContentType("application/octet-stream");
                response.setHeader("Content-Type", "text/css");
                response.setHeader("Content-Description", "File Transfer");
                response.setHeader("Transfer-Encoding", "chunked");
            } else {
                response.statusCode = 404;
                response.setPayload("Requested file not found");
            }
        } else {
            byte[]|string|error? orgImage = utils:retrieveOrgImages(fileName, orgId);
            if orgImage is byte[] {
                if (fileName.endsWith(".svg")) {
                    string imageContent = check string:fromBytes(orgImage);
                    file.setBody(imageContent);
                    response.setEntity(file);
                    response.setHeader("Content-Type", "image/svg+xml");
                } else {
                    file.setBody(orgImage);
                    response.setEntity(file);
                    response.setHeader("Content-Type", "application/octet-stream");
                }
            } else {
                response.statusCode = 404;
                response.setPayload("Requested file not found");
            }
        }
        return response;
    }

    resource function get orgFileType(string orgName, string fileType, string? filePath, string? fileName, http:Request request) returns
    store:OrganizationAssets[]|error|http:Response {

        var params = request.getQueryParams();
        store:OrganizationAssets[] fileContent = [];
        if (params.hasKey("fileName")) {
            if (fileType.equalsIgnoreCaseAscii("template") || fileType.equalsIgnoreCaseAscii("layout")) {
                mime:Entity file = new;
                http:Response response = new;
                string templateFile = check utils:retrieveOrgTemplateFile(filePath ?: "", orgName, fileName ?: "") ?: "";
                file.setBody(templateFile);
                response.setEntity(file);
                check response.setContentType("application/octet-stream");
                response.setHeader("Content-Type", "text/css");
                response.setHeader("Content-Description", "File Transfer");
                response.setHeader("Transfer-Encoding", "chunked");
                return response;
            }
        } else if (params.hasKey("filePath")) {
            fileContent = check utils:retrieveOrgFilesFromPath(fileType, orgName, filePath ?: "") ?: [];
        } else {
            fileContent = check utils:retrieveOrgFileType(fileType, orgName) ?: [];
        }
        return fileContent;
    }

    # Store the identity provider details for the developer portal.
    #
    # + identityProvider - IDP details
    # + return - return value description
    resource function post identityProvider(string orgName, @http:Payload models:IdentityProvider identityProvider) returns models:IdentityProviderResponse|error {

        log:printInfo("Adding identity provider");
        string identityProviderResult = check utils:addIdentityProvider(identityProvider, orgName);

        log:printInfo(identityProviderResult);

        models:IdentityProviderResponse createdIDP = {
            id: identityProviderResult,
            orgName: orgName,
            issuer: identityProvider.issuer,
            authorizationURL: identityProvider.authorizationURL,
            tokenURL: identityProvider.tokenURL,
            userInfoURL: identityProvider.userInfoURL,
            clientId: identityProvider.clientId,
            callbackURL: identityProvider.callbackURL,
            scope: identityProvider.scope,
            signUpURL: identityProvider.signUpURL,
            logoutURL: identityProvider.logoutURL,
            logoutRedirectURI: identityProvider.logoutRedirectURI
        };
        return createdIDP;
    }

    # Retrieve identity providers.
    #
    # + orgName - parameter description
    # + return - list of identity providers for the organization.
    resource function get identityProvider(string orgName) returns models:IdentityProviderResponse[]|error {

        store:IdentityProviderWithRelations[] idpList = check utils:getIdentityProviders(orgName);
        models:IdentityProviderResponse[] idps = [];
        foreach var idp in idpList {
            models:IdentityProviderResponse identityProvider = {
                id: idp.idpId ?: "",
                orgName: idp.orgName ?: "",
                issuer: idp.issuer ?: "",
                authorizationURL: idp.authorizationURL ?: "",
                tokenURL: idp.tokenURL ?: "",
                userInfoURL: idp.userInfoURL ?: "",
                clientId: idp.clientId ?: "",
                callbackURL: idp.callbackURL ?: "",
                scope: idp.scope ?: "",
                signUpURL: idp.signUpURL ?: "",
                logoutURL: idp.logoutURL ?: "",
                logoutRedirectURI: idp.logoutRedirectURI ?: ""
            };
            idps.push(identityProvider);

        }
        return idps;
    }

    resource function post organisations/[string orgId]/subscriptionPlans(@http:Payload models:SubscriptionPlan subscriptionPlan) returns models:SubscriptionPlanResponse|error {

        log:printInfo(orgId);
        
        string planId = check utils:addSubscriptionPlan(subscriptionPlan, orgId);
        models:SubscriptionPlanResponse plan = {
            subscriptionPlanID: planId,
            policyName: subscriptionPlan.policyName,
            displayName: subscriptionPlan.displayName,
            description: subscriptionPlan.description,
            amount: subscriptionPlan.amount
        };

        return plan;
    }

}

