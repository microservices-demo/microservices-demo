package works.weave.socks.cart.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.cart.entities.Item;

@RepositoryRestResource
public interface ItemRepository extends MongoRepository<Item, String> {
}

