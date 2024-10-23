// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/persist.sql as psql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

const THROTTLING_POLICY = "throttlingpolicies";
const API_METADATA = "apimetadata";
const API_CONTENT = "apicontents";
const API_IMAGES = "apiimages";
const ORG_IMAGES = "orgimages";
const ADDITIONAL_PROPERTIES = "additionalproperties";
const IDENTITY_PROVIDER = "identityproviders";
const APPLICATION = "applications";
const ORGANIZATION = "organizations";
const ORGANIZATION_ASSETS = "organizationassets";
const APPLICATION_PROPERTIES = "applicationproperties";
const SUBSCRIPTION_PLAN_MAPPING = "subscriptionplanmappings";
const SUBSCRIPTION_PLAN = "subscriptionplans";
const SUBSCRIPTION = "subscriptions";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final postgresql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [THROTTLING_POLICY]: {
            entityName: "ThrottlingPolicy",
            tableName: "ThrottlingPolicy",
            fieldMetadata: {
                policyId: {columnName: "policyId"},
                'type: {columnName: "type"},
                policyName: {columnName: "policyName"},
                description: {columnName: "description"},
                apimetadataApiId: {columnName: "apimetadataApiId"},
                apimetadataOrgId: {columnName: "apimetadataOrgId"},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["policyId"],
            joinMetadata: {apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apimetadataApiId", "apimetadataOrgId"], 'type: psql:ONE_TO_MANY}}
        },
        [API_METADATA]: {
            entityName: "ApiMetadata",
            tableName: "ApiMetadata",
            fieldMetadata: {
                apiId: {columnName: "apiId"},
                orgId: {columnName: "orgId"},
                apiName: {columnName: "apiName"},
                metadata: {columnName: "metadata"},
                organizationName: {columnName: "organizationName"},
                apiCategory: {columnName: "apiCategory"},
                apiVersion: {columnName: "apiVersion"},
                apiDescription: {columnName: "apiDescription"},
                apiType: {columnName: "apiType"},
                tags: {columnName: "tags"},
                apiDefinition: {columnName: "apiDefinition"},
                productionUrl: {columnName: "productionUrl"},
                sandboxUrl: {columnName: "sandboxUrl"},
                authorizedRoles: {columnName: "authorizedRoles"},
                "additionalProperties[].apiId": {relation: {entityName: "additionalProperties", refField: "apiId"}},
                "additionalProperties[].orgId": {relation: {entityName: "additionalProperties", refField: "orgId"}},
                "additionalProperties[].key": {relation: {entityName: "additionalProperties", refField: "key"}},
                "additionalProperties[].value": {relation: {entityName: "additionalProperties", refField: "value"}},
                "throttlingPolicies[].policyId": {relation: {entityName: "throttlingPolicies", refField: "policyId"}},
                "throttlingPolicies[].type": {relation: {entityName: "throttlingPolicies", refField: "type"}},
                "throttlingPolicies[].policyName": {relation: {entityName: "throttlingPolicies", refField: "policyName"}},
                "throttlingPolicies[].description": {relation: {entityName: "throttlingPolicies", refField: "description"}},
                "throttlingPolicies[].apimetadataApiId": {relation: {entityName: "throttlingPolicies", refField: "apimetadataApiId"}},
                "throttlingPolicies[].apimetadataOrgId": {relation: {entityName: "throttlingPolicies", refField: "apimetadataOrgId"}},
                "apiContent[].apiContentId": {relation: {entityName: "apiContent", refField: "apiContentId"}},
                "apiContent[].apimetadataApiId": {relation: {entityName: "apiContent", refField: "apimetadataApiId"}},
                "apiContent[].apimetadataOrgId": {relation: {entityName: "apiContent", refField: "apimetadataOrgId"}},
                "apiContent[].apiContent": {relation: {entityName: "apiContent", refField: "apiContent"}},
                "apiContent[].fileName": {relation: {entityName: "apiContent", refField: "fileName"}},
                "apiImages[].imageTag": {relation: {entityName: "apiImages", refField: "imageTag"}},
                "apiImages[].apiId": {relation: {entityName: "apiImages", refField: "apiId"}},
                "apiImages[].orgId": {relation: {entityName: "apiImages", refField: "orgId"}},
                "apiImages[].imagePath": {relation: {entityName: "apiImages", refField: "imagePath"}},
                "apiImages[].image": {relation: {entityName: "apiImages", refField: "image"}},
                "subscriptionPlans[].mappingId": {relation: {entityName: "subscriptionPlans", refField: "mappingId"}},
                "subscriptionPlans[].subscriptionplanSubscriptionPlanID": {relation: {entityName: "subscriptionPlans", refField: "subscriptionplanSubscriptionPlanID"}},
                "subscriptionPlans[].subscriptionplanOrgId": {relation: {entityName: "subscriptionPlans", refField: "subscriptionplanOrgId"}},
                "subscriptionPlans[].apimetadataApiId": {relation: {entityName: "subscriptionPlans", refField: "apimetadataApiId"}},
                "subscriptionPlans[].apimetadataOrgId": {relation: {entityName: "subscriptionPlans", refField: "apimetadataOrgId"}},
                "subscription.subscriptionId": {relation: {entityName: "subscription", refField: "subscriptionId"}},
                "subscription.userName": {relation: {entityName: "subscription", refField: "userName"}},
                "subscription.organizationOrgId": {relation: {entityName: "subscription", refField: "organizationOrgId"}},
                "subscription.subscriptionplanSubscriptionPlanID": {relation: {entityName: "subscription", refField: "subscriptionplanSubscriptionPlanID"}},
                "subscription.subscriptionplanOrgId": {relation: {entityName: "subscription", refField: "subscriptionplanOrgId"}},
                "subscription.apimetadataApiId": {relation: {entityName: "subscription", refField: "apimetadataApiId"}},
                "subscription.apimetadataOrgId": {relation: {entityName: "subscription", refField: "apimetadataOrgId"}}
            },
            keyFields: ["apiId", "orgId"],
            joinMetadata: {
                additionalProperties: {entity: AdditionalProperties, fieldName: "additionalProperties", refTable: "AdditionalProperties", refColumns: ["apiId", "orgId"], joinColumns: ["apiId", "orgId"], 'type: psql:MANY_TO_ONE},
                throttlingPolicies: {entity: ThrottlingPolicy, fieldName: "throttlingPolicies", refTable: "ThrottlingPolicy", refColumns: ["apimetadataApiId", "apimetadataOrgId"], joinColumns: ["apiId", "orgId"], 'type: psql:MANY_TO_ONE},
                apiContent: {entity: ApiContent, fieldName: "apiContent", refTable: "ApiContent", refColumns: ["apimetadataApiId", "apimetadataOrgId"], joinColumns: ["apiId", "orgId"], 'type: psql:MANY_TO_ONE},
                apiImages: {entity: ApiImages, fieldName: "apiImages", refTable: "ApiImages", refColumns: ["apiId", "orgId"], joinColumns: ["apiId", "orgId"], 'type: psql:MANY_TO_ONE},
                subscriptionPlans: {entity: SubscriptionPlanMapping, fieldName: "subscriptionPlans", refTable: "SubscriptionPlanMapping", refColumns: ["apimetadataApiId", "apimetadataOrgId"], joinColumns: ["apiId", "orgId"], 'type: psql:MANY_TO_ONE},
                subscription: {entity: Subscription, fieldName: "subscription", refTable: "Subscription", refColumns: ["apimetadataApiId", "apimetadataOrgId"], joinColumns: ["apiId", "orgId"], 'type: psql:ONE_TO_ONE}
            }
        },
        [API_CONTENT]: {
            entityName: "ApiContent",
            tableName: "ApiContent",
            fieldMetadata: {
                apiContentId: {columnName: "apiContentId"},
                apimetadataApiId: {columnName: "apimetadataApiId"},
                apimetadataOrgId: {columnName: "apimetadataOrgId"},
                apiContent: {columnName: "apiContent"},
                fileName: {columnName: "fileName"},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["apiContentId"],
            joinMetadata: {apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apimetadataApiId", "apimetadataOrgId"], 'type: psql:ONE_TO_MANY}}
        },
        [API_IMAGES]: {
            entityName: "ApiImages",
            tableName: "ApiImages",
            fieldMetadata: {
                imageTag: {columnName: "imageTag"},
                apiId: {columnName: "apiId"},
                orgId: {columnName: "orgId"},
                imagePath: {columnName: "imagePath"},
                image: {columnName: "image"},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["imageTag", "apiId", "orgId"],
            joinMetadata: {apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apiId", "orgId"], 'type: psql:ONE_TO_MANY}}
        },
        [ORG_IMAGES]: {
            entityName: "OrgImages",
            tableName: "OrgImages",
            fieldMetadata: {
                orgId: {columnName: "orgId"},
                fileName: {columnName: "fileName"},
                image: {columnName: "image"},
                "organization.orgId": {relation: {entityName: "organization", refField: "orgId"}},
                "organization.organizationName": {relation: {entityName: "organization", refField: "organizationName"}},
                "organization.isPublic": {relation: {entityName: "organization", refField: "isPublic"}},
                "organization.authenticatedPages": {relation: {entityName: "organization", refField: "authenticatedPages"}}
            },
            keyFields: ["orgId", "fileName"],
            joinMetadata: {organization: {entity: Organization, fieldName: "organization", refTable: "Organization", refColumns: ["orgId"], joinColumns: ["orgId"], 'type: psql:ONE_TO_MANY}}
        },
        [ADDITIONAL_PROPERTIES]: {
            entityName: "AdditionalProperties",
            tableName: "AdditionalProperties",
            fieldMetadata: {
                apiId: {columnName: "apiId"},
                orgId: {columnName: "orgId"},
                key: {columnName: "key"},
                value: {columnName: "value"},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["apiId", "orgId", "key"],
            joinMetadata: {apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apiId", "orgId"], 'type: psql:ONE_TO_MANY}}
        },
        [IDENTITY_PROVIDER]: {
            entityName: "IdentityProvider",
            tableName: "IdentityProvider",
            fieldMetadata: {
                idpId: {columnName: "idpId"},
                orgName: {columnName: "orgName"},
                issuer: {columnName: "issuer"},
                authorizationURL: {columnName: "authorizationURL"},
                tokenURL: {columnName: "tokenURL"},
                userInfoURL: {columnName: "userInfoURL"},
                clientId: {columnName: "clientId"},
                callbackURL: {columnName: "callbackURL"},
                scope: {columnName: "scope"},
                signUpURL: {columnName: "signUpURL"},
                logoutURL: {columnName: "logoutURL"},
                logoutRedirectURI: {columnName: "logoutRedirectURI"},
                organizationOrgId: {columnName: "organizationOrgId"},
                "organization.orgId": {relation: {entityName: "organization", refField: "orgId"}},
                "organization.organizationName": {relation: {entityName: "organization", refField: "organizationName"}},
                "organization.isPublic": {relation: {entityName: "organization", refField: "isPublic"}},
                "organization.authenticatedPages": {relation: {entityName: "organization", refField: "authenticatedPages"}}
            },
            keyFields: ["idpId"],
            joinMetadata: {organization: {entity: Organization, fieldName: "organization", refTable: "Organization", refColumns: ["orgId"], joinColumns: ["organizationOrgId"], 'type: psql:ONE_TO_MANY}}
        },
        [APPLICATION]: {
            entityName: "Application",
            tableName: "Application",
            fieldMetadata: {
                appId: {columnName: "appId"},
                applicationName: {columnName: "applicationName"},
                sandBoxKey: {columnName: "sandBoxKey"},
                productionKey: {columnName: "productionKey"},
                addedAPIs: {columnName: "addedAPIs"},
                userName: {columnName: "userName"},
                idpId: {columnName: "idpId"},
                "appProperties[].propertyId": {relation: {entityName: "appProperties", refField: "propertyId"}},
                "appProperties[].name": {relation: {entityName: "appProperties", refField: "name"}},
                "appProperties[].value": {relation: {entityName: "appProperties", refField: "value"}},
                "appProperties[].applicationAppId": {relation: {entityName: "appProperties", refField: "applicationAppId"}}
            },
            keyFields: ["appId"],
            joinMetadata: {appProperties: {entity: ApplicationProperties, fieldName: "appProperties", refTable: "ApplicationProperties", refColumns: ["applicationAppId"], joinColumns: ["appId"], 'type: psql:MANY_TO_ONE}}
        },
        [ORGANIZATION]: {
            entityName: "Organization",
            tableName: "Organization",
            fieldMetadata: {
                orgId: {columnName: "orgId"},
                organizationName: {columnName: "organizationName"},
                isPublic: {columnName: "isPublic"},
                authenticatedPages: {columnName: "authenticatedPages"},
                "organizationAssets[].orgAssetId": {relation: {entityName: "organizationAssets", refField: "orgAssetId"}},
                "organizationAssets[].pageName": {relation: {entityName: "organizationAssets", refField: "pageName"}},
                "organizationAssets[].orgName": {relation: {entityName: "organizationAssets", refField: "orgName"}},
                "organizationAssets[].pageType": {relation: {entityName: "organizationAssets", refField: "pageType"}},
                "organizationAssets[].filePath": {relation: {entityName: "organizationAssets", refField: "filePath"}},
                "organizationAssets[].pageContent": {relation: {entityName: "organizationAssets", refField: "pageContent"}},
                "organizationAssets[].organizationOrgId": {relation: {entityName: "organizationAssets", refField: "organizationOrgId"}},
                "identityProvider[].idpId": {relation: {entityName: "identityProvider", refField: "idpId"}},
                "identityProvider[].orgName": {relation: {entityName: "identityProvider", refField: "orgName"}},
                "identityProvider[].issuer": {relation: {entityName: "identityProvider", refField: "issuer"}},
                "identityProvider[].authorizationURL": {relation: {entityName: "identityProvider", refField: "authorizationURL"}},
                "identityProvider[].tokenURL": {relation: {entityName: "identityProvider", refField: "tokenURL"}},
                "identityProvider[].userInfoURL": {relation: {entityName: "identityProvider", refField: "userInfoURL"}},
                "identityProvider[].clientId": {relation: {entityName: "identityProvider", refField: "clientId"}},
                "identityProvider[].callbackURL": {relation: {entityName: "identityProvider", refField: "callbackURL"}},
                "identityProvider[].scope": {relation: {entityName: "identityProvider", refField: "scope"}},
                "identityProvider[].signUpURL": {relation: {entityName: "identityProvider", refField: "signUpURL"}},
                "identityProvider[].logoutURL": {relation: {entityName: "identityProvider", refField: "logoutURL"}},
                "identityProvider[].logoutRedirectURI": {relation: {entityName: "identityProvider", refField: "logoutRedirectURI"}},
                "identityProvider[].organizationOrgId": {relation: {entityName: "identityProvider", refField: "organizationOrgId"}},
                "subscriptions[].subscriptionId": {relation: {entityName: "subscriptions", refField: "subscriptionId"}},
                "subscriptions[].userName": {relation: {entityName: "subscriptions", refField: "userName"}},
                "subscriptions[].organizationOrgId": {relation: {entityName: "subscriptions", refField: "organizationOrgId"}},
                "subscriptions[].subscriptionplanSubscriptionPlanID": {relation: {entityName: "subscriptions", refField: "subscriptionplanSubscriptionPlanID"}},
                "subscriptions[].subscriptionplanOrgId": {relation: {entityName: "subscriptions", refField: "subscriptionplanOrgId"}},
                "subscriptions[].apimetadataApiId": {relation: {entityName: "subscriptions", refField: "apimetadataApiId"}},
                "subscriptions[].apimetadataOrgId": {relation: {entityName: "subscriptions", refField: "apimetadataOrgId"}},
                "orgImages[].orgId": {relation: {entityName: "orgImages", refField: "orgId"}},
                "orgImages[].fileName": {relation: {entityName: "orgImages", refField: "fileName"}},
                "orgImages[].image": {relation: {entityName: "orgImages", refField: "image"}}
            },
            keyFields: ["orgId"],
            joinMetadata: {
                organizationAssets: {entity: OrganizationAssets, fieldName: "organizationAssets", refTable: "OrganizationAssets", refColumns: ["organizationOrgId"], joinColumns: ["orgId"], 'type: psql:MANY_TO_ONE},
                identityProvider: {entity: IdentityProvider, fieldName: "identityProvider", refTable: "IdentityProvider", refColumns: ["organizationOrgId"], joinColumns: ["orgId"], 'type: psql:MANY_TO_ONE},
                subscriptions: {entity: Subscription, fieldName: "subscriptions", refTable: "Subscription", refColumns: ["organizationOrgId"], joinColumns: ["orgId"], 'type: psql:MANY_TO_ONE},
                orgImages: {entity: OrgImages, fieldName: "orgImages", refTable: "OrgImages", refColumns: ["orgId"], joinColumns: ["orgId"], 'type: psql:MANY_TO_ONE}
            }
        },
        [ORGANIZATION_ASSETS]: {
            entityName: "OrganizationAssets",
            tableName: "OrganizationAssets",
            fieldMetadata: {
                orgAssetId: {columnName: "orgAssetId"},
                pageName: {columnName: "pageName"},
                orgName: {columnName: "orgName"},
                pageType: {columnName: "pageType"},
                filePath: {columnName: "filePath"},
                pageContent: {columnName: "pageContent"},
                organizationOrgId: {columnName: "organizationOrgId"},
                "organization.orgId": {relation: {entityName: "organization", refField: "orgId"}},
                "organization.organizationName": {relation: {entityName: "organization", refField: "organizationName"}},
                "organization.isPublic": {relation: {entityName: "organization", refField: "isPublic"}},
                "organization.authenticatedPages": {relation: {entityName: "organization", refField: "authenticatedPages"}}
            },
            keyFields: ["orgAssetId"],
            joinMetadata: {organization: {entity: Organization, fieldName: "organization", refTable: "Organization", refColumns: ["orgId"], joinColumns: ["organizationOrgId"], 'type: psql:ONE_TO_MANY}}
        },
        [APPLICATION_PROPERTIES]: {
            entityName: "ApplicationProperties",
            tableName: "ApplicationProperties",
            fieldMetadata: {
                propertyId: {columnName: "propertyId"},
                name: {columnName: "name"},
                value: {columnName: "value"},
                applicationAppId: {columnName: "applicationAppId"},
                "application.appId": {relation: {entityName: "application", refField: "appId"}},
                "application.applicationName": {relation: {entityName: "application", refField: "applicationName"}},
                "application.sandBoxKey": {relation: {entityName: "application", refField: "sandBoxKey"}},
                "application.productionKey": {relation: {entityName: "application", refField: "productionKey"}},
                "application.addedAPIs": {relation: {entityName: "application", refField: "addedAPIs"}},
                "application.userName": {relation: {entityName: "application", refField: "userName"}},
                "application.idpId": {relation: {entityName: "application", refField: "idpId"}}
            },
            keyFields: ["propertyId"],
            joinMetadata: {application: {entity: Application, fieldName: "application", refTable: "Application", refColumns: ["appId"], joinColumns: ["applicationAppId"], 'type: psql:ONE_TO_MANY}}
        },
        [SUBSCRIPTION_PLAN_MAPPING]: {
            entityName: "SubscriptionPlanMapping",
            tableName: "SubscriptionPlanMapping",
            fieldMetadata: {
                mappingId: {columnName: "mappingId"},
                subscriptionplanSubscriptionPlanID: {columnName: "subscriptionplanSubscriptionPlanID"},
                subscriptionplanOrgId: {columnName: "subscriptionplanOrgId"},
                apimetadataApiId: {columnName: "apimetadataApiId"},
                apimetadataOrgId: {columnName: "apimetadataOrgId"},
                "subscriptionPlan.subscriptionPlanID": {relation: {entityName: "subscriptionPlan", refField: "subscriptionPlanID"}},
                "subscriptionPlan.policyName": {relation: {entityName: "subscriptionPlan", refField: "policyName"}},
                "subscriptionPlan.displayName": {relation: {entityName: "subscriptionPlan", refField: "displayName"}},
                "subscriptionPlan.description": {relation: {entityName: "subscriptionPlan", refField: "description"}},
                "subscriptionPlan.orgId": {relation: {entityName: "subscriptionPlan", refField: "orgId"}},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["mappingId"],
            joinMetadata: {
                subscriptionPlan: {entity: SubscriptionPlan, fieldName: "subscriptionPlan", refTable: "SubscriptionPlan", refColumns: ["subscriptionPlanID", "orgId"], joinColumns: ["subscriptionplanSubscriptionPlanID", "subscriptionplanOrgId"], 'type: psql:ONE_TO_MANY},
                apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apimetadataApiId", "apimetadataOrgId"], 'type: psql:ONE_TO_MANY}
            }
        },
        [SUBSCRIPTION_PLAN]: {
            entityName: "SubscriptionPlan",
            tableName: "SubscriptionPlan",
            fieldMetadata: {
                subscriptionPlanID: {columnName: "subscriptionPlanID"},
                policyName: {columnName: "policyName"},
                displayName: {columnName: "displayName"},
                description: {columnName: "description"},
                orgId: {columnName: "orgId"},
                "apis[].mappingId": {relation: {entityName: "apis", refField: "mappingId"}},
                "apis[].subscriptionplanSubscriptionPlanID": {relation: {entityName: "apis", refField: "subscriptionplanSubscriptionPlanID"}},
                "apis[].subscriptionplanOrgId": {relation: {entityName: "apis", refField: "subscriptionplanOrgId"}},
                "apis[].apimetadataApiId": {relation: {entityName: "apis", refField: "apimetadataApiId"}},
                "apis[].apimetadataOrgId": {relation: {entityName: "apis", refField: "apimetadataOrgId"}},
                "subscription.subscriptionId": {relation: {entityName: "subscription", refField: "subscriptionId"}},
                "subscription.userName": {relation: {entityName: "subscription", refField: "userName"}},
                "subscription.organizationOrgId": {relation: {entityName: "subscription", refField: "organizationOrgId"}},
                "subscription.subscriptionplanSubscriptionPlanID": {relation: {entityName: "subscription", refField: "subscriptionplanSubscriptionPlanID"}},
                "subscription.subscriptionplanOrgId": {relation: {entityName: "subscription", refField: "subscriptionplanOrgId"}},
                "subscription.apimetadataApiId": {relation: {entityName: "subscription", refField: "apimetadataApiId"}},
                "subscription.apimetadataOrgId": {relation: {entityName: "subscription", refField: "apimetadataOrgId"}}
            },
            keyFields: ["subscriptionPlanID", "orgId"],
            joinMetadata: {
                apis: {entity: SubscriptionPlanMapping, fieldName: "apis", refTable: "SubscriptionPlanMapping", refColumns: ["subscriptionplanSubscriptionPlanID", "subscriptionplanOrgId"], joinColumns: ["subscriptionPlanID", "orgId"], 'type: psql:MANY_TO_ONE},
                subscription: {entity: Subscription, fieldName: "subscription", refTable: "Subscription", refColumns: ["subscriptionplanSubscriptionPlanID", "subscriptionplanOrgId"], joinColumns: ["subscriptionPlanID", "orgId"], 'type: psql:ONE_TO_ONE}
            }
        },
        [SUBSCRIPTION]: {
            entityName: "Subscription",
            tableName: "Subscription",
            fieldMetadata: {
                subscriptionId: {columnName: "subscriptionId"},
                userName: {columnName: "userName"},
                organizationOrgId: {columnName: "organizationOrgId"},
                subscriptionplanSubscriptionPlanID: {columnName: "subscriptionplanSubscriptionPlanID"},
                subscriptionplanOrgId: {columnName: "subscriptionplanOrgId"},
                apimetadataApiId: {columnName: "apimetadataApiId"},
                apimetadataOrgId: {columnName: "apimetadataOrgId"},
                "organization.orgId": {relation: {entityName: "organization", refField: "orgId"}},
                "organization.organizationName": {relation: {entityName: "organization", refField: "organizationName"}},
                "organization.isPublic": {relation: {entityName: "organization", refField: "isPublic"}},
                "organization.authenticatedPages": {relation: {entityName: "organization", refField: "authenticatedPages"}},
                "subscriptionPlan.subscriptionPlanID": {relation: {entityName: "subscriptionPlan", refField: "subscriptionPlanID"}},
                "subscriptionPlan.policyName": {relation: {entityName: "subscriptionPlan", refField: "policyName"}},
                "subscriptionPlan.displayName": {relation: {entityName: "subscriptionPlan", refField: "displayName"}},
                "subscriptionPlan.description": {relation: {entityName: "subscriptionPlan", refField: "description"}},
                "subscriptionPlan.orgId": {relation: {entityName: "subscriptionPlan", refField: "orgId"}},
                "apimetadata.apiId": {relation: {entityName: "apimetadata", refField: "apiId"}},
                "apimetadata.orgId": {relation: {entityName: "apimetadata", refField: "orgId"}},
                "apimetadata.apiName": {relation: {entityName: "apimetadata", refField: "apiName"}},
                "apimetadata.metadata": {relation: {entityName: "apimetadata", refField: "metadata"}},
                "apimetadata.organizationName": {relation: {entityName: "apimetadata", refField: "organizationName"}},
                "apimetadata.apiCategory": {relation: {entityName: "apimetadata", refField: "apiCategory"}},
                "apimetadata.apiVersion": {relation: {entityName: "apimetadata", refField: "apiVersion"}},
                "apimetadata.apiDescription": {relation: {entityName: "apimetadata", refField: "apiDescription"}},
                "apimetadata.apiType": {relation: {entityName: "apimetadata", refField: "apiType"}},
                "apimetadata.tags": {relation: {entityName: "apimetadata", refField: "tags"}},
                "apimetadata.apiDefinition": {relation: {entityName: "apimetadata", refField: "apiDefinition"}},
                "apimetadata.productionUrl": {relation: {entityName: "apimetadata", refField: "productionUrl"}},
                "apimetadata.sandboxUrl": {relation: {entityName: "apimetadata", refField: "sandboxUrl"}},
                "apimetadata.authorizedRoles": {relation: {entityName: "apimetadata", refField: "authorizedRoles"}}
            },
            keyFields: ["subscriptionId"],
            joinMetadata: {
                organization: {entity: Organization, fieldName: "organization", refTable: "Organization", refColumns: ["orgId"], joinColumns: ["organizationOrgId"], 'type: psql:ONE_TO_MANY},
                subscriptionPlan: {entity: SubscriptionPlan, fieldName: "subscriptionPlan", refTable: "SubscriptionPlan", refColumns: ["subscriptionPlanID", "orgId"], joinColumns: ["subscriptionplanSubscriptionPlanID", "subscriptionplanOrgId"], 'type: psql:ONE_TO_ONE},
                apimetadata: {entity: ApiMetadata, fieldName: "apimetadata", refTable: "ApiMetadata", refColumns: ["apiId", "orgId"], joinColumns: ["apimetadataApiId", "apimetadataOrgId"], 'type: psql:ONE_TO_ONE}
            }
        }
    };

    public isolated function init() returns persist:Error? {
        postgresql:Client|error dbClient = new (host = host, username = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [THROTTLING_POLICY]: check new (dbClient, self.metadata.get(THROTTLING_POLICY), psql:POSTGRESQL_SPECIFICS),
            [API_METADATA]: check new (dbClient, self.metadata.get(API_METADATA), psql:POSTGRESQL_SPECIFICS),
            [API_CONTENT]: check new (dbClient, self.metadata.get(API_CONTENT), psql:POSTGRESQL_SPECIFICS),
            [API_IMAGES]: check new (dbClient, self.metadata.get(API_IMAGES), psql:POSTGRESQL_SPECIFICS),
            [ORG_IMAGES]: check new (dbClient, self.metadata.get(ORG_IMAGES), psql:POSTGRESQL_SPECIFICS),
            [ADDITIONAL_PROPERTIES]: check new (dbClient, self.metadata.get(ADDITIONAL_PROPERTIES), psql:POSTGRESQL_SPECIFICS),
            [IDENTITY_PROVIDER]: check new (dbClient, self.metadata.get(IDENTITY_PROVIDER), psql:POSTGRESQL_SPECIFICS),
            [APPLICATION]: check new (dbClient, self.metadata.get(APPLICATION), psql:POSTGRESQL_SPECIFICS),
            [ORGANIZATION]: check new (dbClient, self.metadata.get(ORGANIZATION), psql:POSTGRESQL_SPECIFICS),
            [ORGANIZATION_ASSETS]: check new (dbClient, self.metadata.get(ORGANIZATION_ASSETS), psql:POSTGRESQL_SPECIFICS),
            [APPLICATION_PROPERTIES]: check new (dbClient, self.metadata.get(APPLICATION_PROPERTIES), psql:POSTGRESQL_SPECIFICS),
            [SUBSCRIPTION_PLAN_MAPPING]: check new (dbClient, self.metadata.get(SUBSCRIPTION_PLAN_MAPPING), psql:POSTGRESQL_SPECIFICS),
            [SUBSCRIPTION_PLAN]: check new (dbClient, self.metadata.get(SUBSCRIPTION_PLAN), psql:POSTGRESQL_SPECIFICS),
            [SUBSCRIPTION]: check new (dbClient, self.metadata.get(SUBSCRIPTION), psql:POSTGRESQL_SPECIFICS)
        };
    }

    isolated resource function get throttlingpolicies(ThrottlingPolicyTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get throttlingpolicies/[string policyId](ThrottlingPolicyTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post throttlingpolicies(ThrottlingPolicyInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(THROTTLING_POLICY);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ThrottlingPolicyInsert inserted in data
            select inserted.policyId;
    }

    isolated resource function put throttlingpolicies/[string policyId](ThrottlingPolicyUpdate value) returns ThrottlingPolicy|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(THROTTLING_POLICY);
        }
        _ = check sqlClient.runUpdateQuery(policyId, value);
        return self->/throttlingpolicies/[policyId].get();
    }

    isolated resource function delete throttlingpolicies/[string policyId]() returns ThrottlingPolicy|persist:Error {
        ThrottlingPolicy result = check self->/throttlingpolicies/[policyId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(THROTTLING_POLICY);
        }
        _ = check sqlClient.runDeleteQuery(policyId);
        return result;
    }

    isolated resource function get apimetadata(ApiMetadataTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get apimetadata/[string apiId]/[string orgId](ApiMetadataTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post apimetadata(ApiMetadataInsert[] data) returns [string, string][]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApiMetadataInsert inserted in data
            select [inserted.apiId, inserted.orgId];
    }

    isolated resource function put apimetadata/[string apiId]/[string orgId](ApiMetadataUpdate value) returns ApiMetadata|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runUpdateQuery({"apiId": apiId, "orgId": orgId}, value);
        return self->/apimetadata/[apiId]/[orgId].get();
    }

    isolated resource function delete apimetadata/[string apiId]/[string orgId]() returns ApiMetadata|persist:Error {
        ApiMetadata result = check self->/apimetadata/[apiId]/[orgId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_METADATA);
        }
        _ = check sqlClient.runDeleteQuery({"apiId": apiId, "orgId": orgId});
        return result;
    }

    isolated resource function get apicontents(ApiContentTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get apicontents/[string apiContentId](ApiContentTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post apicontents(ApiContentInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_CONTENT);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApiContentInsert inserted in data
            select inserted.apiContentId;
    }

    isolated resource function put apicontents/[string apiContentId](ApiContentUpdate value) returns ApiContent|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_CONTENT);
        }
        _ = check sqlClient.runUpdateQuery(apiContentId, value);
        return self->/apicontents/[apiContentId].get();
    }

    isolated resource function delete apicontents/[string apiContentId]() returns ApiContent|persist:Error {
        ApiContent result = check self->/apicontents/[apiContentId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_CONTENT);
        }
        _ = check sqlClient.runDeleteQuery(apiContentId);
        return result;
    }

    isolated resource function get apiimages(ApiImagesTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get apiimages/[string imageTag]/[string apiId]/[string orgId](ApiImagesTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post apiimages(ApiImagesInsert[] data) returns [string, string, string][]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_IMAGES);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApiImagesInsert inserted in data
            select [inserted.imageTag, inserted.apiId, inserted.orgId];
    }

    isolated resource function put apiimages/[string imageTag]/[string apiId]/[string orgId](ApiImagesUpdate value) returns ApiImages|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_IMAGES);
        }
        _ = check sqlClient.runUpdateQuery({"imageTag": imageTag, "apiId": apiId, "orgId": orgId}, value);
        return self->/apiimages/[imageTag]/[apiId]/[orgId].get();
    }

    isolated resource function delete apiimages/[string imageTag]/[string apiId]/[string orgId]() returns ApiImages|persist:Error {
        ApiImages result = check self->/apiimages/[imageTag]/[apiId]/[orgId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(API_IMAGES);
        }
        _ = check sqlClient.runDeleteQuery({"imageTag": imageTag, "apiId": apiId, "orgId": orgId});
        return result;
    }

    isolated resource function get orgimages(OrgImagesTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get orgimages/[string orgId]/[string fileName](OrgImagesTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post orgimages(OrgImagesInsert[] data) returns [string, string][]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_IMAGES);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from OrgImagesInsert inserted in data
            select [inserted.orgId, inserted.fileName];
    }

    isolated resource function put orgimages/[string orgId]/[string fileName](OrgImagesUpdate value) returns OrgImages|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_IMAGES);
        }
        _ = check sqlClient.runUpdateQuery({"orgId": orgId, "fileName": fileName}, value);
        return self->/orgimages/[orgId]/[fileName].get();
    }

    isolated resource function delete orgimages/[string orgId]/[string fileName]() returns OrgImages|persist:Error {
        OrgImages result = check self->/orgimages/[orgId]/[fileName].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_IMAGES);
        }
        _ = check sqlClient.runDeleteQuery({"orgId": orgId, "fileName": fileName});
        return result;
    }

    isolated resource function get additionalproperties(AdditionalPropertiesTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get additionalproperties/[string apiId]/[string orgId]/[string key](AdditionalPropertiesTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post additionalproperties(AdditionalPropertiesInsert[] data) returns [string, string, string][]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ADDITIONAL_PROPERTIES);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from AdditionalPropertiesInsert inserted in data
            select [inserted.apiId, inserted.orgId, inserted.key];
    }

    isolated resource function put additionalproperties/[string apiId]/[string orgId]/[string key](AdditionalPropertiesUpdate value) returns AdditionalProperties|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ADDITIONAL_PROPERTIES);
        }
        _ = check sqlClient.runUpdateQuery({"apiId": apiId, "orgId": orgId, "key": key}, value);
        return self->/additionalproperties/[apiId]/[orgId]/[key].get();
    }

    isolated resource function delete additionalproperties/[string apiId]/[string orgId]/[string key]() returns AdditionalProperties|persist:Error {
        AdditionalProperties result = check self->/additionalproperties/[apiId]/[orgId]/[key].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ADDITIONAL_PROPERTIES);
        }
        _ = check sqlClient.runDeleteQuery({"apiId": apiId, "orgId": orgId, "key": key});
        return result;
    }

    isolated resource function get identityproviders(IdentityProviderTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get identityproviders/[string idpId](IdentityProviderTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post identityproviders(IdentityProviderInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(IDENTITY_PROVIDER);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from IdentityProviderInsert inserted in data
            select inserted.idpId;
    }

    isolated resource function put identityproviders/[string idpId](IdentityProviderUpdate value) returns IdentityProvider|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(IDENTITY_PROVIDER);
        }
        _ = check sqlClient.runUpdateQuery(idpId, value);
        return self->/identityproviders/[idpId].get();
    }

    isolated resource function delete identityproviders/[string idpId]() returns IdentityProvider|persist:Error {
        IdentityProvider result = check self->/identityproviders/[idpId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(IDENTITY_PROVIDER);
        }
        _ = check sqlClient.runDeleteQuery(idpId);
        return result;
    }

    isolated resource function get applications(ApplicationTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get applications/[string appId](ApplicationTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post applications(ApplicationInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApplicationInsert inserted in data
            select inserted.appId;
    }

    isolated resource function put applications/[string appId](ApplicationUpdate value) returns Application|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION);
        }
        _ = check sqlClient.runUpdateQuery(appId, value);
        return self->/applications/[appId].get();
    }

    isolated resource function delete applications/[string appId]() returns Application|persist:Error {
        Application result = check self->/applications/[appId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION);
        }
        _ = check sqlClient.runDeleteQuery(appId);
        return result;
    }

    isolated resource function get organizations(OrganizationTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get organizations/[string orgId](OrganizationTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post organizations(OrganizationInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from OrganizationInsert inserted in data
            select inserted.orgId;
    }

    isolated resource function put organizations/[string orgId](OrganizationUpdate value) returns Organization|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION);
        }
        _ = check sqlClient.runUpdateQuery(orgId, value);
        return self->/organizations/[orgId].get();
    }

    isolated resource function delete organizations/[string orgId]() returns Organization|persist:Error {
        Organization result = check self->/organizations/[orgId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION);
        }
        _ = check sqlClient.runDeleteQuery(orgId);
        return result;
    }

    isolated resource function get organizationassets(OrganizationAssetsTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get organizationassets/[string orgAssetId](OrganizationAssetsTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post organizationassets(OrganizationAssetsInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION_ASSETS);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from OrganizationAssetsInsert inserted in data
            select inserted.orgAssetId;
    }

    isolated resource function put organizationassets/[string orgAssetId](OrganizationAssetsUpdate value) returns OrganizationAssets|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION_ASSETS);
        }
        _ = check sqlClient.runUpdateQuery(orgAssetId, value);
        return self->/organizationassets/[orgAssetId].get();
    }

    isolated resource function delete organizationassets/[string orgAssetId]() returns OrganizationAssets|persist:Error {
        OrganizationAssets result = check self->/organizationassets/[orgAssetId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORGANIZATION_ASSETS);
        }
        _ = check sqlClient.runDeleteQuery(orgAssetId);
        return result;
    }

    isolated resource function get applicationproperties(ApplicationPropertiesTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get applicationproperties/[string propertyId](ApplicationPropertiesTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post applicationproperties(ApplicationPropertiesInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION_PROPERTIES);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from ApplicationPropertiesInsert inserted in data
            select inserted.propertyId;
    }

    isolated resource function put applicationproperties/[string propertyId](ApplicationPropertiesUpdate value) returns ApplicationProperties|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION_PROPERTIES);
        }
        _ = check sqlClient.runUpdateQuery(propertyId, value);
        return self->/applicationproperties/[propertyId].get();
    }

    isolated resource function delete applicationproperties/[string propertyId]() returns ApplicationProperties|persist:Error {
        ApplicationProperties result = check self->/applicationproperties/[propertyId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(APPLICATION_PROPERTIES);
        }
        _ = check sqlClient.runDeleteQuery(propertyId);
        return result;
    }

    isolated resource function get subscriptionplanmappings(SubscriptionPlanMappingTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get subscriptionplanmappings/[string mappingId](SubscriptionPlanMappingTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post subscriptionplanmappings(SubscriptionPlanMappingInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN_MAPPING);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from SubscriptionPlanMappingInsert inserted in data
            select inserted.mappingId;
    }

    isolated resource function put subscriptionplanmappings/[string mappingId](SubscriptionPlanMappingUpdate value) returns SubscriptionPlanMapping|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN_MAPPING);
        }
        _ = check sqlClient.runUpdateQuery(mappingId, value);
        return self->/subscriptionplanmappings/[mappingId].get();
    }

    isolated resource function delete subscriptionplanmappings/[string mappingId]() returns SubscriptionPlanMapping|persist:Error {
        SubscriptionPlanMapping result = check self->/subscriptionplanmappings/[mappingId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN_MAPPING);
        }
        _ = check sqlClient.runDeleteQuery(mappingId);
        return result;
    }

    isolated resource function get subscriptionplans(SubscriptionPlanTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get subscriptionplans/[string subscriptionPlanID]/[string orgId](SubscriptionPlanTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post subscriptionplans(SubscriptionPlanInsert[] data) returns [string, string][]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from SubscriptionPlanInsert inserted in data
            select [inserted.subscriptionPlanID, inserted.orgId];
    }

    isolated resource function put subscriptionplans/[string subscriptionPlanID]/[string orgId](SubscriptionPlanUpdate value) returns SubscriptionPlan|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN);
        }
        _ = check sqlClient.runUpdateQuery({"subscriptionPlanID": subscriptionPlanID, "orgId": orgId}, value);
        return self->/subscriptionplans/[subscriptionPlanID]/[orgId].get();
    }

    isolated resource function delete subscriptionplans/[string subscriptionPlanID]/[string orgId]() returns SubscriptionPlan|persist:Error {
        SubscriptionPlan result = check self->/subscriptionplans/[subscriptionPlanID]/[orgId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION_PLAN);
        }
        _ = check sqlClient.runDeleteQuery({"subscriptionPlanID": subscriptionPlanID, "orgId": orgId});
        return result;
    }

    isolated resource function get subscriptions(SubscriptionTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get subscriptions/[string subscriptionId](SubscriptionTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post subscriptions(SubscriptionInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from SubscriptionInsert inserted in data
            select inserted.subscriptionId;
    }

    isolated resource function put subscriptions/[string subscriptionId](SubscriptionUpdate value) returns Subscription|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runUpdateQuery(subscriptionId, value);
        return self->/subscriptions/[subscriptionId].get();
    }

    isolated resource function delete subscriptions/[string subscriptionId]() returns Subscription|persist:Error {
        Subscription result = check self->/subscriptions/[subscriptionId].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(SUBSCRIPTION);
        }
        _ = check sqlClient.runDeleteQuery(subscriptionId);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

