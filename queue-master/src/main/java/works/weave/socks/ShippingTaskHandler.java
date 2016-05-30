package works.weave.socks;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class ShippingTaskHandler {

	@Autowired
	DockerSpawner docker;

	public void handleMessage(Shipment shipment) {
		System.out.println("Received shipment task: " + shipment.getName());
		docker.init();
		docker.spawn();
	}
}
