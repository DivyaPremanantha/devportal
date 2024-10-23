import devportal.models;

import ballerina/file;
import ballerina/io;
import ballerina/log;
import ballerina/mime;
import ballerina/regex;
import ballerinax/aws.s3;

public function extractPayload(mime:Entity bodyPart) returns string {
    // Get the media type from the body part retrieved from the request.
    var mediaType = mime:getMediaType(bodyPart.getContentType());
    string payLoad = "";
    if mediaType is mime:MediaType {
        string baseType = mediaType.getBaseType();
        if mime:APPLICATION_JSON == baseType {
            var body = bodyPart.getJson();
            if body is json {
                payLoad = body.toJsonString();
                log:printInfo(body.toJsonString());
            } else {
                log:printError(body.message());
            }
        }
    }
    return payLoad;
}

public function readOrganizationContent(file:MetaData[] directories, string path, string[] assetMappings) returns string[]|error {

    foreach var item in directories {
        if (item.dir) {
            file:MetaData[] meta = check file:readDir(item.absPath);
            _ = check readOrganizationContent(meta, path, assetMappings);
        } else {
            string relativePath = check file:relativePath(file:getCurrentDir(), item.absPath);

            if (relativePath.endsWith(".html")) {
                if (relativePath.endsWith("org-landing-page.html")) {
                    assetMappings.push(relativePath);
                }
                if (relativePath.endsWith("api-landing-page.html")) {
                    assetMappings.push(relativePath);
                }
                assetMappings.push(relativePath);
            } else if (relativePath.endsWith(".css")) {
                assetMappings.push(relativePath);

            } else if (relativePath.endsWith(".mp4") || relativePath.endsWith(".webm") || relativePath.endsWith(".ogv")) {
                assetMappings.push(relativePath);

            } else if (relativePath.endsWith(".png") || relativePath.endsWith(".jpg") || relativePath.endsWith(".jpeg") ||
            relativePath.endsWith(".gif") || relativePath.endsWith(".svg") || relativePath.endsWith(".ico") || relativePath.endsWith(".webp")) {
                assetMappings.push(relativePath);
            }
        }
    }
    return assetMappings;
}

public function pushContentS3(file:MetaData[] directories, string contentType) returns error? {

    log:printDebug("Reading API Content");
    foreach var item in directories {
        s3:Client|error amazonS3Client = createAmazonS3Client();
        string relativePath = check file:relativePath(file:getCurrentDir(), item.absPath);

        byte[] imgContent = check io:fileReadBytes(relativePath);
        int lastIndex = <int>relativePath.lastIndexOf("/");

        if (amazonS3Client is s3:Client) {
            io:println("Uploading Content to Amazon S3: " + relativePath);
            s3:ObjectCreationHeaders objectCreationHeaders = {};
            objectCreationHeaders.contentType = contentType;
            var result = amazonS3Client->createObject("devportal-content/" + relativePath.substring(0, lastIndex), relativePath.substring(lastIndex + 1), imgContent, s3:ACL_PUBLIC_READ, objectCreationHeaders);
            if (result is error) {
                log:printError("Error uploading the org landing page to Amazon S3");
            }
        }
    }
}

public function readAPIContent(file:MetaData[] directories, string orgname, string apiID, models:APIAssets[] apiAssets) returns models:APIAssets[]|error {

    log:printDebug("Reading API Content");
    foreach var item in directories {
        if (item.dir) {
            file:MetaData[] meta = check file:readDir(item.absPath);
            _ = check readAPIContent(meta, orgname, apiID, apiAssets);
        } else {
            string relativePath = check file:relativePath(file:getCurrentDir(), item.absPath);
            log:printInfo(relativePath);
            string fileName = item.absPath.substring(<int>(item.absPath.lastIndexOf("/") + 1), item.absPath.length());
            if (relativePath.endsWith("md") || relativePath.endsWith("hbs")) {
                models:APIAssets assetMapping = {
                    apiContent: check io:fileReadString(relativePath),
                    fileName: fileName,
                    apiImages: [],
                    apiId: apiID
                };
                apiAssets.push(assetMapping);
            }
        }
    }
    return apiAssets;
}

public function createAmazonS3Client() returns s3:Client|error {
    s3:ConnectionConfig amazonS3Config = {
        accessKeyId: models:awsAccessKeyId,
        secretAccessKey: models:awsSecretAccessKey,
        region: models:awsRegion,
        timeout: 120
    };

    return check new (amazonS3Config);
}

