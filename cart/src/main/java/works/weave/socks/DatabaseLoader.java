package works.weave.socks;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CartRepository carts;

    @Override
    public void run(String... strings) throws Exception {

        Cart cart = new Cart();
        cart.setCustomerId(1);
        cart.setItems(Arrays.asList("fd90a-fda9f", "fd90a-fda9f"));

        this.carts.save(cart);
    }
}
