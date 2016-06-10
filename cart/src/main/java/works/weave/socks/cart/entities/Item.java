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

    public Item() {
    }

    public Item(Item item, int quantity) {
        this.id = item.id;
        this.itemId = item.itemId;
        this.quantity = quantity;
        this.unitPrice = item.unitPrice;
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