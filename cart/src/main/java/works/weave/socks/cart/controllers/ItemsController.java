package works.weave.socks.cart.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import works.weave.socks.cart.cart.*;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.item.*;
import works.weave.socks.cart.repositories.ItemRepository;

import java.util.List;
import java.util.function.Supplier;

@RestController
@RequestMapping(value = "/carts/{customerId:.*}/items")
public class ItemsController {
    @Autowired
    private ItemRepository itemRepository;

    @Autowired
    private CartsController cartsController;

    @Autowired
    private CartDAO cartDAO;

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(value = "/{itemId:.*}", produces = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.GET)
    public Item get(@PathVariable String itemId) {
        return new FoundItem<>(itemRepository, itemId).get();
    }

    @ResponseStatus(HttpStatus.OK)
    @RequestMapping(produces = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.GET)
    public List<Item> getItems(@PathVariable String customerId) {
        return cartsController.get(customerId).contents();
    }

    @ResponseStatus(HttpStatus.CREATED)
    @RequestMapping(consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.POST)
    public void addToCart(@PathVariable String customerId, @RequestBody Item item) {
        // Get stored item. Will add if it doesn't exist.
        Supplier<Item> storedItem = new ItemResource(itemRepository, new GetItem(this, item)).value();

        // Add item to cart. Will increment if it already exists in the cart.
        new CartResource(cartDAO, customerId).contents().get().add(storedItem.get());
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(value = "/{itemId:.*}", method = RequestMethod.DELETE)
    public void removeItem(@PathVariable String customerId, @PathVariable String itemId) {
        // Remove item from cart
        Supplier<Item> storedItem = new GetItem(this, itemId);
        new CartResource(cartDAO, customerId).contents().get().delete(storedItem.get()).run();

        // Remove item from item repository
        new ItemResource(itemRepository, storedItem).destroy().run();
    }

    @ResponseStatus(HttpStatus.ACCEPTED)
    @RequestMapping(consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.PATCH)
    public void updateItem(@PathVariable String customerId, @RequestBody Item item) {
        // Merge old and new items
        Supplier<Item> storedItem = new GetItem(this, item);
        new ItemResource(itemRepository, storedItem).merge(item);

        // Save new merged item
        addToCart(customerId, storedItem.get());
    }
}
