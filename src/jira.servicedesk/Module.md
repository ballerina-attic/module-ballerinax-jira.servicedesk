Connects to Jira Service Desk from Ballerina.

# Module Overview

This module allows you to access the Jira Service Desk's REST API through Ballerina. The Jira Service Desk connector
 can be used to manage your service desks by executing the supported CRUD (create, read, update, delete) operations
 on the issues, projects, customers, and organizations.

## Compatibility

|                                      |           Version           |
|:------------------------------------:|:---------------------------:|
| Ballerina Language                   |     Swan Lake Preview1      |
| Jira Service Desk REST API           |            3.6.2            |

## Configurations

Instantiate the connector by giving the authentication details and the URL of your Jira instance in the Jira client
 configuration. 

**Obtaining Tokens**

1. Visit [Atlassian](https://www.atlassian.com/) and sign up to create your account.
2. Generate [an API token](https://id.atlassian.com/manage/api-tokens) for Jira using your Atlassian Account.


```ballerina
// Add the content of the below config file to create a `servicedesk:Client` configuration.
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

## Sample

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

    // Perform the `Organization`-related actions
    servicedesk:Organization organization = checkpanic serviceDeskClient->createOrganization("<ORG_NAME>");
    // Add the created user to the organization
    checkpanic organization->addUsers([USER_ID]);
    // Retrieve all the users in the organization
    servicedesk:User[]|error usersInOrganization = organization->getUsers();
    // Remove the created user from the organization
    checkpanic organization->removeUsers([USER_ID]);


    // Perform the `ServiceDesk`-related actions
    // Retrieve all the service desks in your Jira instance
    servicedesk:ServiceDesk[] servicedesks = checkpanic serviceDeskClient->getServiceDesks();

    // Retrieve the service desks by the ID
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
    
    // Retrieve the users in the service desk
    servicedesk:User[] usersInServiceDesk = checkpanic itHelpDesk->getCustomers();
}
```
