import devportal.models;
import devportal.store;

import ballerina/graphql;
import ballerina/persist;
import ballerina/uuid;

final store:Client userClient = check new ();

service /apiUserPortal on new graphql:Listener(4000) {

    # Retrieve the details for an API.
    #
    # + apiID - parameter description
    # + return - meta data related to the API
    resource function get apiMetaData(string apiID) returns models:ApiMetadata|error {

        store:ApiMetadataWithRelations apiMetaData = check userClient->/apimetadata/[apiID].get();
        store:ThrottlingPolicyOptionalized[] policies = apiMetaData.throttlingPolicies ?: [];
        store:AdditionalPropertiesOptionalized[] additionalProperties = apiMetaData.additionalProperties ?: [];

        models:ThrottlingPolicy[] throttlingPolicies = [];
        foreach var policy in policies {
            models:ThrottlingPolicy policyData = {
                policyName: policy.policyName ?: "",
                description: policy.description ?: "",
                'type: policy.'type ?: ""
            };
            throttlingPolicies.push(policyData);
        }

        map<string> properties = {};
        foreach var property in additionalProperties {
            properties[property.key ?: ""] = property.value ?: "";
        }

        models:ApiMetadata metaData = {
            serverUrl:
                            {
                sandboxUrl: apiMetaData.sandboxUrl ?: "",
                productionUrl: apiMetaData.productionUrl ?: ""
            },
            throttlingPolicies: throttlingPolicies,
            apiInfo: {
                apiName: apiMetaData.apiName ?: "",
                apiCategory: apiMetaData.apiCategory ?: [],
                openApiDefinition: apiMetaData.openApiDefinition ?: "",
                additionalProperties: properties
            }
        };

        return metaData;
    }

    # Filter the APIs using category or a keyword/s.
    #
    # + orgId - parameter description  
    # + category - parameter description
    # + return - return value description
    resource function get apiFilter(string orgId, string category, string? keywords) returns models:ApiMetadata[]|error {

        stream<store:ApiMetadataWithRelations, persist:Error?> apiData = userClient->/apimetadata.get();
        models:ApiMetadata[] filteredData = [];
        store:ApiMetadataWithRelations[] metaDataList = check from var apiMetadata in apiData
            select apiMetadata;

        foreach var api in metaDataList {
            foreach var item in api.apiCategory ?: [] {
                if (category.equalsIgnoreCaseAscii(item)) {

                    store:ThrottlingPolicyOptionalized[] policies = api.throttlingPolicies ?: [];
                    models:ThrottlingPolicy[] throttlingPolicies = [];
                    foreach var policy in policies {
                        models:ThrottlingPolicy policyData = {
                            policyName: policy.policyName ?: "",
                            description: policy.description ?: "",
                            'type: policy.'type ?: ""
                        };
                        throttlingPolicies.push(policyData);

                    }
                    store:AdditionalPropertiesOptionalized[] additionalProperties = api.additionalProperties ?: [];
                    map<string> properties = {};
                    foreach var property in additionalProperties {
                        properties[property.key ?: ""] = property.value ?: "";
                    }
                    models:ApiMetadata metaData = {
                        serverUrl:
                            {
                            sandboxUrl: api.sandboxUrl ?: "",
                            productionUrl: api.productionUrl ?: ""
                        },
                        throttlingPolicies: throttlingPolicies,
                        apiInfo: {
                            apiName: api.apiName ?: "",
                            apiCategory: api.apiCategory ?: [],
                            openApiDefinition: api.openApiDefinition ?: "",
                            additionalProperties: properties
                        }
                    };
                    filteredData.push(metaData);
                }
            }
        }
        return filteredData;
    }

    # Create an application.
    #
    # + application - parameter description
    # + return - return value description
    remote function addApplicationDetails(models:Application application) returns models:ApplicationResponse|error {

        store:User[] user = [];
        store:ApplicationProperties[] appProperties = [];
        string applicationId = uuid:createType1AsString();
        foreach var createdUser in application.accessControl {
            user.push({
                userId: uuid:createType1AsString(),
                role: createdUser.role,
                userName: createdUser.userName,
                applicationAppId: applicationId
            });
        }
        foreach var property in application.appProperties {
            appProperties.push({
                name: property.name,
                value: property.value,
                applicationAppId: applicationId,
                propertyId: uuid:createType1AsString()
            });
        }

        store:Application app = {
            addedAPIs: application.addedAPIs,
            appId: applicationId,
            applicationName: application.applicationName,
            productionKey: application.productionKey,
            sandBoxKey: application.sandBoxKey,
            idpId: application.idpId
        };

        string[] listResult = check userClient->/applications.post([app]);
        return new (application);
    }

    # Retrieve application details.
    #
    # + appId - parameter description
    # + return - return value description
    resource function get applications(string appId) returns models:ApplicationResponse|error {

        store:ApplicationWithRelations application = check userClient->/applications/[appId].get();
        store:UserOptionalized[] users = application.accessControl ?: [];
        models:User[] userList = [];
        foreach var user in users {
            userList.push({
                role: user.role ?: "",
                userName: user.userName ?: ""
            });
        }
        store:ApplicationPropertiesOptionalized[] properties = application.appProperties ?: [];
        models:ApplicationProperties[] appProperties = [];
        foreach var property in properties {
            appProperties.push({
                name: property.name ?: "",
                value: property.value ?: ""
            });
        }
        models:Application app = {
            accessControl: userList,
            productionKey: "",
            addedAPIs: [],
            appId: application.productionKey ?: "",
            sandBoxKey: application.sandBoxKey ?: "",
            applicationName: application.applicationName ?: "",
            appProperties: appProperties,
            idpId: application.idpId ?: ""
        };
        return new (app);
    }

    # Add a subscription.
    #
    # + subscription - parameter description
    # + return - return value description
    remote function subscription(models:APISubscription subscription) returns models:SubscriptionResponse|error {

        string subscriptionId = uuid:createType1AsString();

        store:Subscription storeSubscription = {
            apiId: subscription.apiId,
            orgId: subscription.orgId,
            subscriptionId: subscriptionId,
            userId: subscription.userId
        };

        string[] listResult = check userClient->/subscriptions.post([storeSubscription]);
        return new (subscription);
    }

    # Retrieve consumer specific component details.
    #
    # + userId - user identifier
    # + return - all subscribed APIs
    resource function get subscriptions(string userId) returns models:SubscriptionResponse[]|error {

        stream<store:Subscription , persist:Error?>  subscription =   userClient->/subscriptions.get();
          store:Subscription[] subscribedAPIs = check from var sub in subscription where sub.userId == userId select sub;
            models:SubscriptionResponse[] subscriptionResponse = [];
            foreach var sub in subscribedAPIs {
                subscriptionResponse.push(new(sub));
            }
        return subscriptionResponse;
    }

    # Add a consumer review.
    #
    # + review - parameter description
    # + return - return value description
    remote function review(models:ConsumerReview review) returns models:ConsumerReviewResponse|error {

        string reviewId = uuid:createType1AsString();

        store:ConsumerReview consumerReview = {
            apiId: review.apiId,
            userId: review.userId,
            rating: review.rating,
            comment: review.comment,
            reviewId: reviewId
        };

        string[] listResult = check userClient->/consumerreviews.post([consumerReview]);
        return new (review);
    }

    # Retrieve reviews.
    #
    # + apiId - api identifier 
    # + return - list of reviews for the api.
    resource function get reviews(string apiId) returns models:ConsumerReviewResponse[]|error {

        stream<store:ConsumerReview, persist:Error?> reviews = userClient->/consumerreviews.get();
        store:ConsumerReview[] selectedReviews = check from var review in reviews
            where review.apiId == apiId
            select review;

        models:ConsumerReviewResponse[] reviewResponse = [];

        foreach var review in selectedReviews {
            reviewResponse.push(new (review));
        }
        return reviewResponse;
    }
}