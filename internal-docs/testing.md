# Testing strategies

**Goal: Demonstrate real world microservice testing techniques**

## Test levels

### Unit

No need to describe.

### Component

Test service without external dependencies. For example, test the stateful services without the need for an external DB. Use a mocked or simulated version. Items to test:

- Contract
- Wiring of internal subjects
- Inter-class communication and dependencies

### Container
 
Test service as a container, with their external dependencies. Only test specific service. No need to start entire application. For example, test stateful services with a real DB container and by using their external API. Items to test:

- Failure state: What happens when dependencies are not available (e.g. no db)?
- API
- Use-case

### Application

Verify that the application works as a whole, on the intended platform. Items to test:

- Does it start?
- Does it not crash?
- Are the deployment scripts working?
- Is the deployment platform responsive?
- Performance

### User

From the point of view of a user, is the application functional? Items to test:

- UI testing (more research required)
-- Link checking
-- Click through testing
-- Use case testing
- Any public APIs

## Test environments

| Environment | Responsibilities                                                 | Level mapping                |
|:------------|:-----------------------------------------------------------------|:-----------------------------|
| Local       | Development                                                      | Unit                         |
| Build       | Building code and containers                                     | Unit, Component              |
| Testing     | Transient infrastructure for testing containers and applications | Container, Application, User |
| Staging     | Permanent infrastructure for snapshot deployment                 |                              |
| Production  | Static production deployment                                     |                              |

## Pipeline

All events are triggered by the repository. The following repository actions will produce the result:

| Action                 | Requirement                                          | Task                                                          |
|:-----------------------|:-----------------------------------------------------|:--------------------------------------------------------------|
| Commit in PR           |                                                      | Build branch, deploy to testing                               |
| Commit/Merge in master | PR branch passing tests. Code reviewed.              | Build snapshot, deploy to testing, deploy to staging          |
| GH release             | Master passing tests. Manual staging tests complete. | Build tagged version, deploy to testing, deploy to production |

We can invert that table. Environments will be triggered when:

| Environment | Triggered on                            |
|:------------|:----------------------------------------|
| Local       |                                         |
| Build       | New commit in branch/master/tag         |
| Testing     | Successful build of branch/snapshot/tag |
| Staging     | Successful testing of snapshot          |
| Production  | Github release                          |

## Testing gates

Preferably, all steps will be integrated with GH. E.g. you can't merge the PR until the branch has been built and successfully deployed to testing.

Generally, you can proceed to the following step when:

| Step       | Proceed                                             |
|:-----------|:----------------------------------------------------|
| Production | After manual QA acceptance                          |
| Staging    | After successful testing deployment                 |
| Testing    | After successful build                              |
| Build      | After successful unit and component test and new PR |

# Application urls

## Staging

Keys and/or passwords are available from the maintainer.

| Stage   | Description  | URL                                                                           | Maintainer |
|:--------|:-------------|:------------------------------------------------------------------------------|:-----------|
| Staging | Bastion host | 52.209.82.220                                                                 | Phil       |
| Staging | App          | http://microservices-demo-staging-k8s-1605564473.eu-west-1.elb.amazonaws.com/ | Phil       |
| Staging | K8s UI       | https://52.209.23.12/ui                                                       | Phil       |
| Staging | Scope UI     | http://microservicesdemo-staging-scope-1340023156.eu-west-1.elb.amazonaws.com | Phil       |
