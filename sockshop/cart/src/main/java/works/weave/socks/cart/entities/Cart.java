package works.weave.socks.cart.entities;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.DBRef;
import org.springframework.data.mongodb.core.mapping.Document;

import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;

@Document
public class Cart {
    @NotNull
    public String customerId; // Public instead of getters/setters.
    @Id
    private String id;
    @DBRef
    private List<Item> items = new ArrayList<>();

    public Cart(String customerId) {
        this.customerId = customerId;
    }

    public Cart() {
        this(null);
    }

    public List<Item> contents() {
        return items;
    }

    public Cart add(Item item) {
        items.add(item);
        return this;
    }

    public Cart remove(Item item) {
        items.remove(item);
        return this;
    }

    @Override
    public String toString() {
        return "Cart{" +
                "id='" + id + '\'' +
                ", customerId='" + customerId + '\'' +
                ", items=" + items +
                '}';
    }
}