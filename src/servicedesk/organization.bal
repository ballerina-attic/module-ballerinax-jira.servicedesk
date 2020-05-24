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

# Handles functions related to a specific organization
public type Organization client object {

    http:Client jiraClient;
    OrganizationProperties properties;

    # Initializes the `Organization` client object.
    #
    # + jiraClient - The `http:Client` object
    # + properties - Properties of the Organization
    public function __init(http:Client jiraClient, OrganizationProperties properties) {
        self.properties = properties;
        self.jiraClient = jiraClient;
    }

    # Retrieves the properties of the Organization.
    # ```ballerina
    # OrganizationProperties properties = organization.getProperties();
    # ```
    #
    # + return - The `OrganizationProperties` record of the Organization
    public function getProperties() returns OrganizationProperties {
        return self.properties;
    }

    # Adds users to an organization.
    # ```ballerina
    # error? addUsers = organization->addUsers(["accountid-123"]);
    # ```
    #
    # + users - List of customer account IDs, to add to the organization
    # + return - () if successful or else error
    public remote function addUsers(string[] users) returns error? {
        json[] values = <json[]>users;
        json request = {
            "accountIds": values
        };
        http:Response|error response = self.jiraClient->post(ORGANIZATION_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + USER_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Removes users from an organization.
    # ```ballerina
    # error? addUsers = organization->removeUsers(["accountid-123"]);
    # ```
    #
    # + users - List of customers or account IDs, to remove from the organization
    # + return - () if successful or else error
    public remote function removeUsers((string|User)[] users) returns error? {
        json[] values = <json[]>users;
        json request = {
            "accountIds": values
        };
        http:Response|error response = self.jiraClient->delete(ORGANIZATION_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + USER_PATH, request);
        if (response is error) {
            return response;
        } else {
            return validateResponseCode(response);
        }
    }

    # Retrieves the list of users associated with an organization.
    # ```ballerina
    # User[]|error users = organization->getUsers();
    # ```
    #
    # + return - The `User` list if successful or else error
    public remote function getUsers() returns User[]|error {
        http:Response|error response = self.jiraClient->get(ORGANIZATION_PATH + PATH_SEPARATOR
            + self.properties.id.toString() + USER_PATH);
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
};
