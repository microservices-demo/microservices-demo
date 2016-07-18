package works.weave.socks.cart.action;

import java.util.Collection;
import java.util.function.Supplier;

public class FirstResultOrDefault<T> implements Supplier<T> {
    private final Collection<T> collection;
    private final Supplier<T> nonePresent;

    public FirstResultOrDefault(final Collection<T> collection, final Supplier<T> nonePresent) {
        this.collection = collection;
        this.nonePresent = nonePresent;
    }

    @Override
    public T get() {
        return collection.stream().findFirst().orElseGet(nonePresent);
    }
}
