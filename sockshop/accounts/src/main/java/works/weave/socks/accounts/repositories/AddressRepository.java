package works.weave.socks.accounts.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.accounts.entities.Address;

@RepositoryRestResource(collectionResourceRel = "address", path = "addresses")
public interface AddressRepository extends MongoRepository<Address, String> {
}

