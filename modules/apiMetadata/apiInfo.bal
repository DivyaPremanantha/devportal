public distinct service class ApiInformation {
    private final readonly & ApiInfoEntry entryRecord;

    public function init(ApiInfoEntry entryRecord) {
        self.entryRecord = entryRecord.cloneReadOnly();
    }

    resource function get apiCategory() returns string {
        return self.entryRecord.apiCategory;
    }
    resource function get apiDocumentation() returns string {
        return self.entryRecord.apiDocumentation;
    }
    resource function get apiImage() returns string? {
        return self.entryRecord.apiImage;
    }
}