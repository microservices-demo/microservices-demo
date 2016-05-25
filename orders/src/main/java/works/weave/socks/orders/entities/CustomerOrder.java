package works.weave.socks.orders.entities;

import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
import works.weave.socks.accounts.entities.Customer;
import works.weave.socks.cart.entities.Item;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Entity
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

    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Item> items = new HashSet<>();

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

    public Set<Item> getItems() {
        return items;
    }

    public void setItems(Set<Item> items) {
        this.items = items;
    }
}
