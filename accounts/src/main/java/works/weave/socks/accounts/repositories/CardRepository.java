package works.weave.socks.accounts.repositories;

import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.accounts.entities.Card;

import java.math.BigInteger;

@RepositoryRestResource(collectionResourceRel = "card", path = "cards")
public interface CardRepository extends MongoRepository<Card, BigInteger> {
}

