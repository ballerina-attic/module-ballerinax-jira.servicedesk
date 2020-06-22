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
import ballerina/http;
import ballerina/oauth2;

# Handles the global functions related to the `Jira Service Desk` instance.
public type Client client object {
    http:Client jiraClient;

    # Initializes the Jira client endpoint.
    #
    # + jiraConfig - Jira client configuration record
    public function init(Configuration jiraConfig) {
        string baseUrl = jiraConfig.baseUrl + API_PATH;
        http:ClientConfiguration clientConfig;
        BasicAuthConfiguration|oauth2:DirectTokenConfig authConfig = jiraConfig.authConfig;
        if (authConfig is BasicAuthConfiguration) {
            auth:OutboundBasicAuthProvider basicAuthProvider = new ({
                username: authConfig.username,
                password: authConfig.apiToken
            });
            http:BasicAuthHandler outboundBasicAuthHandler = new (basicAuthProvider);
            clientConfig = {
                auth: {
                    authHandler: outboundBasicAuthHandler
                }
            };
        } else {
            oauth2:OutboundOAuth2Provider oauth2Provider = new (authConfig);
            http:BearerAuthHandler bearerHandler = new (oauth2Provider);
            clientConfig = {
                auth: {
                    authHandler: bearerHandler
                }
            };
        }
        self.jiraClient = new (baseUrl, config = clientConfig);
    }

    # Retrieves all the service desks in the Jira Service Desk instance.
    # ```ballerina
    # ServiceDesk[]|error serviceDesks = serviceDeskClient->getServiceDesks();
    # ```
    #
    # + return - An array of `ServiceDesk` instances if successful or else an error
    public remote function getServiceDesks() returns ServiceDesk[]|error {
        http:Response|error response = self.jiraClient->get(SERVICEDESK_PATH);
        if (response is error) {
            return response;
        } else {
            error|json result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createServiceDeskArray(result, self.jiraClient);
            }
        }
    }

    # Retrieves a Service Desk by the given ID.
    # ```ballerina
    # ServiceDesk|error serviceDesk = serviceDeskClient->getServiceDeskById(1);
    # ```
    #
    # + serviceDeskId - The ID of the Service Desk to return
    # + return - Returns the requested `ServiceDesk` instance as a client object or else an error
    public remote function getServiceDeskById(int serviceDeskId) returns ServiceDesk|error {
        http:Response|error response = self.jiraClient->get(SERVICEDESK_PATH + PATH_SEPARATOR
            + serviceDeskId.toString());
        if (response is error) {
            return response;
        } else {
            error|json result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToServiceDesk(result, self.jiraClient);
            }
        }
    }

    # Creates a customer who is not associated with a Service Desk project.
    # To raise issues in closed Service Desks, the customer must be added to a
    # service desk project using `serviceDesk->addCustomers([<accountId>])`.
    # ```ballerina
    # User|error customer = serviceDeskClient->createCustomer("john@example.com", "John H. Smith");
    # ```
    #
    # + emailAddress - Customer's email address
    # + displayName - Customer's name to be displayed in the UI
    # + return - Customer detail record if successful or else an error
    public remote function createCustomer(string emailAddress, string displayName) returns User|error {
        json request = {
            "email": emailAddress,
            "fullName": displayName
        };
        http:Response|error response = self.jiraClient->post(CUSTOMER_PATH, request);
        if (response is error) {
            return response;
        } else {
            error|json result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToUser(result);
            }
        }
    }

    # Retrieves the list of organizations in the Jira Service Desk instance.
    # ```ballerina
    # Organization[]|error organizations = serviceDeskClient->getOrganizations();
    # ```
    #
    # + return - List of organizations if successful or else an error
    public remote function getOrganizations() returns Organization[]|error {
        http:Response|error response = self.jiraClient->get(ORGANIZATION_PATH);
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

    # Retrieves an organization by the given ID.
    # ```ballerina
    # Organization|error organization = serviceDeskClient->getOrganizationById(1);
    # ```
    #
    # + organizationId - The ID of the organization to retrieve
    # + return - Requested organization if successful or else an error
    public remote function getOrganizationById(int organizationId) returns Organization|error {
        http:Response|error response = self.jiraClient->get(ORGANIZATION_PATH + PATH_SEPARATOR
            + organizationId.toString());
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToOrganization(result, self.jiraClient);
            }
        }
    }

    # Creates an organization by passing the name of the organization.
    # ```ballerina
    # Organization|error organization = serviceDeskClient->createOrganization("My Organization");
    # ```
    #
    # + name - Name of the organization
    # + return - Created `Organization` as a client object if successful or else an error
    public remote function createOrganization(string name) returns Organization|error {
        json request = {
            "name": name
        };
        http:Response|error response = self.jiraClient->post(ORGANIZATION_PATH, request);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToOrganization(result, self.jiraClient);
            }
        }
    }

    # Deletes an organization by the given ID.
    # ```ballerina
    # error? result = serviceDeskClient->deleteOrganization(1);
    # ```
    #
    # + organizationId - The ID of the organization to be deleted
    # + return - `()` if successful or else an error
    public remote function deleteOrganization(int organizationId) returns error? {
        http:Response|error response = self.jiraClient->delete(ORGANIZATION_PATH + PATH_SEPARATOR
            + organizationId.toString());
        if (response is http:Response) {
            return validateResponseCode(response);
        } else {
            return response;
        }
    }

    # Retrieves the customer issue by the ID or key.
    # ```ballerina
    # Issue|error issue = serviceDeskClient->getIssueById("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to be returned.
    # + return - The customer `Issue` if successful or else an error
    public remote function getIssueById(int|string issueIdOrKey) returns Issue|error {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->get(REQUEST_PATH + PATH_SEPARATOR + id);
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

    # Subscribes the user to receive notifications from a customer issue.
    # ```ballerina
    # error? result = serviceDeskClient->subscribe("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to be subscribed
    # + return - `()` if successful or else an error
    public remote function subscribe(int|string issueIdOrKey) returns error? {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        json request = {};
        http:Response|error response = self.jiraClient->put(REQUEST_PATH + PATH_SEPARATOR + id + NOTIFICATION_PATH,
            request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Unsubscribes the user from the notifications of a customer issue.
    # ```ballerina
    # error? result = serviceDeskClient->unsubscribe("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to be unsubscribed from
    # + return - `()` if the user was unsubscribed or else an error
    public remote function unsubscribe(int|string issueIdOrKey) returns error? {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->delete(REQUEST_PATH + PATH_SEPARATOR + id + NOTIFICATION_PATH);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Retrieves a list of all the participants of a customer issue.
    # ```ballerina
    # User[]|error users = serviceDeskClient->getParticipants("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to retrieve its participants
    # + return - List of participants of the issue if successful or else an error
    public remote function getParticipants(int|string issueIdOrKey) returns User[]|error {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->get(REQUEST_PATH + PATH_SEPARATOR + id
            + PARTICIPANT_PATH);
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

    # Retrieves all the SLA records of a customer issue.
    # ```ballerina
    # SLAInformation[]|error sla = serviceDeskClient->getSlaInformation("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to retrieve information of its SLA
    # + return - SLA information if successful or else an error
    public remote function getSlaInformation(int|string issueIdOrKey)
    returns SlaInformation[]|error {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->get(REQUEST_PATH + PATH_SEPARATOR + id + SLA_PATH);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createSlaInformationArray(result);
            }
        }
    }

    # Creates a public or private (internal) comment of a customer issue.
    # The user recorded as the author of the comment.
    # ```ballerina
    # Comment|error comment = serviceDeskClient->createComment("SD-1", "Resolved");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue to which the comment will be added
    # + body - Content of the comment
    # + isPublic - Indicates whether the comment is public (true) or private/internal (false)
    # + return - The `Comment` created if successful or else an error
    public remote function createComment(int|string issueIdOrKey, string body,
        public boolean isPublic = false) returns Comment|error {
        json request = {
            "public": isPublic,
            "body": body
        };
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->post(REQUEST_PATH + PATH_SEPARATOR + id + COMMENT_PATH,
            request);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return convertToComment(result);
            }
        }
    }

    # Retrieves all comments of a customer issue.
    # ```ballerina
    # Comment[]|error comments = serviceDeskClient->getComments("SD-1");
    # ```
    #
    # + issueIdOrKey - The ID or key of the customer issue of which the comments will be retrieved
    # + publicOn - Whether to return public comments or not. The default value is `true`.
    # + return - List of comments if successful or else an error
    public remote function getComments(string|int issueIdOrKey, public boolean publicOn = true)
    returns Comment[]|error {
        string id = issueIdOrKey is int ? issueIdOrKey.toString() : issueIdOrKey;
        http:Response|error response = self.jiraClient->get(REQUEST_PATH + PATH_SEPARATOR + id + COMMENT_PATH);
        if (response is error) {
            return response;
        } else {
            json|error result = validateResponse(response);
            if (result is error) {
                return result;
            } else {
                return createCommentArray(result);
            }
        }
    }
};
