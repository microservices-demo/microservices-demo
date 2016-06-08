package works.weave.socks.cart.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.repositories.CartRepository;
import works.weave.socks.cart.repositories.ItemRepository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping(value = "/carts/{customerId:.*}/items")
public class ItemsController {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private CartRepository cartRepository;

    @Autowired
    private ItemRepository itemRepository;

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.GET)
    public List<Item> getItems(@PathVariable String customerId) {
        logger.debug("Items in cart: " + customersCart(customerId).contents());
        return customersCart(customerId).contents();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(value = "/{itemId:.*}", method = RequestMethod.DELETE)
    public void deleteItem(@PathVariable String customerId, @PathVariable String itemId) {
        Cart cart = customersCart(customerId);
        logger.debug("Removing " + itemId + " from " + cart);
        List<Item> toDelete = cart.contents().stream()
                .filter(i -> i.itemId.equals(itemId))
                .collect(Collectors.toList());
        toDelete.forEach(cart::remove);
        cartRepository.save(cart);
        logger.debug("Removing " + itemId + " from item repository");
        toDelete.forEach(itemRepository::delete);
    }

    @RequestMapping(consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.PATCH)
    public ResponseEntity updateItem(@PathVariable String customerId, @RequestBody Item item) {
        logger.debug("Updating " + item + " into customer with id: " + customerId);
        Optional<Item> foundItem = customersCart(customerId).contents().stream()
                .filter(item::equals)
                .peek(i -> i.merge(item))
                .findFirst();
        if (foundItem.isPresent()) {
            itemRepository.save(foundItem.get());
            return ResponseEntity.accepted().body(null);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @ResponseStatus(HttpStatus.CREATED)
    @RequestMapping(consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.POST)
    public void addToCart(@PathVariable String customerId, @RequestBody Item item) {
        logger.debug("Saving " + item + " into customer with id: " + customerId);
        Optional<Item> currentItem = customersCart(customerId).contents().stream()
                .filter(item::equals)
                .peek(Item::increment)  // If it exists, increment.
                .peek(itemRepository::save)  // If it exists, save.
                .findFirst();
        if (!currentItem.isPresent()) {
            Item savedItem = itemRepository.save(item);
            cartRepository.save(this.customersCart(customerId).add(savedItem));
        }
    }

    private Cart customersCart(String customerId) {
        return cartRepository.findByCustomerId(customerId).stream().findFirst().orElseGet(() -> {
            logger.debug("New cart created for user: " + customerId);
            return cartRepository.save(new Cart(customerId));
        });
    }
}
