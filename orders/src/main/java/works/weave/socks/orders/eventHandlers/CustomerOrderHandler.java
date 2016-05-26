package works.weave.socks.orders.eventHandlers;

import com.mashape.unirest.http.Unirest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.rest.core.annotation.HandleBeforeCreate;
import org.springframework.data.rest.core.annotation.RepositoryEventHandler;
import org.springframework.data.rest.webmvc.support.RepositoryEntityLinks;
import org.springframework.stereotype.Component;
import works.weave.socks.orders.entities.CustomerOrder;

@Component
@RepositoryEventHandler
public class CustomerOrderHandler {
    @Autowired
    private RepositoryEntityLinks entityLinks;

    /**
     * Called before {@link CustomerOrder} is persisted
     *
     * @param order
     */
    @HandleBeforeCreate
    public void handleBeforeSave(CustomerOrder order) {
        if (order.getCustomer() == null || order.getAddress() == null ||
                order.getCard() == null || order.getItems() == null) {
            System.out.println("Received: " + order.getAddress() + ", " + order.getCard()
                    + ", " + order.getCustomer() + ", " + order.getItems());
            throw new IllegalArgumentException("Must pass a Address, Card, Customer and Items");
        }

        // Call payment service to make sure they've paid
        try {
            Unirest.post("http://payment/paymentAuth")
                    .body("{}")
                    .asJson();
        } catch (Exception e) {
            throw new IllegalStateException("Unable to create payment: " + e.getCause().toString(), e);
        }

        // Ship
        try {
            String self = entityLinks.linkToSingleResource(CustomerOrder.class, order.getId()).getHref();
            System.out.println("URL " + self);
            Unirest.post("http://shipping/shipping")
                    .body("{ \"order\": \"" + self + "\" }")
                    .asJson();
        } catch (Exception e) {
            throw new IllegalStateException("Unable to create new shipment: " + e.getCause().toString(), e);
        }
    }
}
