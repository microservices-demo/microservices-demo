package works.weave.socks.cart.item;

import works.weave.socks.cart.controllers.ItemsController;
import works.weave.socks.cart.entities.Item;

import java.util.function.Supplier;

public class GetItem implements Supplier<Item> {
    private final ItemsController controller;
    private final String itemId;

    public GetItem(ItemsController controller, String itemId) {
        this.controller = controller;
        this.itemId = itemId;
    }

    public GetItem(ItemsController controller, Item item) {
        this(controller, item.itemId);
    }

    @Override
    public Item get() {
        return controller.get(itemId);
    }
}
