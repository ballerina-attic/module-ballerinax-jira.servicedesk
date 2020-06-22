// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;
import ballerina/lang.'int;

// Validates the http:Response received
function validateResponse(http:Response response) returns json|error {
    int statusCode = response.statusCode;
    json|error jsonPayload = <@untainted>response.getJsonPayload();
    if (statusCode == http:STATUS_OK || statusCode == http:STATUS_NO_CONTENT || statusCode == http:STATUS_CREATED) {
        return jsonPayload;
    }
    return createError(HTTP_ERROR_CODE, jsonPayload.toString());
}

// Validates the response code
function validateResponseCode(http:Response response) returns error? {
    int statusCode = response.statusCode;
    if (statusCode == http:STATUS_OK || statusCode == http:STATUS_NO_CONTENT || statusCode == http:STATUS_CREATED) {
        return;
    }
    json|error jsonPayload = <@untainted>response.getJsonPayload();
    if (jsonPayload is error) {
        return jsonPayload;
    } else {
        return createError(HTTP_ERROR_CODE, jsonPayload.toString());
    }
}

// Creates an error
function createError(string reason, string message) returns error {
    return error(reason + ": " + message);
}

// Creates the path with the given query params
function getPath(string path, string query, string value) returns string {
    if (path.indexOf("?", 0) == ()) {
        return path + QUESTION_MARK + query + EQUAL + value;
    } else {
        return path + AMPERSAND + query + EQUAL + value;
    }
}

// Creates an array of `Organization`
function createOrganizationArray(json jsonPayload, http:Client jiraClient) returns Organization[]|error {
    Organization[]|error organizations = [];
    json|error organizationJson = jsonPayload.values;
    if (organizationJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the organizations");
    } else {
        organizations = convertToOrganizations(<json[]>jsonPayload.values, jiraClient);
    }
    return organizations;
}

// Converts a json array to `Organization` objects
function convertToOrganizations(json[] jsonPayload, http:Client jiraClient) returns Organization[]|error {
    int i = 0;
    Organization[] organizations = [];
    foreach json organizationJson in jsonPayload {
        Organization|error organization = convertToOrganization(organizationJson, jiraClient);
        if (organization is Organization) {
            organizations[i] = organization;
            i = i + 1;
        } else {
            return organization;
        }
    }
    return organizations;
}

// Converts a json to a `Organization` object
function convertToOrganization(json jsonPayload, http:Client jiraClient) returns Organization|error {
    json idVal = checkpanic jsonPayload.id;
    int id = checkpanic 'int:fromString(idVal.toString());
    json name = checkpanic jsonPayload.name;
    OrganizationProperties orgProperties = {
        id: id,
        name: name.toString()
    };
    Organization organization = new (jiraClient, orgProperties);
    return organization;
}

// Creates an array of `ServiceDesk`
function createServiceDeskArray(json jsonPayload, http:Client jiraClient) returns ServiceDesk[]|error {
    ServiceDesk[]|error serviceDesks = [];
    json|error serviceDeskJson = jsonPayload.values;
    if (serviceDeskJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the service desks");
    } else {
        serviceDesks = convertToServiDesks(<json[]>jsonPayload.values, jiraClient);
    }
    return serviceDesks;
}

// Converts a json array to `ServiceDesk` objects
function convertToServiDesks(json[] jsonPayload, http:Client jiraClient) returns ServiceDesk[]|error {
    int i = 0;
    ServiceDesk[] serviceDesks = [];
    foreach json jsonServiceDesk in jsonPayload {
        ServiceDesk|error serviceDesk = convertToServiceDesk(jsonServiceDesk, jiraClient);
        if (serviceDesk is ServiceDesk) {
            serviceDesks[i] = serviceDesk;
            i = i + 1;
        } else {
            return serviceDesk;
        }
    }
    return serviceDesks;
}

