package works.weave.socks.cart.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import works.weave.socks.cart.cart.CartDAO;
import works.weave.socks.cart.cart.CartResource;
import works.weave.socks.cart.entities.Cart;

@RestController
@RequestMapping(path = "/carts")
public class CartsController {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private CartDAO cartDAO;

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(value = "/{customerId}", produces = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.GET)
    public Cart get(@PathVariable String customerId) {
        return new CartResource(cartDAO, customerId).value().get();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(value = "/{customerId}", method = RequestMethod.DELETE)
    public void delete(@PathVariable String customerId) {
        new CartResource(cartDAO, customerId).destroy().run();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(value="/{customerId}/merge", method = RequestMethod.GET)
    public void mergeCarts(@PathVariable String customerId, @RequestParam(value = "sessionId") String sessionId) {
        logger.debug("Merge carts request received for ids: " + customerId + " and " + sessionId);
        CartResource sessionCart = new CartResource(cartDAO, sessionId);
        CartResource customerCart = new CartResource(cartDAO, customerId);
        customerCart.merge(sessionCart.value().get()).run();
        delete(sessionId);
    }
}
