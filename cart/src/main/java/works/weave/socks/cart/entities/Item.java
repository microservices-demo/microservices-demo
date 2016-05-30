package works.weave.socks.cart.entities;

import org.springframework.data.annotation.Id;

import java.math.BigInteger;

public class Item {
    @Id
    private BigInteger id;

    private String itemId;
    private int quantity;

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String id) {
        this.itemId = id;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
