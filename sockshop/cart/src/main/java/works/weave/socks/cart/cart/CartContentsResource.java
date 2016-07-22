package works.weave.socks.cart.cart;

import org.slf4j.Logger;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;

import java.util.List;
import java.util.function.Supplier;

import static org.slf4j.LoggerFactory.getLogger;

public class CartContentsResource implements Contents<Item> {
    private final Logger LOG = getLogger(getClass());

    private final CartDAO cartRepository;
    private final Supplier<Resource<Cart>> parent;

    public CartContentsResource(CartDAO cartRepository, Supplier<Resource<Cart>> parent) {
        this.cartRepository = cartRepository;
        this.parent = parent;
    }

    @Override
    public Supplier<List<Item>> contents() {
        return () -> parentCart().contents();
    }

    @Override
    public Runnable add(Supplier<Item> item) {
        return () -> {
            LOG.debug("Adding for user: " + parent.get().value().get().toString() + ", " + item.get());
            cartRepository.save(parentCart().add(item.get()));
        };
    }

    @Override
    public Runnable delete(Supplier<Item> item) {
        return () -> {
            LOG.debug("Deleting for user: " + parent.get().value().get().toString() + ", " + item.get());
            cartRepository.save(parentCart().remove(item.get()));
        };
    }

    private Cart parentCart() {
        return parent.get().value().get();
    }
}
