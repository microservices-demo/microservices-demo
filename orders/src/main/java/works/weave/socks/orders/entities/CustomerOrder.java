package works.weave.socks.orders.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
import works.weave.socks.accounts.entities.Customer;

import javax.persistence.*;

// curl -XPOST -H 'Content-type: application/json' http://localhost:8082/orders -d '{"customer": "http://localhost:8080/customer/1", "address": "http://localhost:8080/address/1", "card": "http://localhost:8080/card/1", "items": "http://localhost:8081/carts/1/items"}'

// curl http://localhost:8082/orders/search/customerId\?custId\=1

@Entity
@JsonIgnoreProperties(ignoreUnknown = true)
public class CustomerOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private long id;

    @OneToOne(cascade = CascadeType.ALL, targetEntity = Customer.class)
    private Customer customer;

    @OneToOne(cascade = CascadeType.ALL, targetEntity = Address.class)
    private Address address;

    @OneToOne(cascade = CascadeType.ALL, targetEntity = Card.class)
    private Card card;

    private String items;

    public long getId() {
        return id;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Address getAddress() {
        return address;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public String getItems() {
        return items;
    }

    public void setItems(String items) {
        this.items = items;
    }
}
