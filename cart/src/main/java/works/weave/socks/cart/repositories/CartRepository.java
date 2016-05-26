package works.weave.socks.cart.repositories;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.cart.entities.Cart;

import java.util.List;

@RepositoryRestResource
public interface CartRepository extends CrudRepository<Cart, Long> {
    List<Cart> findByCustomerId(@Param("custId") long id);
}

