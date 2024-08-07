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
        string path = "./zip";
        string targetPath = "./" + orgName;
        check io:fileWriteBytes(path, binaryPayload);

        error? result = check zip:extract(path, targetPath);

        //types- template/layout/markdown/partial

        file:MetaData[] layoutDir = check file:readDir("./" + orgName + "/views/layouts");
        file:MetaData[] partialDir = check file:readDir("./" + orgName + "/views/partials");

        file:MetaData[] imageDir = check file:readDir("./" + orgName + "/images");
        file:MetaData[] stylesheetDir = check file:readDir("./" + orgName + "/styles");

        models:OrganizationAssets[] assetMappings = [];

        _ = check utils:getAssetmapping(layoutDir, assetMappings, "layout", orgId, orgName);
        _ = check utils:getAssetmapping(partialDir, assetMappings, "partials", orgId, orgName);
        check file:remove(orgName + "/views/layouts", file:RECURSIVE);
        check file:remove(orgName + "/views/partials", file:RECURSIVE);
        file:MetaData[] templateDir = check file:readDir("./" + orgName + "/views");

        _ = check utils:getAssetmapping(templateDir, assetMappings, "template", orgId, orgName);
        _ = check utils:getAssetmapping(stylesheetDir, assetMappings, "styles", orgId, orgName);

        string _ = check utils:createOrgAssets(assetMappings);

        if (storage.equalsIgnoreCaseAscii("DB")) {
            models:OrgImages[] orgImages = [];
            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.lastIndexOf("/") + 1), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii(".DS_Store")) {
                    orgImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName
                    }
                    );
                }
            }
            string _ = check utils:storeOrgImages(orgImages, orgId);
        } else {
            check utils:pushContentS3(imageDir, "text/plain");
            check utils:pushContentS3(stylesheetDir, "text/css");
            log:printInfo("Added content to S3 successfully");
        }
        check file:remove(orgName, file:RECURSIVE);
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
        string path = "./zip";
        string targetPath = "./" + orgName;
        check io:fileWriteBytes(path, binaryPayload);

        error? result = check zip:extract(path, targetPath);

        file:MetaData[] templateDir = check file:readDir("./" + orgName + "/resources/template");
        file:MetaData[] imageDir = check file:readDir("./" + orgName + "/resources/images");
        file:MetaData[] stylesheetDir = check file:readDir("./" + orgName + "/resources/stylesheet");

        file:MetaData[] content = [];
        content.push(...templateDir);
        content.push(...stylesheetDir);
        models:OrganizationAssets[] assetMappings = [];
        foreach var file in content {
            string pageType = file.absPath.substring(<int>(file.absPath.lastIndexOf("/") + 1), file.absPath.length());
            string fileName = file.absPath.substring(<int>(file.absPath.indexOf("/")), file.absPath.length());
            io:println(fileName);

            if (!pageType.equalsIgnoreCaseAscii(".DS_Store")) {

                string pageContent = check io:fileReadString(file.absPath);
                models:OrganizationAssets assetMapping = {
                    pageType: pageType,
                    pageContent: pageContent,
                    orgId: orgId,
                    orgName: orgName,
                    pageName: pageType,
                    fileName: fileName
                };
                assetMappings.push(assetMapping);
            }
        }
        string _ = check utils:updateOrgAssets(assetMappings);

        if (storage.equalsIgnoreCaseAscii("DB")) {
            models:OrgImages[] orgImages = [];
            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.lastIndexOf("/") + 1), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii(".DS_Store")) {
                    orgImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName
                    }
                    );
                }
            }
            string _ = check utils:updateOrgImages(orgImages, orgId);
        } else {
            check utils:pushContentS3(imageDir, "text/plain");
            check utils:pushContentS3(stylesheetDir, "text/css");
            log:printInfo("Added content to S3 successfully");
        }
        check file:remove(orgName, file:RECURSIVE);
        io:println("Organization content uploaded");
        return "Organization content uploaded successfully";
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
            byte[]|string|error? retrieveOrgImage = utils:retrieveOrgImages(fileName, orgId);
            if retrieveOrgImage is byte[] {
                file.setBody(retrieveOrgImage);
                response.setEntity(file);
                check response.setContentType("application/octet-stream");
                response.setHeader("Content-Type", "application/octet-stream");
                response.setHeader("Content-Description", "File Transfer");
                response.setHeader("Transfer-Encoding", "chunked");
            } else {
                response.statusCode = 404;
                response.setPayload("Requested file not found");
            }
        }
        return response;
    }

    resource function get orgFileType(string orgName, string fileType, string? filePath, http:Request request) returns
    store:OrganizationAssets[]|error|http:Response {

        store:OrganizationAssets[] fileContent = check utils:retrieveOrgFileType(fileType, orgName) ?: [];

        if (fileType.equalsIgnoreCaseAscii("template")) {
            mime:Entity file = new;
            http:Response response = new;
            string templateFile = check utils:retrieveOrgTemplateFile(filePath ?: "", orgName) ?: "";
            file.setBody(templateFile);
            response.setEntity(file);
            check response.setContentType("application/octet-stream");
            response.setHeader("Content-Type", "text/css");
            response.setHeader("Content-Description", "File Transfer");
            response.setHeader("Transfer-Encoding", "chunked");
            return response;

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
            signUpURL: identityProvider.signUpURL
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
                signUpURL: idp.signUpURL ?: ""
            };
            idps.push(identityProvider);

        }
        return idps;
    }
}

