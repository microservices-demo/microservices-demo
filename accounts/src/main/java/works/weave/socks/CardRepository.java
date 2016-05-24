package works.weave.socks;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;

@RepositoryRestResource(collectionResourceRel = "card", path = "card")
public interface CardRepository extends PagingAndSortingRepository<Card, Long> {
}

