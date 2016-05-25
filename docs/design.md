# Architecture§
![Architecture diagram](https://github.com/ContainerSolutions/weaveDemo/raw/master/docs/images/Architecture.png "Architecture")

# API
- Catalogue
    - GET /catalogue
    - GET /catalogue/{id}
    - GET /catalogue/search?query=[search-query]
    - PUT /catalogue/{id} (update count)
- Login
    - GET /login (query params or basic auth?)
        - returns customer id
- Payment
    - GET /validate
- Shipping
    - POST /shipping
    - GET /shipping/{id}
- Accounts:
    - GET /accounts/{id}
    - GET /accounts/?custId=[customerId] get account for customer
    - PUT /accounts/{id}  update account
    - POST /accounts/ create new account with customer id
- Cart
    - GET /carts/?custId=[customerId]
    - PUT /carts/{id} (add/remove item to/from cart)
- Orders
    - POST /orders (create new order)
    - GET /orders/{id}

# DockerCon Demo Narrative
## Full demo (requires internet connection)
This could also run as a pre-recorded video demo.

The infrastructure for the application is described in a YAML file and it includes containerised components supplied by Weave.

The application is a website that sells socks.

* Code is present and observable (if necessary) on laptop.
* Show a local version of the entire application.
* The presenter can introduce scope and show how it describes the app.
* Show how networks are segmented via Weave Net.
* Talk about how this code is pushed to CI and the CI deploys to test and production servers on [insert cloud service here].
* Presenter opens web based scope and demonstrates similarity between local and remote scope windows.
* Presenter now manually destroys one of the services. Watch scope as service is destroyed and new service is started.
* Presenter now starts load test. Watch node icons in scope as services become loaded.
* Induce a crash in one of the nodes. See error/crash in scope and click through the UI to get to the container CLI. View the logs.

Bonus points in the demo:
* Observe the different Docker networks in use
* See metrics
* Deploy a different version of an existing service
* Use Flux

## Quick Demo (local network, Docker Swarm)
Similar to above.
* Code is present and observable (if necessary) on laptop.
* Show a local version of the entire application.
* The presenter can introduce scope and show how it describes the app.
* Show how networks are segmented via Weave Net.
* Make a code change, build, start new container. (TBC - something visible)
* [FLUX ONLY] If change is made to load balanced container, show how old/new container is used (A/B) testing. (TBC - How do we show which is being used? Content?)
* Kill the old container.


Eventual storylines: 
test & observe loop (as above)
segment (isolated networks)
flow (traffic management & tracing examples) 
monitor (charts & time series)
