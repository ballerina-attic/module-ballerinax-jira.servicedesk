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

import ballerina/auth;
import ballerina/config;
import ballerina/http;
import ballerina/system;
import ballerina/test;

string USERNAME = system:getEnv("JIRA_USERNAME") == "" ? config:getAsString("USERNAME") :
    system:getEnv("JIRA_USERNAME");
string PASSWORD = system:getEnv("JIRA_PASS") == "" ? config:getAsString("PASSWORD") :
    system:getEnv("JIRA_PASS");
string BASE_URL = system:getEnv("JIRA_URL") == "" ? config:getAsString("BASE_URL") :
    system:getEnv("JIRA_URL");
string ISSUE_KEY = system:getEnv("ISSUE_KEY") == "" ? config:getAsString("ISSUE_KEY") :
    system:getEnv("ISSUE_KEY");
string USER_ID = system:getEnv("USER_ID") == "" ? config:getAsString("USER_ID") :
    system:getEnv("USER_ID");
string ORG_NAME = "Test Organization";
string ORG_NAME_SD = "Service Desk Organization";
string DELETE_ORG_NAME = "Test Delete Organization";
string CUSTOMER_NAME = "John H. Smith";
string CUSTOMER_EMAIL = "jonsmith@hotmail.com";
string CUSTOMER_ID = "";

auth:OutboundBasicAuthProvider outboundBasicAuthProvider = new ({
    username: USERNAME,
    password: PASSWORD
});

http:BasicAuthHandler outboundBasicAuthHandler = new (outboundBasicAuthProvider);
JiraConfiguration jiraConfig = {
    baseUrl: BASE_URL,
    clientConfig: {
        auth: {
            authHandler: outboundBasicAuthHandler
        }
    }
};

Client sdClient = new (jiraConfig);

