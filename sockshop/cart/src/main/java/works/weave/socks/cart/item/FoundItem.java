package works.weave.socks.cart.item;

import org.slf4j.Logger;
import works.weave.socks.cart.entities.Item;

import java.util.List;
import java.util.function.Supplier;

import static org.slf4j.LoggerFactory.getLogger;

public class FoundItem implements Supplier<Item> {
    private final Logger LOG = getLogger(getClass());
    private final Supplier<List<Item>> items;
    private final Supplier<Item> item;

    public FoundItem(Supplier<List<Item>> items, Supplier<Item> item) {
        this.items = items;
        this.item = item;
    }

    @Override
    public Item get() {
        return items.get().stream()
                .filter(item.get()::equals)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Cannot find item in cart"));
    }

    public boolean hasItem() {
        boolean present = items.get().stream()
                .filter(item.get()::equals)
                .findFirst()
                .isPresent();
        LOG.debug((present ? "Found" : "Didn't find") + " item: " + item.get() + ", in: " + items.get());
        return present;
    }
}
