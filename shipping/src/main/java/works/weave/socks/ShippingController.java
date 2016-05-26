package works.weave.socks;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;

@RestController
public class ShippingController {

	@Autowired
	RabbitTemplate rabbitTemplate;

    @RequestMapping(value="/shipping", method=RequestMethod.GET)
    public String getShipping() {
        return "GET ALL Shipping Resource.";
    }

    @RequestMapping(value="/shipping/{id}", method=RequestMethod.GET)
    public String getShippingById(@PathVariable String id) {
        return "GET Shipping Resource with id: " + id;
    }
    
    @RequestMapping(value="/shipping", method=RequestMethod.POST)
    public String postShipping(@RequestBody Shipment shipment) {
    	System.out.println("Adding shipment to queue...");
        rabbitTemplate.convertAndSend("shipping-task", shipment);
        return "POST Shipping Resource. Name: " + shipment.getName() + " Id: "+ shipment.getId();
    }
}