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
function convertToIssue(json jsonPayload) returns Issue {
    json issueId = checkpanic jsonPayload.issueId;
    json issueKey = checkpanic jsonPayload.issueKey;
    json requestTypeId = checkpanic jsonPayload.requestTypeId;
    json createdDate = checkpanic jsonPayload.createdDate.friendly;
    json reporterName = checkpanic jsonPayload.reporter.displayName;
    json status = checkpanic jsonPayload.currentStatus.status;
    IssueType issueType = {id: requestTypeId.toString()};
    Issue issue = {
        id: issueId.toString(),
        key: issueKey.toString(),
        statusId: status.toString(),
        reporterName: reporterName.toString(),
        createdDate: createdDate.toString(),
        issueType: issueType
    };
    return issue;
}
function createSLAInformationArray(json jsonPayload) returns SLAInformation[]|error {
    SLAInformation[]|error slaInfo = [];
    json|error slaJson = jsonPayload.values;
    if (slaJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the sla information");
    } else {
        slaInfo = convertToSLAInformationArray(<json[]>jsonPayload.values);
    }
    return slaInfo;
}

function convertToSLAInformationArray(json[] jsonPayload) returns SLAInformation[]|error {
    int i = 0;
    SLAInformation[] slaInfoArray = [];
    foreach json slaJson in jsonPayload {
        SLAInformation|error sla = convertToSLAInformation(slaJson);
        if (sla is SLAInformation) {
            slaInfoArray[i] = sla;
            i = i + 1;
        } else {
            return sla;
        }
    }
    return slaInfoArray;
}

function convertToSLAInformation(json jsonPayload) returns SLAInformation {
    json idVal = checkpanic jsonPayload.id;
    int id = checkpanic 'int:fromString(idVal.toString());
    json name = checkpanic jsonPayload.name;
    json completedCyclesJson = checkpanic jsonPayload.completedCycles;
    json ongoingCycleJson = checkpanic jsonPayload.ongoingCycle;
    SLACycle[] completeCycles = convertToSLACycles(<json[]>completedCyclesJson);
    SLACycle ongoingCycle = convertToSlACycle(ongoingCycleJson);
    SLAInformation slaInfo = {
        id: id,
        name: name.toString(),
        completedCycles: completeCycles,
        ongoingCycle: ongoingCycle
    };
    return slaInfo;
}

function convertToSLACycles(json[] jsonPayload) returns SLACycle[] {
    int i = 0;
    SLACycle[] cycles = [];
    foreach json jsonCycle in jsonPayload {
        SLACycle|error cycle = convertToSlACycle(jsonCycle);
        if (cycle is SLACycle) {
            cycles[i] = cycle;
            i = i + 1;
        } else {
            panic cycle;
        }
    }
    return cycles;
}
function convertToSlACycle(json jsonPayload) returns SLACycle {
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
    SLACycle cycle = {
        startTime: startTime.toString(),
        breachTime: breachTime.toString(),
        goalDurationInMillis: goalDurationInMillis,
        elapsedTimeInMillis: elapsedTimeInMillis,
        remainingTimeInMillis: remainingTimeInMillis,
        breached: breached
    };
    return cycle;
}

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

function createCommentArray(json jsonPayload) returns Comment[]|error {
    Comment[]|error comments = [];
    json|error commentsJson = jsonPayload.values;
    if (commentsJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the users");
    } else {
        comments = convertToComments(<json[]>jsonPayload.values);
    }
    return comments;
}

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

function validateResponse(http:Response response) returns json|error {
    int statusCode = response.statusCode;
    json|error jsonPayload = <@untainted>response.getJsonPayload();
    if (statusCode == http:STATUS_OK || statusCode == http:STATUS_NO_CONTENT || statusCode == http:STATUS_CREATED) {
        return jsonPayload;
    }
    return createError(HTTP_ERROR_CODE, jsonPayload.toString());
}

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

function createIssueTypeArray(json jsonPayload) returns IssueType[]|error {
    IssueType[]|error types = [];
    json|error typesJson = jsonPayload.values;
    if (typesJson is error) {
        return createError(CONVERSION_ERROR_CODE, "could not retrieve the queues");
    } else {
        types = convertToIssueTypes(<json[]>jsonPayload.values);
    }
    return types;
}

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

function createError(string reason, string message) returns error {
    return error(reason, message = message);
}

function getPath(string path, string query, string value) returns string {
    if (path.indexOf("?", 0) == ()) {
        return path + QUESTION_MARK + query + EQUAL + value;
    } else {
        return path + AMPERSAND + query + EQUAL + value;
    }
}
