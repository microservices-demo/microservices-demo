# Testable Deployment Documentation
This directory contains the code that is used to daily integrate all potential changes in the
microservices and especially in the descriptions of how these are deployed on top of different
suported targets.

This implies that the user-facing documentation is the canonical source for our tests, preventing
out-of-date documentation.


## Phases
The test runner has four phases:

- `pre-install`, in which required additonal software should be installed, such as Terraform.
  If this phase fails, the tests just aborts, without attempting to destroy the infrastructure.
  *NOTE*: This implies that it is very important to also install any the tool that is required
  to tear down the infrastructure.
- `create-infrastructure`, in which the cloud resources are created. If this phase fails,
  the tests are skipped, but the `destroy-infrastructure` phase is executed.
- `run-tests`, which should contain instructions that validate that the infrastructure is up and
   running and that the microservices are deployed correctly.
-  `destroy-infrastructure`, which must tear down the infrastructure.

### Secrets phase
There is an additional `require-env` phase, that can be used to pass in environmental variables to
the steps. If they are not present, testing the documentation will result in an error message that
these variables are not present.

## Defining phases and steps
Multiple shell snippets (steps) can be added to a phase.
The phases are run in the order give in the previous section, after which each snippet is executed
in the order of declaration in the file.

The following syntaxes are supported to add snippets:

 1. Single line annotation, not visibile in Markdown output

    &lt;!-- deploy-test PHASE [VALUE]* --&gt;

 2. Hidden multiline annotation

    &lt;!-- deploy-test-start PHASE [VALUE]*
    CONTENT
    --&gt;

 3. Visible multiline annotation

    &lt;!-- deploy-test-start PHASE [VALUE]* --&gt;
    CONTENT
    &lt;!-- deploy-test-end --&gt;


Note that due to current technical limitations of the test runner, each step is executed in a
separate shell.  This implies that *setting* an environmental variable in one step, will not be
available in a next step. A work-around is to load/store this information in files.
The externally required environmental variables to store secrets are available in all steps.

## Development
To contribute to these deploy documentations (e.g. to add an additional platform), add or modify a
markdown file in `$REPO/docs/deployment`.

Each document should start with a yaml block, containing at least the two entries `layout: default`
and `executableDocumentation: true`.
The `layout` part is required by Jekyll, which is used to render the markdown to GitHub pages,
the `executableDocumentation` is used to determine whether or not a markdown file should be
considered to be a test.

The runner assumes that a file `$REPO/docs/deployment/$PLATFORM.md` corresponds to a directory that
contains the required in `$REPO/deploy/$PLATFORM/`.
The `$PLATFORM` variable in the latter can be overriden by setting the yaml variable
`deploymentScriptDir` in the document header to a different name. These scripts directories should
still reside `$REPO/deploy/$ALTERNATIVE_PLATFORM_NAME/`.

Example:

    ---
    layout: default
    executableDocumentation: true
    ---

    # Hello World!
    <!-- require-env MY_SECRET_ID MY_SECRET_PASSWORD -->

    We assume that you have terraform installed.

    <!-- deploy-test-start pre-install
      # This is a hidden block, not shown in the docs.
      apt-get install terraform
    -->

    ## Create some infra
    <!-- deploy-test-start created-infrastructure -->
      terraform apply
    <!-- deploy-test-end -->


    ## Now you can deploy the application
    <!-- deploy-test-start run-tests -->
      kubectl -f blah.yml
    <!-- deploy-test-end -->

    <!-- deploy-test-start run-tests
      # hide the actual test from the documentation user
      curl http://address
    -->

    ## Cleaning up
    <!-- deploy-test-start destroy-infrastructure -->
      terraform destroy
    <!-- deploy-test-end -->

## Travis Integration
The cron job is run every day. This cron job identifies when the previous cron job has been started.
All changes since then will trigger a (partial) re-testing of documentation.

### Detected changes
The active Docker images names are retrieved by parsing the
`$REPO/deploy/kubernetes/complete-demo.yml` file.
This ensure that this list will not get out of date; we develop on top of k8s.

If any of these docker images has changed, we will trigger a build for all the supported deployment
platforms.

Alternatively, if no Docker image has change, we check for any of the changes in git files in
`$REPO/docs/deployment/$PLATFORM.md` since the previous cron job started, and trigger a build
for the changed `$PLATFORM`'s.

### Walkthrough of a typical cron cycle
- Cron job fires, this travis build executes the script in
  `$REPO/doc-tests/cronjob-test-build-spawner`.
- This script connects to the Travis API to determine when the previous cron job has started.
- Then, it determines which platforms should be tested (see previous section).
- It schedules a single build, with jobs for each platform, using the Travis API.
- Each build job is tasked to run `$REPO/doc-tests/run $PLATFORM_NAME`
- In case of a build failure, the slack channel is notified via the slack plugin.
