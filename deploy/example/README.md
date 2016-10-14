# Example documentation

Hi, cool docs over here.


We need to install some tools before we start:
<!-- deploy-test preinstall -->

    apt-get install -yq cowsay

<!-- deploy-test-end -->

# Provision infrastucture

<!-- deploy-test-start create-infrastructure -->

  gcloud instances create blah

<!-- deploy-test-end -->



<!-- now we can run the tests -->

<!-- deploy-test-start run-tests --> 
  
    cd /path/of/tests;
    ./run_tests

<!-- deployment-test-end -->



# Cleaning upg
If you're done, clean up your cluster with these commands:

<!-- deploy-test-start destroy-infrastructure -->

  gcloud destroy blah

<!-- deploy-test-end -->

