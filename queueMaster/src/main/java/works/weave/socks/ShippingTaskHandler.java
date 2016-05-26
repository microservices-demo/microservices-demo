package works.weave.socks;

import org.springframework.stereotype.Component;
import org.springframework.beans.factory.annotation.Autowired;

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
