package works.weave.socks.accounts.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.accounts.entities.Customer;

import java.util.List;

@RepositoryRestResource(collectionResourceRel = "customer", path = "customers")
public interface CustomerRepository extends MongoRepository<Customer, String> {
    List<Customer> findByUsername(@Param("username") String username);
}

