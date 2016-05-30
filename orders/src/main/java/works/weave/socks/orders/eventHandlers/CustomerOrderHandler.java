package works.weave.socks.orders.eventHandlers;

import com.mashape.unirest.http.HttpResponse;
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
            // We haven't actually written this to the db yet, so it doesn't have a link...
            System.out.println("Posting to shipping");
            HttpResponse<String> jsonNodeHttpResponse = Unirest.post("http://shipping/shipping")
                    .header("Content-type", "application/json")
                    .body("{ \"customerId\": \"" + order.getCustomerId() + "\", \"name\": \"" + order.getCustomerId() + "\" }")
                    .asString();
            System.out.println("Response: " + jsonNodeHttpResponse.getBody());
            if (jsonNodeHttpResponse.getStatus() > 202) {
                throw new IllegalStateException(jsonNodeHttpResponse.getBody());
            }
        } catch (Exception e) {
            throw new IllegalStateException("Unable to create new shipment.", e);
        }
    }
}
