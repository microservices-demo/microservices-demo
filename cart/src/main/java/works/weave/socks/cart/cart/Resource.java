package works.weave.socks.cart.cart;

import works.weave.socks.cart.entities.Cart;
import works.weave.socks.cart.entities.Item;

import java.util.function.Supplier;

public interface Resource<T> {
    Runnable destroy();

    Runnable create();

    Supplier<T> value();

    Runnable merge(T toMerge);

    class CartFake implements Resource<Cart> {
        private final String customerId;
        private Cart cart = null;

        public CartFake(String customerId) {
            this.customerId = customerId;
        }

        @Override
        public Runnable destroy() {
            return () -> cart = null;
        }

        @Override
        public Runnable create() {
            return () -> new Cart(customerId);
        }

        @Override
        public Supplier<Cart> value() {
            if (cart == null) {
                create().run();
            }
            return () -> cart;
        }

        @Override
        public Runnable merge(Cart toMerge) {
            return null;
        }
    }
}
