package works.weave.socks.orders.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import works.weave.socks.Shipment;
import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
import works.weave.socks.accounts.entities.Customer;
import works.weave.socks.cart.entities.Item;

import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.List;

// curl -XPOST -H 'Content-type: application/json' http://localhost:8082/orders -d '{"customer": "http://localhost:8080/customer/1", "address": "http://localhost:8080/address/1", "card": "http://localhost:8080/card/1", "items": "http://localhost:8081/carts/1/items"}'

// curl http://localhost:8082/orders/search/customerId\?custId\=1

@JsonIgnoreProperties(ignoreUnknown = true)
@Document
public class CustomerOrder {

    @Id
    private String id;

    private String customerId;

    private Customer customer;

    private Address address;

    private Card card;

    private Collection<Item> items;

    private Shipment shipment;

    private Date date = Calendar.getInstance().getTime();

    private float total;

    public CustomerOrder() {
    }

    public CustomerOrder(String id, String customerId, Customer customer, Address address, Card card,
                         Collection<Item> items, Shipment shipment, Date date, float total) {
        this.id = id;
        this.customerId = customerId;
        this.customer = customer;
        this.address = address;
        this.card = card;
        this.items = items;
        this.shipment = shipment;
        this.date = date;
        this.total = total;
    }

    @Override
    public String toString() {
        return "CustomerOrder{" +
                "id='" + id + '\'' +
                ", customerId='" + customerId + '\'' +
                ", customer=" + customer +
                ", address=" + address +
                ", card=" + card +
                ", items=" + items +
                ", date=" + date +
                '}';
    }

// Crappy getter setters for Jackson

    public String getId() {
        return id;
    }

    public String getCustomerId() {
        return this.customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
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

    public Collection<Item> getItems() {
        return items;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public Shipment getShipment() {
        return shipment;
    }

    public void setShipment(Shipment shipment) {
        this.shipment = shipment;
    }

    public float getTotal() {
        return total;
    }

    public void setTotal(float total) {
        this.total = total;
    }
}
