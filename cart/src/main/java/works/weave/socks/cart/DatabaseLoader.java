package works.weave.socks.cart;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.repositories.CartRepository;
import works.weave.socks.cart.repositories.ItemRepository;

import java.math.BigInteger;
import java.util.Arrays;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CartRepository carts;

    @Autowired
    private ItemRepository items;

    @Override
    public void run(String... strings) throws Exception {

        Cart cart = new Cart();
        cart.setCustomerId(BigInteger.valueOf(1L));
        Item item = new Item();
        item.setItemId("fdas9342-fdsa3f-fds");
        item.setQuantity(2);
        items.save(item);
        Item item2 = new Item();
        item2.setItemId("fs9-gfdsa12");
        item2.setQuantity(1);
        items.save(item2);
        cart.setItems(Arrays.asList(item, item2));
        this.carts.save(cart);
    }
}
