package works.weave.socks;

import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

import java.util.List;

@RepositoryRestResource
public interface CartRepository extends CrudRepository<Cart, Long> {
    List<Cart> findByCustomerId(@Param("custId") long id);
}

