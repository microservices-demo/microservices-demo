package works.weave.socks.orders;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
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
        Card card = new Card();
        card.setLongNum("54254");
        card.setCcv("321");
        Address address = new Address();
        address.setCity("fdsfds");
        address.setCountry("UK");
        CustomerOrder customerOrder = new CustomerOrder();
        customerOrder.setCustomer(customer);
        customerOrder.setCard(card);
        customerOrder.setAddress(address);
        orders.save(customerOrder);
    }
}
