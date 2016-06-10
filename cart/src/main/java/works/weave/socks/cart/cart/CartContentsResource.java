package works.weave.socks.cart.cart;

import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;

import java.util.List;
import java.util.Optional;
import java.util.function.Supplier;

public class CartContentsResource implements Contents<Item> {
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
    public Runnable add(Item item) {
        return () -> {
            Optional<Item> first = contents().get().stream().filter(item::equals).findFirst();
            if (first.isPresent()) {
                add(new Item(item, item.quantity + 1));
                delete(item);
            } else {
                contents().get().add(item);
            }
            cartRepository.save(parentCart());
        };
    }

    @Override
    public Runnable delete(Item item) {
        return () -> {
            contents().get().remove(item);
            cartRepository.save(parentCart());
        };
    }

    private Cart parentCart() {
        return parent.get().value().get();
    }
}
