package works.weave.socks.orders.repositories;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.repository.query.Param;
import org.springframework.data.rest.core.annotation.RepositoryRestResource;
import org.springframework.data.rest.core.annotation.RestResource;
import works.weave.socks.orders.entities.CustomerOrder;

import java.util.List;

@RepositoryRestResource(path = "orders", itemResourceRel = "order")
public interface CustomerOrderRepository extends PagingAndSortingRepository<CustomerOrder, Long> {
    @RestResource(path = "customerId")
    List<CustomerOrder> findByCustomer_Id(@Param("custId") long id);
}

