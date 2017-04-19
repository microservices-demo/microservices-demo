package works.weave.socks.cart.cart;

import java.util.function.Supplier;

public interface HasContents<T extends Contents> {
    Supplier<T> contents();
}
