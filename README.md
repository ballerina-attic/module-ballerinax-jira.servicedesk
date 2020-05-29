[![Build Status](https://travis-ci.com/ballerina-platform/module-ballerinax-jira.servicedesk.svg?branch=master)](https://travis-ci.com/ballerina-platform/module-ballerinax-jira.servicedesk)
# Ballerina Jira Service Desk Connector

This module allows you to access the Jira Service Desk's REST API through ballerina. Jira Service Desk is an ITSM 
solution by Atlassian. With Jira Service Desk, you can easily receive, track, manage, and resolve requests from 
your team’s customers. Jira Service Desk is built on the Jira platform, so you’ll see some terms and concepts that 
carry across all of Atlassian’s Jira products. The Jira Service Desk connector can be used to manage your service desks
by executing the supported CRUD (create, read, update, delete) operations on the issues, projects, customers and
 organizations.

The following sections provide you details on how to use the Jira Service Desk connector.

- [Compatibility](#compatibility)
- [Getting Started](#getting-started)
- [Samples](#samples)

## Compatibility

|                                      |           Version           |
|:------------------------------------:|:---------------------------:|
| Ballerina Language                   |            1.2.x            |
| Jira Service Desk REST API           |            3.6.2            |

## Getting Started

### Prerequisites
Download and install [Ballerina](https://ballerinalang.org/downloads/).

### Pull the Module
Execute the below command to pull the Jira Service Desk module from Ballerina Central:
```ballerina
$ ballerina pull ballerinax/jira.servicedesk
```
## Sample

Instantiate the connector by giving authentication details and the url of your Jira instance in the Jira client
 configuration. 

**Obtaining Tokens**

1. Visit [Atlassian](https://www.atlassian.com/) and create an sign up to create your account.
2. Generate an API token for Jira using your Atlassian Account: https://id.atlassian.com/manage/api-tokens


**Create the `servicedesk:Client`**

```ballerina
// Create `servicedesk:Client` configuration by reading from config file.
import ballerinax/jira.servicedesk;

servicedesk:BasicAuthConfiguration basicAuth = {
    username: USERNAME,
    apiToken: API_TOKEN
};

servicedesk:Configuration jiraConfig = {
    baseUrl: BASE_URL,
    authConfig: basicAuth
};

servicedesk:Client servicedeskClient = new (jiraConfig);
```

**Perform Jira Service Desk operations**

```ballerina
import ballerina/io;
import ballerinax/jira.servicedesk;

public function main() {
    servicedesk:BasicAuthConfiguration basicAuth = {
        username: USERNAME,
        apiToken: PASSWORD
    };

    servicedesk:Configuration jiraConfig = {
        baseUrl: BASE_URL,
        authConfig: basicAuth
    };
    servicedesk:Client serviceDeskClient = new (jiraConfig);

    servicedesk:User userCreated = checkpanic serviceDeskClient->createCustomer("<CUSTOMER_EMAIL>", "<CUSTOMER_NAME>");
    string USER_ID = "";
    string? userId = userCreated?.accountId;
    if (userId is string) {
        USER_ID = userId;
    }

    // Perform `Organization` related actions
    servicedesk:Organization organization = checkpanic serviceDeskClient->createOrganization("<ORG_NAME>");
    // Add the created user to the organization
    checkpanic organization->addUsers([USER_ID]);
    // Retrieve all the users in the organization
    servicedesk:User[]|error usersInOrganization = organization->getUsers();
    // Remove the created user from the organization
    checkpanic organization->removeUsers([USER_ID]);


    // Perform `ServiceDesk` related actions
    // Retrieve all the service desks in your Jira instance
    servicedesk:ServiceDesk[] servicedesks = checkpanic serviceDeskClient->getServiceDesks();

    // Retrieve service desks by id
    servicedesk:ServiceDesk itHelpDesk = checkpanic serviceDeskClient->getServiceDeskById(1);
    servicedesk:ServiceDesk supportHelpDesk = checkpanic serviceDeskClient->getServiceDeskById(2);

    // Create an issue 
    servicedesk:Issue issue = {
        summary: "Request JSD help via REST",
        issueType: {
            id: "10003"
        }
    };
    servicedesk:Issue|error result =
        itHelpDesk->createIssue(issue, "I have an issue", [USER_ID]);

    // Retrieve all the queues in the service desk
    servicedesk:Queue[] queues = checkpanic itHelpDesk->getQueues(true);
    
    // Retrieve users in the service desk
    servicedesk:User[] usersInServiceDesk = checkpanic itHelpDesk->getCustomers();
}
```
