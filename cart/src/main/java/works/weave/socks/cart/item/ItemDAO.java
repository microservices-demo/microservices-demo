package works.weave.socks.cart.item;

import works.weave.socks.cart.entities.Item;

import java.util.HashMap;
import java.util.Map;

public interface ItemDAO {
    void save(Item item);

    void destroy(Item item);

    Item findOne(String id);

    class Fake implements ItemDAO {
        private Map<String, Item> store = new HashMap<>();

        @Override
        public void save(Item item) {
            store.put(item.itemId, item);
        }

        @Override
        public void destroy(Item item) {
            store.remove(item.itemId);

        }

        @Override
        public Item findOne(String id) {
            return store.get(id);
        }
    }
}