public function getAssetmapping(file:MetaData[] directory, models:OrganizationAssets[] assetMappings, string orgId, string orgName, string adminURL)
returns models:OrganizationAssets[]|error {

    string pageType = "";
    string dirName = "";
    string templateName = "";
    foreach var item in directory {

        if (item.dir) {
            file:MetaData[] meta = check file:readDir(item.absPath);
            _ = check getAssetmapping(meta, assetMappings, orgId, orgName, adminURL);
        } else {
            string fileName = item.absPath.substring(<int>(item.absPath.lastIndexOf("/") + 1), item.absPath.length());
            string filePath = "";
            if (!fileName.endsWith(".DS_Store")) {
                // Find the last two directory name
                //io:println("item.absPath: " + item.absPath);
                int lastSlashIndex = <int>item.absPath.lastIndexOf("/");
                int secondLastSlashIndex = <int>item.absPath.lastIndexOf("/", lastSlashIndex - 1);
                dirName = item.absPath.substring(secondLastSlashIndex + 1, lastSlashIndex);

                if (fileName.endsWith(".css")) {
                    pageType = "styles";
                    if (dirName == "layout") {
                        templateName = "main";
                    } else if (dirName == "partials") {
                        int thirdLastSlashIndex = <int>item.absPath.lastIndexOf("/", secondLastSlashIndex - 1);
                        var thirdDirName = item.absPath.substring(thirdLastSlashIndex + 1, secondLastSlashIndex);
                        if (thirdDirName == orgName) {
                            templateName = "main";
                        } else {
                            templateName = thirdDirName;
                        }
                    } else {
                        templateName = dirName;
                    }
                } else if (fileName.endsWith(".hbs") && dirName == "layout") {
                    pageType = "layout";
                    templateName = "main";
                } else if (fileName.endsWith(".hbs") && dirName == "partials") {
                    pageType = "partials";
                    int thirdLastSlashIndex = <int>item.absPath.lastIndexOf("/", secondLastSlashIndex - 1);
                    var thirdDirName = item.absPath.substring(thirdLastSlashIndex + 1, secondLastSlashIndex);
                    if (thirdDirName == orgName) {
                        templateName = "main";
                    } else {
                        templateName = thirdDirName;
                    }
                } else if (fileName.endsWith(".md") && dirName == "content") {
                    pageType = "markDown";
                    int thirdLastSlashIndex = <int>item.absPath.lastIndexOf("/", secondLastSlashIndex - 1);
                    var thirdDirName = item.absPath.substring(thirdLastSlashIndex + 1, secondLastSlashIndex);
                    if (thirdDirName == orgName) {
                        templateName = "main";
                    } else {
                        templateName = thirdDirName;
                    }
                } else if (fileName.endsWith(".hbs")) {
                    pageType = "template";
                    templateName = dirName;
                }
            }
            if (!fileName.equalsIgnoreCaseAscii(".DS_Store")) {
                string pageContent = check io:fileReadString(item.absPath);

                if (fileName.equalsIgnoreCaseAscii("main.css")) {

                    pageContent = regex:replaceAll(pageContent, "@import '", "@import url(\" ");
                    pageContent = regex:replaceAll(pageContent, "';", "\");");
                    pageContent = regex:replaceAll(pageContent, "\\/styles\\/", adminURL + orgName + "&fileName=");
                    // log:printInfo(pageContent);

                }
                if (fileName.equalsIgnoreCaseAscii("main.hbs")) {
                    pageContent = regex:replaceAll(pageContent, "\\/styles\\/", adminURL + orgName + "&fileName=");
                }
                pageContent = regex:replaceAll(pageContent, "\\/images\\/", adminURL + orgName + "&fileName=");

                models:OrganizationAssets assetMapping = {
                    pageType: pageType,
                    pageContent: pageContent,
                    orgId: orgId,
                    orgName: orgName,
                    pageName: fileName,
                    dirName: templateName
                };
                assetMappings.push(assetMapping);
            }
        }
    }
    return assetMappings;
}

# Description.
#
# + directories - parameter description
# + return - return value description
public function addFileTypeContent(file:MetaData[] directories, file:MetaData[] stylesheetDir, string fileType) returns file:MetaData[]|error {
    io:println("Reading API Content");
    foreach var item in directories {
        if (item.dir) {
            file:MetaData[] meta = check file:readDir(item.absPath);
            _ = check addFileTypeContent(meta, stylesheetDir, fileType);
        } else {
            string relativePath = check file:relativePath(file:getCurrentDir(), item.absPath);
            if (relativePath.endsWith(fileType)) {
                stylesheetDir.push(item);
            }
        }
    }

    return stylesheetDir;
}
