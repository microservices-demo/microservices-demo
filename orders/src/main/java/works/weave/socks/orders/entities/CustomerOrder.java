package works.weave.socks.orders.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.math.BigInteger;

// curl -XPOST -H 'Content-type: application/json' http://localhost:8082/orders -d '{"customer": "http://localhost:8080/customer/1", "address": "http://localhost:8080/address/1", "card": "http://localhost:8080/card/1", "items": "http://localhost:8081/carts/1/items"}'

// curl http://localhost:8082/orders/search/customerId\?custId\=1

@JsonIgnoreProperties(ignoreUnknown = true)
@Document
public class CustomerOrder {

    @Id
    private BigInteger id;

    private BigInteger customerId;

    // TODO: These used to be references to the other types. But in mongo, they stopped working.
    private String customer;

    private String address;

    private String card;

    private String items;

    public BigInteger getId() {
        return id;
    }

    public String getCustomer() {
        return customer;
    }

    public void setCustomer(String customer) {
        this.customer = customer;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCard() {
        return card;
    }

    public void setCard(String card) {
        this.card = card;
    }

    public String getItems() {
        return items;
    }

    public void setItems(String items) {
        this.items = items;
    }

    public BigInteger getCustomerId() {
        return customerId;
    }

    public void setCustomerId(BigInteger customerId) {
        this.customerId = customerId;
    }
}
