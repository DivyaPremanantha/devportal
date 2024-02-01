// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

public type ThrottlingPolicy record {|
    readonly string policyId;
    string 'type;
    string policyName;
    string description;
    string apimetadataApiId;
|};

public type ThrottlingPolicyOptionalized record {|
    string policyId?;
    string 'type?;
    string policyName?;
    string description?;
    string apimetadataApiId?;
|};

public type ThrottlingPolicyWithRelations record {|
    *ThrottlingPolicyOptionalized;
    ApiMetadataOptionalized apimetadata?;
|};

public type ThrottlingPolicyTargetType typedesc<ThrottlingPolicyWithRelations>;

public type ThrottlingPolicyInsert ThrottlingPolicy;

public type ThrottlingPolicyUpdate record {|
    string 'type?;
    string policyName?;
    string description?;
    string apimetadataApiId?;
|};

public type RateLimitingPolicy record {|
    readonly string policyId;
    string policyName;
    string policyInfo;
|};

public type RateLimitingPolicyOptionalized record {|
    string policyId?;
    string policyName?;
    string policyInfo?;
|};

public type RateLimitingPolicyTargetType typedesc<RateLimitingPolicyOptionalized>;

public type RateLimitingPolicyInsert RateLimitingPolicy;

public type RateLimitingPolicyUpdate record {|
    string policyName?;
    string policyInfo?;
|};

public type Feedback record {|
    readonly string apiId;
    int noOfRating;
    int noOfComments;
    string apimetadataApiId;
|};

public type FeedbackOptionalized record {|
    string apiId?;
    int noOfRating?;
    int noOfComments?;
    string apimetadataApiId?;
|};

public type FeedbackWithRelations record {|
    *FeedbackOptionalized;
    ReviewOptionalized[] reviews?;
    ApiMetadataOptionalized apimetadata?;
|};

public type FeedbackTargetType typedesc<FeedbackWithRelations>;

public type FeedbackInsert Feedback;

public type FeedbackUpdate record {|
    int noOfRating?;
    int noOfComments?;
    string apimetadataApiId?;
|};

public type Review record {|
    readonly string reviewId;
    string reviewedBy;
    int rating;
    string comment;
    string feedbackApiId;
|};

public type ReviewOptionalized record {|
    string reviewId?;
    string reviewedBy?;
    int rating?;
    string comment?;
    string feedbackApiId?;
|};

public type ReviewWithRelations record {|
    *ReviewOptionalized;
    FeedbackOptionalized feedback?;
|};

public type ReviewTargetType typedesc<ReviewWithRelations>;

public type ReviewInsert Review;

public type ReviewUpdate record {|
    string reviewedBy?;
    int rating?;
    string comment?;
    string feedbackApiId?;
|};

public type ApiMetadata record {|
    readonly string apiId;
    string orgId;
    string apiName;
    string[] apiCategory;
    string? apiImage;
    string openApiDefinition;
    string productionUrl;
    string sandboxUrl;
|};

public type ApiMetadataOptionalized record {|
    string apiId?;
    string orgId?;
    string apiName?;
    string[] apiCategory?;
    string? apiImage?;
    string openApiDefinition?;
    string productionUrl?;
    string sandboxUrl?;
|};

public type ApiMetadataWithRelations record {|
    *ApiMetadataOptionalized;
    AdditionalPropertiesOptionalized[] additionalProperties?;
    ThrottlingPolicyOptionalized[] throttlingPolicies?;
    FeedbackOptionalized feedback?;
|};

public type ApiMetadataTargetType typedesc<ApiMetadataWithRelations>;

public type ApiMetadataInsert ApiMetadata;

public type ApiMetadataUpdate record {|
    string orgId?;
    string apiName?;
    string[] apiCategory?;
    string? apiImage?;
    string openApiDefinition?;
    string productionUrl?;
    string sandboxUrl?;
|};

public type AdditionalProperties record {|
    readonly string propertyId;
    string key;
    string value;
    string apimetadataApiId;
|};

public type AdditionalPropertiesOptionalized record {|
    string propertyId?;
    string key?;
    string value?;
    string apimetadataApiId?;
|};

public type AdditionalPropertiesWithRelations record {|
    *AdditionalPropertiesOptionalized;
    ApiMetadataOptionalized apimetadata?;
|};

public type AdditionalPropertiesTargetType typedesc<AdditionalPropertiesWithRelations>;

public type AdditionalPropertiesInsert AdditionalProperties;

public type AdditionalPropertiesUpdate record {|
    string key?;
    string value?;
    string apimetadataApiId?;
|};
