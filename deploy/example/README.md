# Example documentation

Hi, cool docs over here.


We need to install some tools before we start:
<!-- deploy-test pre-install -->

    apt-get install -yq cowsay

<!-- deploy-test-end -->

# Provision infrastucture

We first have to provision some instances.

<!-- deploy-test-start create-infrastructure -->

    gcloud instances create blah

<!-- deploy-test-end -->

Now you can play around with your cluster!

<!-- now we can run the tests, hidden from the end-user -->
<!-- deploy-test-start run-tests

    cd /path/of/tests;
    ./run_tests
-->

# Cleaning up
If you're done, clean up your cluster with these commands:

<!-- deploy-test-start destroy-infrastructure -->

    gcloud destroy blah

<!-- deploy-test-end -->

