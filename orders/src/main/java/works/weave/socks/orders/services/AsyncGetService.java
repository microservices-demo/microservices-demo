package works.weave.socks.orders.services;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.hateoas.Resource;
import org.springframework.hateoas.Resources;
import org.springframework.hateoas.mvc.TypeReferences;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import works.weave.socks.Shipment;
import works.weave.socks.orders.config.RestProxyTemplate;

import java.io.IOException;
import java.net.URI;
import java.util.List;
import java.util.concurrent.Future;

import static org.springframework.hateoas.MediaTypes.HAL_JSON;

@Service
public class AsyncGetService {
    private final Logger LOG = LoggerFactory.getLogger(getClass());

    private final URI paymentUri = URI.create("http://payment/paymentAuth");
    private final URI shippingUri = URI.create("http://192.168.99.102:32776/shipping");

    @Autowired
    private RestProxyTemplate restProxyTemplate;

    @Async
    public <T> Future<Resource<T>> getData(URI url, TypeReferences.ResourceType<T> type) throws InterruptedException, IOException {
        RequestEntity<Void> request = RequestEntity.get(url).accept(HAL_JSON).build();
        LOG.debug("Requesting: " + request.toString());
        Resource<T> body = restProxyTemplate.getRestTemplate().exchange(request, type).getBody();
        LOG.debug("Received: " + body.toString());
        return new AsyncResult<>(body);
    }

    @Async
    public <T> Future<Resources<T>> getDataList(URI url, TypeReferences.ResourcesType<T> type) throws InterruptedException, IOException {
        RequestEntity<Void> request = RequestEntity.get(url).accept(HAL_JSON).build();
        LOG.debug("Requesting: " + request.toString());
        Resources<T> body = restProxyTemplate.getRestTemplate().exchange(request, type).getBody();
        LOG.debug("Received: " + body.toString());
        return new AsyncResult<>(body);
    }

    @Async
    public <T> Future<List<T>> getDataList(URI url, ParameterizedTypeReference<List<T>> type) throws InterruptedException, IOException {
        RequestEntity<Void> request = RequestEntity.get(url).accept(MediaType.APPLICATION_JSON).build();
        LOG.debug("Requesting: " + request.toString());
        List<T> body = restProxyTemplate.getRestTemplate().exchange(request, type).getBody();
        LOG.debug("Received: " + body.toString());
        return new AsyncResult<>(body);
    }

    @Async
    public Future<String> requestPayment() {
        RequestEntity<String> request = RequestEntity.post(paymentUri).contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).body("{}");
        LOG.debug("Requesting: " + request.toString());
        String body = restProxyTemplate.getRestTemplate().exchange(request, String.class).getBody();
        LOG.debug("Received: " + body);
        return new AsyncResult<>(body);
    }

    @Async
    public Future<String> ship(Shipment shipment) {
// Set the Content-Type header
        RequestEntity<Shipment> request = RequestEntity.post(paymentUri).contentType(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).body(shipment);

        LOG.debug("Requesting: " + request.toString());
// Create a new RestTemplate instance
        RestTemplate restTemplate = new RestTemplate();
        restTemplate.setRequestFactory(restProxyTemplate.getRestTemplate().getRequestFactory());

// Add the Jackson and String message converters
        restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());
        restTemplate.getMessageConverters().add(new StringHttpMessageConverter());

// Make the HTTP POST request, marshaling the request to JSON, and the response to a String
        ResponseEntity<String> responseEntity = restTemplate.exchange(shippingUri, HttpMethod.POST, request, String.class);
        String result = responseEntity.getBody();
        LOG.debug("Received: " + result.toString());
        return new AsyncResult<>(result);
    }
}
