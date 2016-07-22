package works.weave.socks;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

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

    @ResponseStatus(HttpStatus.CREATED)
    @RequestMapping(value="/shipping", method=RequestMethod.POST)
    public
    @ResponseBody
    Shipment postShipping(@RequestBody Shipment shipment) {
        System.out.println("Adding shipment to queue...");
        try {
            rabbitTemplate.convertAndSend("shipping-task", shipment);
        } catch (Exception e) {
            System.out.println("Unable to add to queue (the queue is probably down). Accepting anyway. Don't do this for real!");
        }
        return shipment;
    }
}