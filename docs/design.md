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
    - GET /paymentAuth
- Shipping
    - POST /shipping
    - GET /shipping/{id}
- Accounts:
    - Create address:
        - curl -XPOST -H "Content-type: application/json" http://accounts/addresses -d '{"street": "my road", "number": "3", "country": "UK", "city": "London"}'
    - Create card: 
        - curl -XPOST -H "Content-type: application/json" http://accounts/cards -d '{"longNum": "5429804235432", "expires": "04/16", "ccv": "432"}'
    - Create customer:
        - curl -XPOST -H "Content-type: application/json" http://accounts/customers -d '{"firstName": "alice", "lastName": "Green", "addresses": ["http://accounts/addresses/0"], "cards": ["http://accounts/cards/0"]}'
    - GET /customers/{id}
    - Get addresses for customer
        - GET /customers/{id}/addresses
    - PUT/PATCH/DELETE all work too.
    - No username/password functionality. Customer id should be referenced from login service.
- Cart
    - Create cart    
        - curl -XPOST -H "Content-type: application/json" http://cart/carts -d '{"customerId": 1}' 
    - Get/remove/update cart
        - GET/DELETE/PUT /carts/{id}
    - Get cart for customerId (empty array if doesn't exist)
        - GET /carts/search/findByCustomerId?custId=[customerId]
    - Get items in cart
        - GET /carts/{id}/items
    - To add items to the cart, create a new item, then add the link to the cart. Orphaned items will be deleted.
        - curl -XPOST -H 'Content-type: application/json' http://cart/items -d '{"itemId": "three", "quantity": 4 }'    
        - curl -v -X POST -H "Content-Type: text/uri-list" -d "http://cart/items/27017283435201488713382769171" http://cart/carts/27017282808012190207258014226/items
    - Remove item from cart
        - curl -XDELETE http://localhost:8080/carts/2/items/4
    - Update quantities:
        - curl -XPATCH -H 'Content-type: application/json' http://localhost:8080/items/5 -d '{"quantity": 100}'
- Orders
    - Create new order
        - curl -XPOST -H 'Content-type: application/json' http://orders/orders -d '{"customer": "http://accounts/customers/27017261685533885656544909042", "address": "http://accounts/addresses/27017261685533885656544909040", "card": "http://accounts/cards/27017261685533885656544909041", "items": "http://cart/carts/27017282808012190207258014226/items", "customerId": 27017261685533885656544909042}'
    - GET/PATCH/DELETE /orders/{id}
    - Find orders by customer ID:
        - curl http://orders/orders/search/customerId?custId=1

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