// Converts a json to a `ServiceDesk` object
function convertToServiceDesk(json jsonPayload, http:Client jiraClient) returns ServiceDesk {
    json idVal = checkpanic jsonPayload.id;
    int id = checkpanic 'int:fromString(idVal.toString());
    json projectIdVal = checkpanic jsonPayload.projectId;
    int projectId = checkpanic 'int:fromString(projectIdVal.toString());
    json projectName = checkpanic jsonPayload.projectName;
    json projectKey = checkpanic jsonPayload.projectKey;
    ServiceDeskProperties properties = {
        id: id,
        projectId: projectId,
        projectName: projectName.toString(),
        projectKey: projectKey.toString()
    };
    ServiceDesk serviceDesk = new (jiraClient, properties);
    return serviceDesk;
}

// Creates an array of `Issue`
function createIssueArray(json jsonPayload) returns Issue[]|error {
    Issue[]|error issues = [];
    json|error issueJson = jsonPayload.values;
    if (issueJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the issues");
    } else {
        issues = convertToIssues(<json[]>jsonPayload.values);
    }
    return issues;
}

// Converts a json array to `Issue` records
function convertToIssues(json[] jsonPayload) returns Issue[]|error {
    int i = 0;
    Issue[] issues = [];
    foreach json jsonIssue in jsonPayload {
        Issue|error issue = convertToIssue(jsonIssue);
        if (issue is Issue) {
            issues[i] = issue;
            i = i + 1;
        } else {
            return issue;
        }
    }
    return issues;
}

// Converts a json to an `Issue` record
function convertToIssue(json jsonPayload) returns Issue {
    string summary = "";
    json issueId = checkpanic jsonPayload.issueId;
    json[] requestFieldValues = <json[]>jsonPayload.requestFieldValues;
    foreach json fieldJson in requestFieldValues {
        string fieldName = fieldJson.fieldId.toString();
        if (fieldName == "summary") {
            summary = fieldJson.value.toString();
        }
    }
    json issueKey = checkpanic jsonPayload.issueKey;
    json requestTypeId = checkpanic jsonPayload.requestTypeId;
    json createdDate = checkpanic jsonPayload.createdDate.friendly;
    json reporterName = checkpanic jsonPayload.reporter.displayName;
    json status = checkpanic jsonPayload.currentStatus.status;
    IssueType issueType = {id: requestTypeId.toString()};
    Issue issue = {
        id: issueId.toString(),
        summary: summary,
        key: issueKey.toString(),
        statusId: status.toString(),
        reporterName: reporterName.toString(),
        createdDate: createdDate.toString(),
        issueType: issueType
    };
    return issue;
}
// Creates an array of `Issue`
function createIssuesInQueueArray(json jsonPayload) returns Issue[]|error {
    Issue[]|error issues = [];
    json|error issueJson = jsonPayload.values;
    if (issueJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the issues");
    } else {
        issues = convertToIssuesInQueue(<json[]>jsonPayload.values);
    }
    return issues;
}

// Converts a json array to `Issue` records
function convertToIssuesInQueue(json[] jsonPayload) returns Issue[]|error {
    int i = 0;
    Issue[] issues = [];
    foreach json jsonIssue in jsonPayload {
        Issue|error issue = convertToIssueInQueue(jsonIssue);
        if (issue is Issue) {
            issues[i] = issue;
            i = i + 1;
        } else {
            return issue;
        }
    }
    return issues;
}

// Converts a json to an `Issue` record
function convertToIssueInQueue(json jsonPayload) returns Issue {
    json issueId = checkpanic jsonPayload.id;
    json issueKey = checkpanic jsonPayload.key;
    json summary = checkpanic jsonPayload.fields.summary;
    json requestTypeId = checkpanic jsonPayload.fields.issuetype.id;
    json createdDate = checkpanic jsonPayload.fields.created;
    json reporterName = checkpanic jsonPayload.fields.reporter.displayName;
    json status = checkpanic jsonPayload.fields.status.name;
    IssueType issueType = {id: requestTypeId.toString()};
    Issue issue = {
        id: issueId.toString(),
        summary: summary.toString(),
        key: issueKey.toString(),
        statusId: status.toString(),
        reporterName: reporterName.toString(),
        createdDate: createdDate.toString(),
        issueType: issueType
    };
    return issue;
}

// Creates an array of `SlaInformation`
function createSlaInformationArray(json jsonPayload) returns SlaInformation[]|error {
    SlaInformation[]|error slaInfo = [];
    json|error slaJson = jsonPayload.values;
    if (slaJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the sla information");
    } else {
        slaInfo = convertToSlaInformationArray(<json[]>jsonPayload.values);
    }
    return slaInfo;
}

