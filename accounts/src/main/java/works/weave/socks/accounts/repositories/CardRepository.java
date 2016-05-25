package works.weave.socks.accounts.repositories;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.accounts.entities.Card;

@RepositoryRestResource(collectionResourceRel = "card", path = "card")
public interface CardRepository extends PagingAndSortingRepository<Card, Long> {
}

