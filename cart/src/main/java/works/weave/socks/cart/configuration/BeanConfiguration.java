package works.weave.socks.cart.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import works.weave.socks.cart.cart.CartDAO;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.repositories.CartRepository;

import java.util.List;

@Configuration
public class BeanConfiguration {
    @Bean
    public CartDAO getCartDao(CartRepository cartRepository) {
        return new CartDAO() {
            @Override
            public void delete(Cart cart) {
                cartRepository.delete(cart);
            }

            @Override
            public void save(Cart cart) {
                cartRepository.save(cart);
            }

            @Override
            public List<Cart> findByCustomerId(String customerId) {
                return cartRepository.findByCustomerId(customerId);
            }
        };
    }
}
