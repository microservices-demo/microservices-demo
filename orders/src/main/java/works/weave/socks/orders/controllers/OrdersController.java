package works.weave.socks.orders.controllers;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.data.rest.webmvc.RepositoryRestController;
import org.springframework.hateoas.Resource;
import org.springframework.hateoas.mvc.TypeReferences;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import works.weave.socks.Shipment;
import works.weave.socks.accounts.entities.Address;
import works.weave.socks.accounts.entities.Card;
import works.weave.socks.accounts.entities.Customer;
import works.weave.socks.cart.entities.Item;
import works.weave.socks.orders.entities.CustomerOrder;
import works.weave.socks.orders.repositories.CustomerOrderRepository;
import works.weave.socks.orders.resources.NewOrderResource;
import works.weave.socks.orders.services.AsyncGetService;

import java.io.IOException;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RepositoryRestController
public class OrdersController {
    private final Logger LOG = LoggerFactory.getLogger(getClass());

    @Autowired
    private AsyncGetService asyncGetService;

    @Autowired
    private CustomerOrderRepository customerOrderRepository;

    @ResponseStatus(HttpStatus.CREATED)
    @RequestMapping(path = "/orders", consumes = MediaType.APPLICATION_JSON_VALUE, method = RequestMethod.POST)
    public void newOrder(@RequestBody NewOrderResource item) throws InterruptedException, IOException, TimeoutException, ExecutionException {
        LOG.debug("Starting calls");
        Future<Resource<Customer>> customerFuture = asyncGetService.getData(item.customer, new TypeReferences.ResourceType<Customer>() {
        });
        Future<Resource<Address>> addressFuture = asyncGetService.getData(item.address, new TypeReferences.ResourceType<Address>() {
        });
        Future<Resource<Card>> cardFuture = asyncGetService.getData(item.card, new TypeReferences.ResourceType<Card>() {
        });
        Future<List<Item>> itemsFuture = asyncGetService.getDataList(item.items, new ParameterizedTypeReference<List<Item>>() {
        });
        LOG.debug("End of calls.");

        CustomerOrder order = new CustomerOrder(
                null,
                parseId(customerFuture.get(5L, TimeUnit.SECONDS).getId().getHref()),
                customerFuture.get(5L, TimeUnit.SECONDS).getContent(),
                addressFuture.get(5L, TimeUnit.SECONDS).getContent(),
                cardFuture.get(5L, TimeUnit.SECONDS).getContent(),
                itemsFuture.get(5L, TimeUnit.SECONDS),
                Calendar.getInstance().getTime()
        );
        LOG.debug("Received data: " + order.toString());

        if (order.getCustomer() == null || order.getAddress() == null ||
                order.getCard() == null || order.getItems() == null) {
            System.out.println("Received: " + order.getAddress() + ", " + order.getCard()
                    + ", " + order.getCustomer() + ", " + order.getItems());
            throw new IllegalArgumentException("Must pass a Address, Card, Customer and Items");
        }

        CustomerOrder savedOrder = customerOrderRepository.save(order);
        LOG.debug("Saved order: " + savedOrder);

        // Call payment service to make sure they've paid
        asyncGetService.requestPayment().get(5L, TimeUnit.SECONDS);

        // Ship
        Shipment shipment = new Shipment(order.getId(), order.getCustomerId());
        asyncGetService.ship(shipment).get(5L, TimeUnit.SECONDS);
    }

    private String parseId(String href) {
        Pattern idPattern = Pattern.compile("[\\w-]+$");
        Matcher matcher = idPattern.matcher(href);
        if (!matcher.find()) {
            throw new IllegalStateException("Could not parse user ID from: " + href);
        }
        return matcher.group(0);
    }
}
