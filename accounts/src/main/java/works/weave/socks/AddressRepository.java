package works.weave.socks;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "address", path = "address")
public interface AddressRepository extends PagingAndSortingRepository<Address, Long> {
}

