package works.weave.socks.cart.entities;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import javax.validation.constraints.NotNull;

@Document
public class Item {
    @Id
    private String id;

    @NotNull(message = "Item Id must not be null")
    public String itemId;
    public int quantity = 1;
    public float unitPrice = 0.0F;

    public void increment() {
        quantity = quantity + 1;
    }

    public void merge(Item item2) {
        quantity = item2.quantity;
    }

    @Override
    public String toString() {
        return "Item{" +
                "id='" + id + '\'' +
                ", itemId='" + itemId + '\'' +
                ", quantity=" + quantity +
                ", unitPrice=" + unitPrice +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Item item = (Item) o;

        return itemId != null ? itemId.equals(item.itemId) : item.itemId == null;
    }
}
