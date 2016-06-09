package works.weave.socks.cart.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.repositories.CartRepository;
import works.weave.socks.cart.repositories.ItemRepository;

import java.util.List;

@RestController
@RequestMapping(path = "/carts")
public class CartsController {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private ItemRepository itemRepository;

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(value = "/{customerId}", produces = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.GET)
    public Cart get(@PathVariable String customerId) {
        logger.debug("Cart: " + customersCart(customerId));
        return customersCart(customerId);
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(value = "/{customerId}", method = RequestMethod.DELETE)
    public void delete(@PathVariable String customerId) {
        List<Cart> userCarts = cartRepository.findByCustomerId(customerId);
        userCarts.forEach(cartRepository::delete);
        logger.debug("Deleted all carts for customer: " + customerId);
    }

    private Cart customersCart(String customerId) {
        return cartRepository.findByCustomerId(customerId).stream().findFirst().orElseGet(() -> {
            logger.debug("New cart created for user: " + customerId);
            return cartRepository.save(new Cart(customerId));
        });
    }

    @RequestMapping(value="/{customerId}/merge", method = RequestMethod.GET)
    public Cart mergeCarts(@PathVariable String customerId, @RequestParam(value="sessionId") String sessionId) {
        logger.debug("Merge carts request received for ids: " + customerId + " and " + sessionId);
        List<Cart> custCarts = cartRepository.findByCustomerId(customerId);
        List<Cart> sessionCarts = cartRepository.findByCustomerId(sessionId);
        Cart custCart = new Cart();

        // Assume single cart per
        if (sessionCarts.size() != 1) {
            // Nothing to merge...
            logger.debug("No session cart, skipping merge.");
            return custCart;
        }

        if (custCarts.size() > 0) {
            logger.debug("Existing cart for customer found.");
            custCart = custCarts.get(0);
        }
        for (Item i : sessionCarts.get(0).contents()) {
            logger.debug("Addiging item: " + i.itemId);
            custCart.add(i);
        }
        // custCart.contents().addAll(sessionCarts.get(0).contents());
        return cartRepository.save(custCart);
    }
}
