Front-end app
---
Front-end application written in [Node.js](https://nodejs.org/en/) that puts together all of the microservices under [microservices-demo](https://github.com/microservices-demo/microservices-demo).

## Development
#### Dependencies
<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Version</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://docker.com">Docker</a></td>
      <td>>= 1.12</td>
    </tr>
    <tr>
      <td><a href="https://docs.docker.com/compose/">Docker Compose</a></td>
      <td>>= 1.8.0</td>
    </tr>
    <tr>
      <td><a href="https://nodejs.org">Node.js</a></td>
      <td>>= 0.10.32</td>
    </tr>
    <tr>
      <td><a href="gnu.org/s/make">Make</a>&nbsp;(optional)</td>
      <td>>= 4.1</td>
    </tr>
  </tbody>
</table>

#### Getting started
**Before you start** make sure the rest of the microservices are up & running. The easiest way to achieve this is by using the provided Docker Compose file under `deploy/docker-only`.

Install the application dependencies with:
```
$ make deps
```

#### Testing
**Make sure that the microservices are up & running**

* Unit & Functional tests:

    ```
    make test
    ```

* End-to-End tests:
    To make sure that the test suite is running against the latest (local) version with your changes, you need to manually build
    the image, run the container and attach it to the proper Docker networks.
    There is a make task that will do all this for you:

    ```
    $ make dev
    ```

    That will also tail the logs of the container to make debugging easy.

    Then you can run the tests with:

    ```
    $ make e2e
    ```
