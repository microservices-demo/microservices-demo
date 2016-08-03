# Testing

These directories hold scripts that run tests for each testing scope. For example, the unit folder contains scripts that run unit tests for each service (i.e. just calls mvn test or equivalent). Other scopes may be more complex.

## Layout

Each folder contains shell scripts that (roughly, e.g. java unit tests all run at once) test each service. To create a new test, simply add a `sh` script to the folder.

## Usage

### OSX / docker-machine Users

If you're not working out of the `/Users` directory, you must first copy the code to the docker-machine VM, otherwise you
won't be able to mount correctly.

### Running the tests

To run a test scope, simply call the `test.sh` file with the scope that you want to test. For example: `./test.sh --verbose unit component` will run the unit and component tests in verbose mode, meaning that all the intermediate testing steps will be printed.

If all tests pass, then the script will exit with a status of 0.

### Example usage

```
$ ./testing/test.sh unit container
02:13:43 PM [   info] Running tests for "unit container"
02:13:43 PM [   info] Testing ./testing/unit/catalogue.py
02:13:45 PM [   info] Testing ./testing/unit/java-services.py
02:13:54 PM [   info] Testing ./testing/unit/login.py
02:13:55 PM [   info] Testing ./testing/unit/payment.py
all 4 ./testing tests passed in 14.000s.
02:13:57 PM [   info] Testing ./testing/container/catalogue.py
all 1 ./testing tests passed in 1.000s.
```
