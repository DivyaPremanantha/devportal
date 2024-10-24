-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS "OrganizationAssets";
DROP TABLE IF EXISTS "ApiImages";
DROP TABLE IF EXISTS "SubscriptionPlanMapping";
DROP TABLE IF EXISTS "ApplicationProperties";
DROP TABLE IF EXISTS "IdentityProvider";
DROP TABLE IF EXISTS "AdditionalProperties";
DROP TABLE IF EXISTS "Subscription";
DROP TABLE IF EXISTS "ApiContent";
DROP TABLE IF EXISTS "ThrottlingPolicy";
DROP TABLE IF EXISTS "OrgImages";
DROP TABLE IF EXISTS "SubscriptionPlan";
DROP TABLE IF EXISTS "Organization";
DROP TABLE IF EXISTS "ApiMetadata";
DROP TABLE IF EXISTS "Application";

CREATE TABLE "Application" (
	"appId" VARCHAR(191) NOT NULL,
	"applicationName" VARCHAR(191) NOT NULL,
	"sandBoxKey" VARCHAR(191) NOT NULL,
	"productionKey" VARCHAR(191) NOT NULL,
	"addedAPIs" VARCHAR(191) NOT NULL,
	"idpId" VARCHAR(191) NOT NULL,
	PRIMARY KEY("appId")
);

CREATE TABLE "ApiMetadata" (
	"apiId" VARCHAR(191) NOT NULL,
	"orgId" VARCHAR(191) NOT NULL,
	"apiName" VARCHAR(191) NOT NULL,
	"organizationName" VARCHAR(191) NOT NULL,
	"apiCategory" VARCHAR(191) NOT NULL,
	"tags" VARCHAR(191) NOT NULL,
	"apiVersion" VARCHAR(191) NOT NULL,
    "apiDescription" VARCHAR(191) NOT NULL,
    "apiType" VARCHAR(191) NOT NULL,
	"apiDefinition" TEXT NOT NULL,
	"productionUrl" VARCHAR(191) NOT NULL,
	"sandboxUrl" VARCHAR(191) NOT NULL,
	"authorizedRoles" VARCHAR(191),
	"metadata" TEXT NOT NULL,
	PRIMARY KEY("apiId","orgId")
);

CREATE TABLE "Organization" (
	"orgId" VARCHAR(191) NOT NULL,
	"organizationName" VARCHAR(191) NOT NULL,
	"isPublic" BOOLEAN NOT NULL,
	"authenticatedPages" VARCHAR(191) NOT NULL,
	PRIMARY KEY("orgId")
);

CREATE TABLE "SubscriptionPlan" (
	"subscriptionPlanID" VARCHAR(191) NOT NULL,
	"policyName" VARCHAR(191) NOT NULL,
	"displayName" VARCHAR(191) NOT NULL,
	"description" VARCHAR(191) NOT NULL,
	"amount" VARCHAR(191) NOT NULL,
	"organizationOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("organizationOrgId") REFERENCES "Organization"("orgId"),
	PRIMARY KEY("subscriptionPlanID")
);


CREATE TABLE "OrgImages" (
	"fileName" VARCHAR(191) NOT NULL,
	"image" BYTEA NOT NULL,
	"orgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("orgId") REFERENCES "Organization"("orgId"),
	PRIMARY KEY("orgId","fileName")
);

CREATE TABLE "ThrottlingPolicy" (
	"policyId" VARCHAR(191) NOT NULL,
	"type" VARCHAR(191) NOT NULL,
	"policyName" VARCHAR(191) NOT NULL,
		"description" VARCHAR(191) NOT NULL,
		"apimetadataApiId" VARCHAR(191) NOT NULL,
	"apimetadataOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("apimetadataApiId", "apimetadataOrgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("policyId")
);

CREATE TABLE "ApiContent" (
	"apiContentId" VARCHAR(191) NOT NULL,
	"apiContent" text NOT NULL,
	"fileName" VARCHAR(191) NOT NULL,
	"apimetadataApiId" VARCHAR(191) NOT NULL,
	"apimetadataOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("apimetadataApiId", "apimetadataOrgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("apiContentId")
);

