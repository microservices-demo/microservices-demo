package works.weave.socks.cart.controllers;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import works.weave.socks.cart.cart.CartDAO;
import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.cart.item.ItemDAO;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.collection.IsCollectionWithSize.hasSize;
import static org.hamcrest.collection.IsEmptyCollection.empty;
import static org.hamcrest.collection.IsIterableContainingInAnyOrder.containsInAnyOrder;
import static org.junit.Assert.assertThat;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration
public class CartsControllerTest {

    @Autowired
    private ItemsController itemsController;

    @Autowired
    private CartDAO cartDAO;

    @Autowired
    private CartsController cartsController;


    @Test
    public void shouldGetCart() {
        String customerId = "customerIdGet";
        Cart cart = new Cart(customerId);
        cartDAO.save(cart);
        Cart gotCart = cartsController.get(customerId);
        assertThat(gotCart, is(equalTo(cart)));
        assertThat(cartDAO.findByCustomerId(customerId).get(0), is(equalTo(cart)));
    }

    @Test
    public void shouldDeleteCart() {
        String customerId = "customerIdGet";
        Cart cart = new Cart(customerId);
        cartDAO.save(cart);
        cartsController.delete(customerId);
        assertThat(cartDAO.findByCustomerId(customerId), is(empty()));
    }

    @Test
    public void shouldMergeItemsInCartsTogether() {
        String customerId1 = "customerId1";
        Cart cart1 = new Cart(customerId1);
        Item itemId1 = new Item("itemId1");
        cart1.add(itemId1);
        cartDAO.save(cart1);
        String customerId2 = "customerId2";
        Cart cart2 = new Cart(customerId2);
        Item itemId2 = new Item("itemId2");
        cart2.add(itemId2);
        cartDAO.save(cart2);

        cartsController.mergeCarts(customerId1, customerId2);
        assertThat(cartDAO.findByCustomerId(customerId1).get(0).contents(), is(hasSize(2)));
        assertThat(cartDAO.findByCustomerId(customerId1).get(0).contents(), is(containsInAnyOrder(itemId1, itemId2)));
        assertThat(cartDAO.findByCustomerId(customerId2), is(empty()));
    }

    @Configuration
    static class ItemsControllerTestConfiguration {
        @Bean
        public ItemsController itemsController() {
            return new ItemsController();
        }

        @Bean
        public CartsController cartsController() {
            return new CartsController();
        }

        @Bean
        public ItemDAO itemDAO() {
            return new ItemDAO.Fake();
        }

        @Bean
        public CartDAO cartDAO() {
            return new CartDAO.Fake();
        }
    }
}