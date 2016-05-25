package works.weave.socks.orders;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import works.weave.socks.accounts.entities.Customer;
import works.weave.socks.orders.entities.CustomerOrder;
import works.weave.socks.orders.repositories.CustomerOrderRepository;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CustomerOrderRepository orders;

    @Override
    public void run(String... strings) throws Exception {
        Customer customer = new Customer();
        customer.setFirstName("AAAA");
        customer.setLastName("BBBB");
        CustomerOrder customerOrder = new CustomerOrder();
        customerOrder.setCustomer(customer);
        orders.save(customerOrder);
//            Order order = new Order(new Customer(), new Address(), new Card(), new HashSet<Item>(Arrays.asList(new Item())));
//        orders.save(order);
//
//        works.weave.socks.cart.Cart cart = new works.weave.socks.cart.Cart();
//        cart.setCustomerId(1);
//        Item item = new Item();
//        item.setItemId("fdas9342-fdsa3f-fds");
//        item.setQuantity(2);
//        Item item2 = new Item();
//        item2.setItemId("fs9-gfdsa12");
//        item2.setQuantity(1);
//        cart.setItems(new HashSet<>(Arrays.asList(item, item2)));
//        this.carts.save(cart);
    }
}
