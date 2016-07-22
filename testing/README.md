# Testing

These directories hold scripts that run tests for each testing scope. For example, the unit folder contains scripts that run unit tests for each service (i.e. just calls mvn test or equivalent). Other scopes may be more complex.

## Layout

Each folder contains shell scripts that (roughly, e.g. java unit tests all run at once) test each service. To create a new test, simply add a `sh` script to the folder.

## Usage

To run a test scope, simply call the `test.sh` file with the scope that you want to test. For example: `./test.sh --verbose unit component` will run the unit and component tests in verbose mode, meaning that all the intermediate testing steps will be printed.
