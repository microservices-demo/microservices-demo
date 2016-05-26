package works.weave.socks.cart.repositories;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.cart.entities.Item;

@RepositoryRestResource(collectionResourceRel = "items", path = "items")
public interface ItemRepository extends CrudRepository<Item, Long> {
}

