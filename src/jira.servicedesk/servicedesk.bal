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

# Handles functions related to a specific Service Desk.
public type ServiceDesk client object {

    private ServiceDeskProperties properties;
    private http:Client jiraClient;

    # Initializes the `ServiceDesk` client object.
    #
    # + jiraClient - The `http:Client` object
    # + properties - Properties of the Service Desk
    public function __init(http:Client jiraClient, ServiceDeskProperties properties) {
        self.jiraClient = jiraClient;
        self.properties = properties;
    }

    # Retrieves the properties of the Service Desk.
    # ```ballerina
    # ServiceDeskProperties properties = serviceDesk.getProperties();
    # ```
    #
    # + return - The `ServiceDeskProperties` record of the Service Desk
    public function getProperties() returns ServiceDeskProperties {
        return self.properties;
    }

    # Retrieves the list of the customers in a service desk.
    # ```ballerina
    # User[]|error customers = serviceDesk->getCustomers();
    # ```
    #
    # + searchQuery - The string query used to filter the customer list
    # + return - The list of `User` records of the customers in the service desk or else error
    public remote function getCustomers(string searchQuery = "") returns User[]|error {
        http:Request request = new;
        request.setHeader("X-ExperimentalApi", "opt-in");
        string path = SERVICEDESK_PATH + PATH_SEPARATOR + self.properties.id.toString() + CUSTOMER_PATH;
        path = searchQuery != "" ? path + QUEUE_PATH + searchQuery : path;
        http:Response|error response = self.jiraClient->get(path, request);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createUserArray(result);
            }
        }
    }

    # Adds one or more customers to a service desk.
    # ```ballerina
    # error? result = serviceDesk->addCustomers(["accountid-123"]);
    # ```
    #
    # + users - List of user account IDs, to add to the service desk
    # + return - () if successful or else error
    public remote function addCustomers(string[] users) returns error? {
        json[] values = <json[]>users;
        json request = {
            "accountIds": values
        };
        http:Response|error response = self.jiraClient->post(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + CUSTOMER_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Removes one or more customers from a service desk.
    # ```ballerina
    # error? result = serviceDesk->removeCustomers(["accountid-123"]);
    # ```
    #
    # + users - List of user account IDs, to remove from the service desk
    # + return - () if successful or else error
    public remote function removeCustomers(string[] users) returns error? {
        json[] values = <json[]>users;
        json request = {
            "accountIds": values
        };
        http:Response|error response = self.jiraClient->delete(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + CUSTOMER_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Retrieves the queues in a service desk.
    # ```ballerina
    # Queue[]|error queues = serviceDesk->getQueues();
    # ```
    #
    # + includeCount - Specifies whether to include each queue's customer
    #                  issue count in the response - default is false
    # + return - The list of `Queue` of the service desk if successful or else error
    public remote function getQueues(boolean includeCount = false) returns Queue[]|error {
        http:Response|error response = self.jiraClient->get(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + QUEUE_PATH + INCLUDE_COUNT + includeCount.toString());
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createQueueArray(result, includeCount);
            }
        }
    }

    # Retrieves a specific queue in a service desk.
    # ```ballerina
    # Queue|error queue = serviceDesk->getQueueById(1);
    # ```
    #
    # + queueId - ID of the required queue
    # + includeCount - Specifies whether to include each queue's customer
    #                  issue count in the response - default is false
    # + return - The specific `Queue` of the service desk
    public remote function getQueueById(int queueId, boolean includeCount = false)
    returns Queue|error {
        string path = SERVICEDESK_PATH + PATH_SEPARATOR + self.properties.id.toString() + QUEUE_PATH
            + PATH_SEPARATOR + queueId.toString() + INCLUDE_COUNT + includeCount.toString();
        http:Response|error response = self.jiraClient->get(path);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToQueue(result, includeCount);
            }
        }
    }

    # Retrieves the customer issues in a queue.
    # ```ballerina
    # Issue[]|error issues = serviceDesk->getIssuesInQueue(1);
    # ```
    #
    # + queueId - The ID of the queue whose customer issues will be returned
    # + return - Returns the customer issues belonging to the queue or else error
    public remote function getIssuesInQueue(int queueId) returns Issue[]|error {
        string path = SERVICEDESK_PATH + PATH_SEPARATOR + self.properties.id.toString() + QUEUE_PATH + PATH_SEPARATOR
            + queueId.toString() + ISSUE_PATH;
        http:Response|error response = self.jiraClient->get(path);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createIssuesInQueueArray(result);
            }
        }
    }

    # Retrieves all customer issue types from a service desk.
    # ```ballerina
    # IssueType[]|error issueTypes = serviceDesk->getIssueTypes();
    # ```
    #
    # + groupId - Filters results to those in a customer issue type group
    # + searchQuery - The string used to filter the results
    # + return - The requested customer `IssueType` list or else error
    public remote function getIssueTypes(public int groupId = 0,
        public string searchQuery = "") returns IssueType[]|error {
        string path = SERVICEDESK_PATH + PATH_SEPARATOR + self.properties.id.toString() + PATH_SEPARATOR +
            ISSUE_TYPE_PATH;
        path = groupId != 0 ? getPath(path, "groupId", groupId.toString()) : path;
        path = searchQuery != "" ? getPath(path, "searchQuery", searchQuery) : path;
        http:Response|error response = self.jiraClient->get(path);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createIssueTypeArray(result);
            }
        }
    }

    # Retrieves a customer issue type from a service desk.
    # ```ballerina
    #  IssueType|error issueType = serviceDesk->getIssueTypeById(10002);
    # ```
    #
    # + issueTypeId - The ID of the customer issue type to be returned
    # + return - The customer `IssueType` or else error
    public remote function getIssueTypeById(int issueTypeId) returns IssueType|error {
        http:Response|error response = self.jiraClient->get(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + ISSUE_TYPE_PATH + PATH_SEPARATOR + issueTypeId.toString());
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToIssueType(result);
            }
        }
    }

    # Retrieves organizations associated with a service desk.
    # ```ballerina
    # Organization[]|error organizations = serviceDesk->getOrganizations();
    # ```
    #
    # + return - The requested list of `Organization` if successful or else error
    public remote function getOrganizations() returns Organization[]|error {
        http:Response|error response = self.jiraClient->get(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + ORGANIZATION_PATH);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createOrganizationArray(result, self.jiraClient);
            }
        }
    }

    # Adds an organization to a service desk.
    # ```ballerina
    # error? result = serviceDesk->addOrganization(1);
    # ```
    #
    # + organizationId - The ID of the Organization to be added
    # + return - () if successful or else error
    public remote function addOrganization(int organizationId) returns error? {
        json request = {
            "organizationId": organizationId
        };
        http:Response|error response = self.jiraClient->post(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + ORGANIZATION_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Removes an organization from a service desk.
    # ```ballerina
    # error? result = serviceDesk->removeOrganization(1);
    # ```
    #
    # + organizationId - The ID of the Organization to be removed
    # + return - () if successful or else error
    public remote function removeOrganization(int organizationId) returns error? {
        json request = {
            "organizationId": organizationId
        };
        http:Response|error response = self.jiraClient->delete(SERVICEDESK_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + ORGANIZATION_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Retrieves all customer issues for the user executing the query.
    # ```ballerina
    # Issue[]|error issues = serviceDesk->getIssues();
    # ```
    #
    # + searchTerm - Search query to filter issues if the search term matches the issue summary
    # + issueStatus - Filters issues based on values CLOSED, OPEN and ALL
    # + issueTypeId - Filters issues by issue type
    # + return - The list of `Issue` if successful or else error
    public remote function getIssues(public int issueTypeId = 0, public string searchTerm = "",
        public string issueStatus = "") returns Issue[]|error {
        string path = REQUEST_PATH;
        path = searchTerm != "" ? getPath(path, "searchTerm", searchTerm) : path;
        path = issueTypeId != 0 ? getPath(path, "issueTypeId", issueTypeId.toString()) : path;
        path = issueStatus != "" ? getPath(path, "issueStatus", issueStatus) : path;
        http:Response|error response = self.jiraClient->get(path);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createIssueArray(result);
            }
        }
    }

    # Creates a customer issue in a service desk.
    # ```ballerina
    # Issue|error issueCreated = serviceDesk->createIssue(issue, "I need a new *mouse* for my Mac", ["id-123"]);
    # ```
    #
    # + issue - The issue to be created
    # + description - The description of the issue
    # + participants - List of customers to participate in the issue, as a list of accountId
    #                  values
    # + onBehalfOf - The accountId of the customer that the issue is being raised on behalf of
    # + return - The `Issue` created if successful or else error
    public remote function createIssue(Issue issue, string description,
        string[] participants, public string onBehalfOf = "") returns Issue|error {
        json[] values = <json[]>participants;
        json request = {
            "serviceDeskId": self.properties.id,
            "requestTypeId": issue?.issueType?.id,
            "requestFieldValues": {
                "summary": issue?.summary,
                "description": description
            },
            "requestParticipants": values
        };
        if (onBehalfOf != "") {
            json onBehalf = {
                "raiseOnBehalfOf": onBehalfOf
            };
            request = checkpanic request.mergeJson(onBehalf);
        }
        http:Response|error response = self.jiraClient->post(REQUEST_PATH, request);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToIssue(result);
            }
        }
    }
};