CREATE TABLE "Subscription" (
	"subscriptionId" VARCHAR(191) NOT NULL,
	"userName" VARCHAR(191) NOT NULL,
	"organizationOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("organizationOrgId") REFERENCES "Organization"("orgId"),
	"subscriptionplanSubscriptionPlanID" VARCHAR(191) UNIQUE NOT NULL,
	FOREIGN KEY("subscriptionplanSubscriptionPlanID") REFERENCES "SubscriptionPlan"("subscriptionPlanID"),
	"apimetadataApiId" VARCHAR(191) NOT NULL,
	"apimetadataOrgId" VARCHAR(191) NOT NULL,
	UNIQUE ("apimetadataApiId", "apimetadataOrgId"),
	FOREIGN KEY("apimetadataApiId", "apimetadataOrgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("subscriptionId")
);

CREATE TABLE "AdditionalProperties" (
	"key" VARCHAR(191) NOT NULL,
	"value" VARCHAR(191) NOT NULL,
	"apiId" VARCHAR(191) NOT NULL,
	"orgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("apiId", "orgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("apiId","orgId","key")
	
);

CREATE TABLE "IdentityProvider" (
	"idpId" VARCHAR(191) NOT NULL,
	"orgName" VARCHAR(191) NOT NULL,
	"issuer" VARCHAR(191) NOT NULL,
	"authorizationURL" VARCHAR(191) NOT NULL,
	"tokenURL" VARCHAR(191) NOT NULL,
	"userInfoURL" VARCHAR(191) NOT NULL,
	"clientId" VARCHAR(191) NOT NULL,
	"callbackURL" VARCHAR(191) NOT NULL,
	"scope" VARCHAR(191) NOT NULL,
	"signUpURL" VARCHAR(191) NOT NULL,
	"logoutURL" VARCHAR(191) NOT NULL,
	"logoutRedirectURI" VARCHAR(191) NOT NULL,
	"organizationOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("organizationOrgId") REFERENCES "Organization"("orgId"),
	PRIMARY KEY("idpId")
);

CREATE TABLE "ApplicationProperties" (
	"propertyId" VARCHAR(191) NOT NULL,
	"name" VARCHAR(191) NOT NULL,
	"value" VARCHAR(191) NOT NULL,
	"applicationAppId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("applicationAppId") REFERENCES "Application"("appId"),
	PRIMARY KEY("propertyId")
);

CREATE TABLE "SubscriptionPlanMapping" (
	"mappingId" VARCHAR(191) NOT NULL,
	"subscriptionplanSubscriptionPlanID" VARCHAR(191) NOT NULL,
	FOREIGN KEY("subscriptionplanSubscriptionPlanID") REFERENCES "SubscriptionPlan"("subscriptionPlanID"),
	"apimetadataApiId" VARCHAR(191) NOT NULL,
	"apimetadataOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("apimetadataApiId", "apimetadataOrgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("mappingId")
);

CREATE TABLE "ApiImages" (
	"imageTag" VARCHAR(191) NOT NULL,
	"imagePath" VARCHAR(191) NOT NULL,
	"image" BYTEA NOT NULL,
	"apiId" VARCHAR(191) NOT NULL,
	"orgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("apiId", "orgId") REFERENCES "ApiMetadata"("apiId", "orgId"),
	PRIMARY KEY("imageTag","apiId","orgId")
);

CREATE TABLE "OrganizationAssets" (
	"orgAssetId" VARCHAR(191) NOT NULL,
	"pageType" VARCHAR(191) NOT NULL,
	"pageName" VARCHAR(191) NOT NULL,
	"pageContent" TEXT NOT NULL,
    "filePath" VARCHAR(191) NOT NULL,
	"orgName" VARCHAR(191) NOT NULL,
	"organizationOrgId" VARCHAR(191) NOT NULL,
	FOREIGN KEY("organizationOrgId") REFERENCES "Organization"("orgId"),
	PRIMARY KEY("orgAssetId")
);
