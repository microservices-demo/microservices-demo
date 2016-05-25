package works.weave.socks.cart;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.repositories.CartRepository;

import java.util.Arrays;
import java.util.HashSet;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CartRepository carts;

    @Override
    public void run(String... strings) throws Exception {

        Cart cart = new Cart();
        cart.setCustomerId(1);
        Item item = new Item();
        item.setItemId("fdas9342-fdsa3f-fds");
        item.setQuantity(2);
        Item item2 = new Item();
        item2.setItemId("fs9-gfdsa12");
        item2.setQuantity(1);
        cart.setItems(new HashSet<>(Arrays.asList(item, item2)));
        this.carts.save(cart);
    }
}
