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

import ballerinax/jira.commons;

public type User commons:User;
public type Issue commons:Issue;
public type Comment commons:Comment;
public type IssueType commons:IssueType;
public type JiraConfiguration commons:JiraConfiguration;

# Properties of a service desk instance.
# // todo: cHANGE THIS TO PROJECT
# + id - Unique ID of the service desk
# + projectId - Project ID of the service desk
# + projectName - Project name of the service desk
# + projectKey - Project key of the service desk
public type ServiceDeskProperties record {|
    int id;
    int projectId?;
    string projectName?;
    string projectKey?;
|};

# Properties of a SLA record on an issue.
#
# + id - ID of the SLA information record
# + name - Name of the SLA value
# + completedCycles - Each SLA value can have zero or more "completed cycles"
# + ongoingCycle - Each SLA value can have zero or one "ongoing cycles"
public type SLAInformation record {
    int id;
    string name;
    SLACycle[]? completedCycles;
    SLACycle? ongoingCycle;
};

# Properties of a SLA cycle in a SLA record.
#
# + startTime - Start time of the cycle
# + breachTime - Stop time of the cycle
# + goalDurationInMillis - SLA goal duration in milliseconds
# + elapsedTimeInMillis - Elapsed time of cycle in milliseconds
# + remainingTimeInMillis - Remaining time of cycle in milliseconds
# + breached - Whether the cycle breached the SLA goal
public type SLACycle record {|
    string startTime;
    string breachTime;
    int goalDurationInMillis;
    int elapsedTimeInMillis;
    int remainingTimeInMillis;
    boolean breached;
|};

# Properties of a queue in a service desk instance.
#
# + id - ID of the queue
# + name - Name of the queue
# + issueCount - Number of issues in the queue
public type Queue record {|
    int id;
    string name;
    int issueCount?;
|};

# Properties of an organization in the Jira instance.
#
# + id - ID of the organization
# + name - Name of the organization
public type OrganizationProperties record {|
    int id;
    string name;
|};


