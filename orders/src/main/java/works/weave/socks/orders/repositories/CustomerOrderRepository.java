package works.weave.socks.orders.repositories;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import works.weave.socks.orders.entities.CustomerOrder;

@RepositoryRestResource(path = "orders", itemResourceRel = "order")
public interface CustomerOrderRepository extends PagingAndSortingRepository<CustomerOrder, Long> {
}

