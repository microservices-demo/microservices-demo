package works.weave.socks.cart.entities;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

public class Cart {

    @Id
    private BigInteger id;
    private BigInteger customerId;

    @DBRef
    private List<Item> items = new ArrayList<>();

    public BigInteger getCustomerId() {
        return customerId;
    }

    public void setCustomerId(BigInteger customerId) {
        this.customerId = customerId;
    }

    public List<Item> getItems() {
        return items;
    }

    public void setItems(List<Item> items) {
        this.items = items;
    }
}
