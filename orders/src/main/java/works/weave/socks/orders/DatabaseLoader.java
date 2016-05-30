//package works.weave.socks.orders;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.boot.CommandLineRunner;
//import org.springframework.stereotype.Component;
//import works.weave.socks.accounts.entities.Address;
//import works.weave.socks.accounts.entities.Card;
//import works.weave.socks.accounts.entities.Customer;
//import works.weave.socks.accounts.repositories.AddressRepository;
//import works.weave.socks.accounts.repositories.CardRepository;
//import works.weave.socks.accounts.repositories.CustomerRepository;
//import works.weave.socks.orders.entities.CustomerOrder;
//import works.weave.socks.orders.repositories.CustomerOrderRepository;
//
//import java.net.URI;
//import java.util.Arrays;
//
//@Component
//public class DatabaseLoader implements CommandLineRunner {
//    @Autowired
//    private CustomerOrderRepository orders;
//
//    @Autowired
//    private CustomerRepository customers;
//
//    @Override
//    public void run(String... strings) throws Exception {
//
//        CustomerOrder customerOrder = new CustomerOrder();
//        customerOrder.setAddress( ("http://address.com"));
//        customerOrder.setCard( ("http://card.com"));
//        Customer customer = new Customer();
//        customer.setLastName("aaa");
//        customer.setLastName("fsfre");
//        customers.save(customer);
//        customerOrder.setCustomer(customer);
//        customerOrder.setItems( ("http://items.com"));
//
//        this.orders.save(customerOrder);
//    }
//}
