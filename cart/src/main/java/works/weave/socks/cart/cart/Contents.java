package works.weave.socks.cart.cart;

import java.util.List;
import java.util.function.Supplier;

public interface Contents<T> {
    Supplier<List<T>> contents();

    Runnable add(T type);

    Runnable delete(T type);
}
