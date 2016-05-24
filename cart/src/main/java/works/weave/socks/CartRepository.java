package works.weave.socks;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "cart", path = "cart")
public interface CartRepository extends PagingAndSortingRepository<Cart, Long> {
}