// Converts a json array to `SlaInformation` records
function convertToSlaInformationArray(json[] jsonPayload) returns SlaInformation[]|error {
    int i = 0;
    SlaInformation[] slaInfoArray = [];
    foreach json slaJson in jsonPayload {
        SlaInformation|error sla = convertToSlaInformation(slaJson);
        if (sla is SlaInformation) {
            slaInfoArray[i] = sla;
            i = i + 1;
        } else {
            return sla;
        }
    }
    return slaInfoArray;
}

// Converts a json to a `SlaInformation` record
function convertToSlaInformation(json jsonPayload) returns SlaInformation {
    json idVal = checkpanic jsonPayload.id;
    int id = checkpanic 'int:fromString(idVal.toString());
    json name = checkpanic jsonPayload.name;
    json completedCyclesJson = checkpanic jsonPayload.completedCycles;
    json ongoingCycleJson = checkpanic jsonPayload.ongoingCycle;
    SlaCycle[] completeCycles = convertToSlaCycles(<json[]>completedCyclesJson);
    SlaCycle ongoingCycle = convertToSlACycle(ongoingCycleJson);
    SlaInformation slaInfo = {
        id: id,
        name: name.toString(),
        completedCycles: completeCycles,
        ongoingCycle: ongoingCycle
    };
    return slaInfo;
}

// Converts a json array to `SlaCycle` records
function convertToSlaCycles(json[] jsonPayload) returns SlaCycle[] {
    int i = 0;
    SlaCycle[] cycles = [];
    foreach json jsonCycle in jsonPayload {
        SlaCycle|error cycle = convertToSlACycle(jsonCycle);
        if (cycle is SlaCycle) {
            cycles[i] = cycle;
            i = i + 1;
        } else {
            panic cycle;
        }
    }
    return cycles;
}

// Converts a json to a `SlaCycle` record
function convertToSlACycle(json jsonPayload) returns SlaCycle {
    json startTime = checkpanic jsonPayload.startTime.friendly;
    json breachTime = checkpanic jsonPayload.breachTime.friendly;
    json breachedVal = checkpanic jsonPayload.breached;
    json goalDuration = checkpanic jsonPayload.goalDuration.millis;
    int goalDurationInMillis = checkpanic 'int:fromString(goalDuration.toString());
    json elapsedTime = checkpanic jsonPayload.elapsedTime.millis;
    int elapsedTimeInMillis = checkpanic 'int:fromString(elapsedTime.toString());
    json remainingTime = checkpanic jsonPayload.remainingTime.millis;
    int remainingTimeInMillis = checkpanic 'int:fromString(remainingTime.toString());
    boolean breached = breachedVal.toString() == "true" ? true : false;
    SlaCycle cycle = {
        startTime: startTime.toString(),
        breachTime: breachTime.toString(),
        goalDurationInMillis: goalDurationInMillis,
        elapsedTimeInMillis: elapsedTimeInMillis,
        remainingTimeInMillis: remainingTimeInMillis,
        breached: breached
    };
    return cycle;
}

// Creates an array of `User`
function createUserArray(json jsonPayload) returns User[]|error {
    User[]|error users = [];
    json|error usersJson = jsonPayload.values;
    if (usersJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the users");
    } else {
        users = convertToUsers(<json[]>jsonPayload.values);
    }
    return users;
}

// Converts a json array to `User` records
function convertToUsers(json[] jsonPayload) returns User[]|error {
    int i = 0;
    User[] users = [];
    foreach json jsonUser in jsonPayload {
        User|error user = convertToUser(jsonUser);
        if (user is User) {
            users[i] = user;
            i = i + 1;
        } else {
            return user;
        }
    }
    return users;
}

// Converts a json to a `User` record
function convertToUser(json jsonPayload) returns User {
    json accountId = checkpanic jsonPayload.accountId;
    json emailAddress = checkpanic jsonPayload.emailAddress;
    json displayName = checkpanic jsonPayload.displayName;
    json active = checkpanic jsonPayload.active;
    json timeZone = checkpanic jsonPayload.timeZone;
    User user = {
        accountId: accountId.toString(),
        emailAddress: emailAddress.toString(),
        displayName: displayName.toString(),
        active: <boolean>active,
        timeZone: timeZone.toString()
    };
    return user;
}

