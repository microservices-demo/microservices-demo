package works.weave.socks.cart.item;

import works.weave.socks.cart.entities.Item;

import java.util.function.Supplier;

public class FoundItem implements Supplier<Item> {
    private final ItemDAO repo;
    private final String id;

    public FoundItem(ItemDAO repo, String id) {
        this.repo = repo;
        this.id = id;
    }

    @Override
    public Item get() {
        return repo.findOne(id);
    }
}
