import devportal.models;
import devportal.store;
import devportal.utils;

import ballerina/data.jsondata;
import ballerina/file;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/persist;
import ballerina/regex;

import ballerinacentral/zip;

service /apiMetadata on new http:Listener(9090) {

    # Create an API.
    #
    # + return - api Id
    resource function post api(http:Request request) returns http:Response|error {

        var bodyParts = check request.getBodyParts();
        models:ApiMetadata metadata = {
            serverUrl:
            {sandboxUrl: "", productionUrl: ""},
            apiInfo: {
                orgName: "",
                apiName: "",
                apiCategory: "",
                tags: "",
                apiDescription: "",
                apiVersion: "",
                apiType: "",
                additionalProperties: {},
                apiArtifacts: {apiImages: {}}
            }
        };
        foreach var part in bodyParts {
            var mediaType = mime:getMediaType(part.getContentType());
            if mediaType is mime:MediaType {
                string baseType = mediaType.getBaseType();
                if mime:APPLICATION_JSON == baseType {
                    var body = part.getJson();
                    if body is json {
                        string extractPayload = body.toJsonString();
                        metadata = check jsondata:parseString(extractPayload);
                        log:printInfo(body.toJsonString());
                    } else {
                        log:printError(body.message());
                    }
                } else if mime:APPLICATION_OCTET_STREAM == baseType {
                    var body = part.getByteArray();
                    if body is byte[] {
                        string apiDefinition = check string:fromBytes(body);
                        metadata.apiInfo.apiDefinition = apiDefinition;
                    } else {
                        log:printError(body.message());
                    }
                }
            }
        }
        string apiId = check utils:createAPIMetadata(metadata);
        error? apiImages = utils:addApiImages(metadata.apiInfo.apiArtifacts.apiImages, apiId, metadata.apiInfo.orgName);
        if apiImages is error {

        }
        http:Response response = new;
        response.setPayload({apiId: apiId});
        return response;
    }

    resource function delete api(string apiID, string orgName) returns string|error? {

        return utils:deleteAPI(apiID, orgName);
    }

    resource function put api(string apiID, string orgName, http:Request request) returns http:Response|error {

        var bodyParts = check request.getBodyParts();
        models:ApiMetadata metadata = {
            serverUrl:
            {sandboxUrl: "", productionUrl: ""},
            apiInfo: {
                orgName: "",
                apiName: "",
                apiCategory: "",
                tags: "",
                apiDescription: "",
                apiVersion: "",
                apiType: "",
                additionalProperties: {},
                apiArtifacts: {apiImages: {}}
            }
        };
        foreach var part in bodyParts {
            var mediaType = mime:getMediaType(part.getContentType());
            if mediaType is mime:MediaType {
                string baseType = mediaType.getBaseType();
                if mime:APPLICATION_JSON == baseType {
                    var body = part.getJson();
                    if body is json {
                        string extractPayload = body.toJsonString();
                        metadata = check jsondata:parseString(extractPayload);
                        log:printInfo(body.toJsonString());
                    } else {
                        log:printError(body.message());
                    }
                } else if mime:APPLICATION_OCTET_STREAM == baseType {
                    var body = part.getByteArray();
                    if body is byte[] {
                        string apiDefinition = check string:fromBytes(body);
                        metadata.apiInfo.apiDefinition = apiDefinition;
                    } else {
                        log:printError(body.message());
                    }
                }
            }
        }
        string apiId = check utils:updateAPIMetadata(metadata, apiID, orgName);
        string|error apiImageUpdateResponse = utils:updateApiImagePath(metadata.apiInfo.apiArtifacts.apiImages, apiId, metadata.apiInfo.orgName);
        if apiImageUpdateResponse is error {
            log:printError(apiImageUpdateResponse.toString());
        }
        http:Response response = new;
        response.setPayload({apiId: apiId});
        return response;
    }

    resource function get api(string apiID, string orgName) returns models:ApiMetadataResponse|error {

        string orgId = check utils:getOrgId(orgName);
        store:ApiMetadataWithRelations apiMetaData = check adminClient->/apimetadata/[apiID]/[orgId].get();
        store:ThrottlingPolicyOptionalized[] policies = apiMetaData.throttlingPolicies ?: [];
        store:AdditionalPropertiesWithRelations[] additionalProperties = apiMetaData.additionalProperties ?: [];
        store:ApiContentOptionalized[] apiContent = apiMetaData.apiContent ?: [];
        store:ApiImagesOptionalized[] apiImages = apiMetaData.apiImages ?: [];

        models:ThrottlingPolicy[] throttlingPolicies = [];

        foreach var policy in policies {
            models:ThrottlingPolicy policyData = {
                policyName: policy.policyName ?: "",
                description: policy.description ?: "",
                'category: policy.'type ?: ""
            };
            throttlingPolicies.push(policyData);
        }

        map<string> properties = {};

        foreach var property in additionalProperties {
            properties[property.key ?: ""] = property.value ?: "";
        }

        string[] apiContentRecord = [];

        foreach var property in apiContent {
            apiContentRecord.push(property.apiContent ?: "");
        }

        map<string> apiImagesRecord = {};

        foreach var property in apiImages {
            apiImagesRecord[property.imageTag ?: ""] = property.imagePath ?: "";
        }


        models:ApiMetadataResponse metaData = {
            serverUrl: {
                sandboxUrl: apiMetaData.sandboxUrl ?: "",
                productionUrl: apiMetaData.productionUrl ?: ""
            },
            throttlingPolicies: throttlingPolicies,
            apiInfo: {
                apiName: apiMetaData.apiName ?: "",
                apiCategory: apiMetaData.apiCategory ?: "",
                tags: regex:split(apiMetaData?.tags ?: "", " "),
                additionalProperties: properties,
                orgName: apiMetaData.organizationName ?: "",
                apiArtifacts: {apiContent: apiContentRecord, apiImages: apiImagesRecord},
                apiVersion: apiMetaData.apiVersion ?: "",
                authorizedRoles: regex:split(apiMetaData?.authorizedRoles ?: "", " "),
                apiDescription: apiMetaData.apiDescription ?: "",
                apiType: apiMetaData.apiType ?: ""
            }
        };
        log:printInfo(apiMetaData?.authorizedRoles ?: "");

        return metaData;
    }

    resource function get apiDefinition(string apiID, string orgName) returns http:Response|error {

        string orgId = check utils:getOrgId(orgName);
        mime:Entity file = new;
        http:Response response = new;
        store:ApiMetadataWithRelations apiMetaData = check adminClient->/apimetadata/[apiID]/[orgId].get();
        string apiDefinition = apiMetaData.apiDefinition ?: "";
        string apiType = apiMetaData.apiType ?: "";
        mime:ContentDisposition cDisposition = new ();
        if (!apiType.equalsIgnoreCaseAscii("SOAP")) {
            cDisposition = mime:getContentDispositionObject("form-data; name=filepart; filename=apiDefinition.json");
        } else {
            cDisposition = mime:getContentDispositionObject("form-data; name=filepart; filename=apiDefinition.xml");
        }
        file.setBody(apiDefinition);
        file.setContentDisposition(cDisposition);
        response.setEntity(file);
        response.setHeader("Content-Description", "File Transfer");
        response.setHeader("Transfer-Encoding", "chunked");
        log:printInfo("API definition returned");
        return response;
    }

    resource function get apiList(string orgName) returns models:ApiMetadataResponse[]|error {

        //retrieve the organization id
        string orgId = check utils:getOrgId(orgName);
        stream<store:ApiMetadataWithRelations, persist:Error?> apiMetaDataList = adminClient->/apimetadata.get();

        store:ApiMetadataWithRelations[] apiList = check from var api in apiMetaDataList
            where api.orgId == orgId
            select api;

        models:ApiMetadataResponse[] apis = [];
        foreach var apiMetaData in apiList {

            store:ThrottlingPolicyOptionalized[] policies = apiMetaData.throttlingPolicies ?: [];
            store:AdditionalPropertiesWithRelations[] additionalProperties = apiMetaData.additionalProperties ?: [];
            store:ApiContentOptionalized[] apiContent = apiMetaData.apiContent ?: [];
            store:ApiImagesOptionalized[] apiImages = apiMetaData.apiImages ?: [];

            models:ThrottlingPolicy[] throttlingPolicies = [];

            foreach var policy in policies {
                models:ThrottlingPolicy policyData = {
                    policyName: policy.policyName ?: "",
                    description: policy.description ?: "",
                    'category: policy.'type ?: ""
                };
                throttlingPolicies.push(policyData);
            }

            map<string> properties = {};

            foreach var property in additionalProperties {
                properties[property.key ?: ""] = property.value ?: "";
            }

            string[] apiContentRecord = [];

            foreach var property in apiContent {
                apiContentRecord.push(property.apiContent ?: "");
            }

            map<string> apiImagesRecord = {};

            foreach var property in apiImages {
                apiImagesRecord[property.imageTag ?: ""] = property.imagePath ?: "";
            }

            models:ApiMetadataResponse metaData = {
                serverUrl: {
                    sandboxUrl: apiMetaData.sandboxUrl ?: "",
                    productionUrl: apiMetaData.productionUrl ?: ""
                },
                throttlingPolicies: throttlingPolicies,
                apiInfo: {
                    apiName: apiMetaData.apiName ?: "",
                    apiCategory: apiMetaData.apiCategory ?: "",
                    tags: regex:split(apiMetaData?.tags ?: "", " "),
                    additionalProperties: properties,
                    orgName: apiMetaData.organizationName ?: "",
                    apiArtifacts: {apiContent: apiContentRecord, apiImages: apiImagesRecord},
                    apiVersion: apiMetaData.apiVersion ?: "",
                    authorizedRoles: regex:split(apiMetaData?.authorizedRoles ?: "", " "),
                    apiDescription: apiMetaData.apiDescription ?: "",
                    apiType: apiMetaData.apiType ?: ""
                }
            };
            apis.push(metaData);
        }
        return apis;
    }

    resource function post apiContent(http:Request request, string orgName, string apiName) returns string|error {

        string apiId = check utils:getAPIId(orgName, apiName);

        byte[] binaryPayload = check request.getBinaryPayload();
        
        string tmpDir = check file:createTempDir();
        string path = tmpDir + "/tmp";
        string targetPath = tmpDir + "/" + orgName;

        check io:fileWriteBytes(path, binaryPayload);
        error? result = check zip:extract(path, targetPath);

        file:MetaData[] directories = check file:readDir(targetPath+ "/" + apiName + "/content");

        models:APIAssets[] apiAssets = [];
        apiAssets = check utils:readAPIContent(directories, orgName, apiId, apiAssets);

        log:printInfo("APIAssets ".'join(apiAssets.length().toString()));

        //store only md files given by the api developer
        foreach var item in apiAssets {
            if (!item.fileName.endsWith("md")) {
                int index = apiAssets.indexOf(item) ?: 0;
                models:APIAssets remove = apiAssets.remove(index);
            }
        }

        log:printInfo("APIAssets removed ".'join(apiAssets.length().toString()));

        check file:createDir("./" + orgName + "/resources/images", file:RECURSIVE);

        boolean dirExists = check file:test("./" + orgName + "/" + apiName + "/images", file:EXISTS);

        if (dirExists) {
            check file:copy("./" + orgName + "/" + apiName + "/images", "./" + orgName + "/resources/images");
            file:MetaData[] imageDir = check file:readDir("./" + orgName + "/resources/images");

            models:APIImages[] apiImages = [];
            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.indexOf("/")), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii("/resources/images/.DS_Store")) {
                    apiImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName.substring(<int>(imageName.lastIndexOf("/") + 1), imageName.length()),
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
        if apiContent is string {

        }
        if apiContent is error {
            return "Asset update failed";
        }
        io:println("API content added successfully");
        return "API asset updated";
    }

    resource function put apiContent(http:Request request, string orgName, string apiName) returns string|error {

        string apiId = check utils:getAPIId(orgName, apiName);
        byte[] binaryPayload = check request.getBinaryPayload();
        string tmpDir = check file:createTempDir();
        string path = tmpDir + "/tmp";
        string targetPath = tmpDir + "/" + orgName ;
        check io:fileWriteBytes(path, binaryPayload);
        error? result = check zip:extract(path, targetPath);

        file:MetaData[] directories = check file:readDir(targetPath+ "/" + apiName + "/content");

        models:APIAssets[] apiAssets = [];
        apiAssets = check utils:readAPIContent(directories, orgName, apiId, apiAssets);

        //store only md files given by the api developer
        foreach var item in apiAssets {
            if (!item.fileName.endsWith("md")) {
                int index = apiAssets.indexOf(item) ?: 0;
                models:APIAssets remove = apiAssets.remove(index);
            }
        }
        check file:createDir("./" + orgName + "/resources/images", file:RECURSIVE);
        boolean dirExists = check file:test("/" + orgName + "/" + apiName + "/images", file:EXISTS);

        if (dirExists) {
            check file:copy("./" + orgName + "/" + apiName + "/images", "./" + orgName + "/resources/images");
            file:MetaData[] imageDir = check file:readDir("./" + orgName + "/resources/images");

            models:APIImages[] apiImages = [];
            foreach var file in imageDir {
                string imageName = check file:relativePath(file:getCurrentDir(), file.absPath);
                imageName = imageName.substring(<int>(imageName.indexOf("/")), imageName.length());
                if (!imageName.equalsIgnoreCaseAscii("/resources/images/.DS_Store")) {
                    apiImages.push({
                        image: check io:fileReadBytes(check file:relativePath(file:getCurrentDir(), file.absPath)),
                        imageName: imageName,
                        imageTag: ""
                    }
                    );
                }
            }
            if (storage.equalsIgnoreCaseAscii("DB")) {
                string|error apiImagesResult = utils:updateApiImages(apiImages, apiId, orgName);
                if apiImagesResult is error {
                    log:printError(apiImagesResult.toString());
                }
            } else {
                check utils:pushContentS3(imageDir, "text/plain");
            }
        }

        check file:remove(orgName, file:RECURSIVE);
        string|error? apiContent = utils:updateApiContent(apiAssets, apiId, orgName);
        if apiContent is error {
            log:printError(apiContent.toString());
            return "Asset update failed";
        }
        check file:remove(targetPath, file:RECURSIVE);
        io:println("API content added successfully");
        return "API asset updated";
    }

    resource function get apiFiles(string orgName, string apiID, string fileName, http:Request request) returns error|http:Response {

        mime:Entity file = new;
        http:Response response = new;
        if (fileName.endsWith(".html") || fileName.endsWith(".hbs") || fileName.endsWith(".md")) {
            string content = check utils:retrieveAPIContent(apiID, orgName, fileName);
            if (content.equalsIgnoreCaseAscii("API content not found") && fileName.endsWith(".hbs")) {
                content = check utils:retrieveOrgFiles(fileName, orgName);
            }
            file.setBody(content);
            response.setEntity(file);
        } else {
            byte[]|string|error? image = check utils:retrieveAPIImages(fileName, apiID, orgName);
            if (image is byte[]) {
                if (fileName.endsWith(".svg")) {
                    string imageContent = check string:fromBytes(image);
                    file.setBody(imageContent);
                    response.setEntity(file);
                    response.setHeader("Content-Type", "image/svg+xml");
                } else {
                    file.setBody(image);
                    response.setEntity(file);
                    response.setHeader("Content-Type", "application/octet-stream");
                }
            } else {
                file.setBody("File not found");
            }
        }
        response.setHeader("Content-Description", "File Transfer");
        response.setHeader("Transfer-Encoding", "chunked");
        return response;
    }
}

