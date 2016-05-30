package works.weave.socks.cart.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.cart.entities.Cart;

import java.math.BigInteger;
import java.util.List;

@RepositoryRestResource
public interface CartRepository extends MongoRepository<Cart, BigInteger> {
    List<Cart> findByCustomerId(@Param("custId") BigInteger id);
}

