package works.weave.socks.cart.item;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.function.Supplier;

public class FoundItem<T> implements Supplier<T> {
    private final MongoRepository<T, String> repo;
    private final String id;

    public <REPO extends MongoRepository<T, String>> FoundItem(REPO repo, String id) {
        this.repo = repo;
        this.id = id;
    }

    @Override
    public T get() {
        return repo.findOne(id);
    }
}