// Client test cases
@test:Config {}
function testGetServiceDesks() {
    ServiceDesk[]|error result = sdClient->getServiceDesks();
    if (result is ServiceDesk[]) {
        test:assertNotEquals(result.length(), 0, msg = "failed to retrieve the service desks");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetServiceDeskById() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        test:assertEquals(result.getProperties().id, 1, msg = "failed to retrieve the service desk of id 1");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testCreateCustomer() {
    User|error result = sdClient->createCustomer(CUSTOMER_EMAIL, CUSTOMER_NAME);
    if (result is User) {
        CUSTOMER_ID = result.accountId;
        test:assertEquals(result.displayName, CUSTOMER_NAME, msg = "error occurred in customer creation");
        test:assertEquals(result.emailAddress, CUSTOMER_EMAIL, msg = "error occurred in customer creation");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetOrganizations() {
    Organization[]|error result = sdClient->getOrganizations();
    if (result is Organization[]) {
        test:assertNotEquals(result.length(), 0, msg = "failed to retrieve the organizations");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetOrganizationById() {
    Organization|error organization = sdClient->getOrganizationById(1);
    if (organization is Organization) {
        test:assertEquals(organization.getProperties().id, 1, msg = "failed to retrieve the organization");
    } else {
        test:assertFail(msg = <string>organization.detail()["message"]);
    }
}

@test:Config {}
function testCreateOrganization() {
    Organization|error result = sdClient->createOrganization(ORG_NAME);
    if (result is Organization) {
        test:assertEquals(result.getProperties().name.toString(), ORG_NAME.toString(),
            msg = "failed to create the organization");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetIssueById() {
    Issue|error issue = sdClient->getIssueById(ISSUE_KEY);
    if (issue is Issue) {
        test:assertEquals(issue.key, ISSUE_KEY, msg = "failed to retrieve the issue");
    } else {
        test:assertFail(msg = <string>issue.detail()["message"]);
    }
}

@test:Config {}
function testDeleteOrganization() {
    Organization|error result = sdClient->createOrganization(DELETE_ORG_NAME);
    if (result is Organization) {
        test:assertEquals(result.getProperties().name, DELETE_ORG_NAME,
            msg = "failed to create the organization");
        checkpanic sdClient->deleteOrganization(result.getProperties().id);
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testSubscribe() {
    checkpanic sdClient->subscribe(ISSUE_KEY);
}

@test:Config {}
function testUnSubscribe() {
    checkpanic sdClient->unsubscribe(ISSUE_KEY);
}

@test:Config {}
function testGetParticipants() {
    User[]|error result = sdClient->getParticipants(ISSUE_KEY);
    if (result is User[]) {
        test:assertNotEquals(result.length(), 0, msg = "failed to retrieve the participants");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetSLAInformation() {
    SLAInformation[]|error result = sdClient->getSLAInFormation(ISSUE_KEY);
    if (result is SLAInformation[]) {
        test:assertNotEquals(result.length(), 0, msg = "failed to retrieve the sla information");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testCreateComment() {
    Comment|error result = sdClient->createComment(ISSUE_KEY, "Still working on it");
    if (result is Comment) {
        test:assertEquals(result.body, "Still working on it", msg = "failed to create the comment");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetComments() {
    Comment[]|error result = sdClient->getComments(ISSUE_KEY);
    if (result is Comment[]) {
        test:assertNotEquals(result.length(), 0, msg = "failed to retrieve the comments");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

// ServiceDesk client test cases
@test:Config {
    dependsOn: ["testAddCustomers"]
}
function testGetCustomers() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        User[]|error customers = result->getCustomers();
        if (customers is User[]) {
            test:assertNotEquals(customers.length(), 0, msg = "failed to retrieve the customers");
        } else {
            test:assertFail(msg = <string>customers.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testCreateCustomer"]
}
function testAddCustomers() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        error? addResult = result->addCustomers([CUSTOMER_ID]);
        test:assertEquals(addResult, (), msg = "failed to add customers");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddCustomers"]
}
function testRemoveCustomers() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        error? addResult = result->removeCustomers([CUSTOMER_ID]);
        test:assertEquals(addResult, (), msg = "failed to remove customers");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetQueues() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        Queue[]|error queues = result->getQueues(true);
        if (queues is Queue[]) {
            test:assertNotEquals(queues.length(), 0, msg = "failed to retrieve the queues");
        } else {
            test:assertFail(msg = <string>queues.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetQueueById() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        Queue|error queue = result->getQueueById(1);
        if (queue is Queue) {
            test:assertEquals(queue.id, 1, msg = "failed to retrieve the queue by id 1");
        } else {
            test:assertFail(msg = <string>queue.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetIssuesInQueue() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        Issue[]|error issues = result->getIssuesInQueue(1);
        if (issues is Issue[]) {
            test:assertNotEquals(issues.length(), 0, msg = "failed to retrieve the issues in queue");
        } else {
            test:assertFail(msg = <string>issues.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetIssueTypes() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        IssueType[]|error types = result->getIssueTypes();
        if (types is IssueType[]) {
            test:assertNotEquals(types.length(), 0, msg = "failed to retrieve the issue types");
        } else {
            test:assertFail(msg = <string>types.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetIssueTypeById() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        IssueType|error issueType = result->getIssueTypeById(10003);
        if (issueType is IssueType) {
            test:assertEquals(issueType.id, "10003", msg = "failed to retrieve the issue types");
        } else {
            test:assertFail(msg = <string>issueType.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetOrganizationsByServiceDesk() {
    Organization organization = checkpanic sdClient->createOrganization(ORG_NAME);
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        checkpanic result->addOrganization(organization.getProperties().id);
        Organization[]|error organizations = result->getOrganizations();
        if (organizations is Organization[]) {
            test:assertNotEquals(organizations.length(), 0, msg = "failed to retrieve the organizations");
        } else {
            test:assertFail(msg = <string>organizations.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testAddOrganizationToServiceDesk() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        error? addResult = result->addOrganization(1);
        test:assertEquals(addResult, (), msg = "failed to add the organization to service desk");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddOrganizationToServiceDesk"]
}
function testRemoveOrganizationFromServiceDesk() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        error? removeResult = result->removeOrganization(1);
        test:assertEquals(removeResult, (), msg = "failed to remove the organization from service desk");
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testGetIssuesInServiceDesk() {
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        Issue[]|error issues = result->getIssues();
        if (issues is Issue[]) {
            test:assertNotEquals(issues.length(), 0, msg = "failed to retrieve the issues");
        } else {
            test:assertFail(msg = <string>issues.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

@test:Config {}
function testCreateIssue() {
    Issue issue = {
        summary: "Request JSD help via REST",
        issueType: {
            id: "10003"
        }
    };
    ServiceDesk|error result = sdClient->getServiceDeskById(1);
    if (result is ServiceDesk) {
        Issue|error issueCreated = result->createIssue(issue, "I need a new *mouse* for my Mac", [USER_ID]);
        if (issueCreated is Issue) {
            test:assertEquals(issueCreated.summary, issue?.summary, msg = "error in creating the issue");
        } else {
            test:assertFail(msg = <string>issueCreated.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>result.detail()["message"]);
    }
}

// Organization client test cases
@test:Config {}
function testAddUsers() {
    Organization|error organization = sdClient->getOrganizationById(1);
    if (organization is Organization) {
        error? result = organization->addUsers([USER_ID]);
        test:assertEquals(result, (), msg = "failed to add the user to organization");
    } else {
        test:assertFail(msg = <string>organization.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testAddUsers"]
}
function testGetUsers() {
    Organization|error organization = sdClient->getOrganizationById(1);
    if (organization is Organization) {
        User[]|error users = organization->getUsers();
        if (users is User[]) {
            test:assertNotEquals(users.length(), 0, msg = "failed to retrieve the users");
        } else {
            test:assertFail(msg = <string>users.detail()["message"]);
        }
    } else {
        test:assertFail(msg = <string>organization.detail()["message"]);
    }
}

@test:Config {
    dependsOn: ["testGetUsers"]
}
function testRemoveUsers() {
    Organization|error organization = sdClient->getOrganizationById(1);
    if (organization is Organization) {
        error? result = organization->removeUsers([USER_ID]);
        test:assertEquals(result, (), msg = "failed to remove the user from organization");
    } else {
        test:assertFail(msg = <string>organization.detail()["message"]);
    }
}
