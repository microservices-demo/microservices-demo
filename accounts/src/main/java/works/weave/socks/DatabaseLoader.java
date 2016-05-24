package works.weave.socks;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CustomerRepository customers;

    @Override
    public void run(String... strings) throws Exception {

        Customer ben = new Customer();
        ben.setFirstName("Ben");
        ben.setLastName("LastName");

        Address address = new Address();
        address.setNumber("1");
        address.setStreet("The Avenues");
        address.setCity("London");
        address.setCountry("UK");
        address.setPostcode("L10 3QD");

        ben.setAddresses(Arrays.asList(address));

        Card card = new Card();
        card.setLongNum("78542789543215432");
        card.setExpires("08/19");
        card.setCcv("894");

        ben.setCards(Arrays.asList(card));

        this.customers.save(ben);
    }
}
