package works.weave.socks.accounts;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
import works.weave.socks.accounts.entities.Customer;
import works.weave.socks.accounts.repositories.AddressRepository;
import works.weave.socks.accounts.repositories.CardRepository;
import works.weave.socks.accounts.repositories.CustomerRepository;

import java.util.Arrays;

@Component
public class DatabaseLoader implements CommandLineRunner {
    @Autowired
    private CustomerRepository customers;
    @Autowired
    private AddressRepository addresses;
    @Autowired
    private CardRepository cards;

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

        Address save = addresses.save(address);

        ben.setAddresses(Arrays.asList(save));

        Card card = new Card();
        card.setLongNum("78542789543215432");
        card.setExpires("08/19");
        card.setCcv("894");

        Card save1 = cards.save(card);

        ben.setCards(Arrays.asList(save1));

        this.customers.save(ben);
    }
}