// Creates an array of `Comment`
function createCommentArray(json jsonPayload) returns Comment[]|error {
    Comment[]|error comments = [];
    json|error commentsJson = jsonPayload.values;
    if (commentsJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the comments");
    } else {
        comments = convertToComments(<json[]>jsonPayload.values);
    }
    return comments;
}

// Converts a json array to `Comment` records
function convertToComments(json[] jsonPayload) returns Comment[]|error {
    int i = 0;
    Comment[] comments = [];
    foreach json jsonComment in jsonPayload {
        Comment|error comment = convertToComment(jsonComment);
        if (comment is Comment) {
            comments[i] = comment;
            i = i + 1;
        } else {
            return comment;
        }
    }
    return comments;
}

// Converts a json to a `Comment` record
function convertToComment(json jsonPayload) returns Comment {
    json id = checkpanic jsonPayload.id;
    json name = checkpanic jsonPayload.author.displayName;
    json authorId = checkpanic jsonPayload.author.accountId;
    json body = checkpanic jsonPayload.body;
    json createdDate = checkpanic jsonPayload.created.friendly;
    Comment comment = {
        id: id.toString(),
        authorName: name.toString(),
        authorKey: authorId.toString(),
        body: body.toString(),
        updatedDate: createdDate.toString()
    };
    return comment;
}

// Creates an array of `Queue`
function createQueueArray(json jsonPayload, boolean includeCount) returns Queue[]|error {
    Queue[]|error queues = [];
    json|error queueJson = jsonPayload.values;
    if (queueJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the queues");
    } else {
        queues = convertToQueues(<json[]>jsonPayload.values, includeCount);
    }
    return queues;
}

// Converts a json array to `Queue` records
function convertToQueues(json[] jsonPayload, boolean includeCount) returns Queue[]|error {
    int i = 0;
    Queue[] queues = [];
    foreach json jsonQueue in jsonPayload {
        Queue|error queue = convertToQueue(jsonQueue, includeCount);
        if (queue is Queue) {
            queues[i] = queue;
            i = i + 1;
        } else {
            return queue;
        }
    }
    return queues;
}

// Converts a json to a `Queue` record
function convertToQueue(json jsonPayload, boolean includeCount) returns Queue {
    int issueCount = 0;
    json idVal = checkpanic jsonPayload.id;
    int id = checkpanic 'int:fromString(idVal.toString());
    json name = checkpanic jsonPayload.name;
    if (includeCount) {
        json count = checkpanic jsonPayload.issueCount;
        issueCount = checkpanic 'int:fromString(count.toString());
    }
    Queue queue = {
        id: id,
        name: name.toString(),
        issueCount: issueCount
    };
    return queue;
}

// Creates an array of `IssueType`
function createIssueTypeArray(json jsonPayload) returns IssueType[]|error {
    IssueType[]|error types = [];
    json|error typesJson = jsonPayload.values;
    if (typesJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the issue types");
    } else {
        types = convertToIssueTypes(<json[]>jsonPayload.values);
    }
    return types;
}

// Converts a json array to `IssueType` records
function convertToIssueTypes(json[] jsonPayload) returns IssueType[]|error {
    int i = 0;
    IssueType[] issueTypes = [];
    foreach json jsonType in jsonPayload {
        IssueType|error issueType = convertToIssueType(jsonType);
        if (issueType is IssueType) {
            issueTypes[i] = issueType;
            i = i + 1;
        } else {
            return issueType;
        }
    }
    return issueTypes;
}

// Converts a json to a `IssueType` record
function convertToIssueType(json jsonPayload) returns IssueType {
    json id = checkpanic jsonPayload.id;
    json name = checkpanic jsonPayload.name;
    json description = checkpanic jsonPayload.description;
    json avatarId = checkpanic jsonPayload.icon.id;
    IssueType issueType = {
        id: id.toString(),
        name: name.toString(),
        description: description.toString(),
        avatarId: avatarId.toString()
    };
    return issueType;
}
