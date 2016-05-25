package works.weave.socks;

import java.util.concurrent.CountDownLatch;
import org.springframework.stereotype.Component;

@Component
public class ShippingTaskHandler {

	// private CountDownLatch latch = new CountDownLatch(1);

	public void handleMessage(Shipment shipment) {
		System.out.println("Received shipment task" + shipment.getName());
		// TODO Spawn new worker container
		// latch.countDown();
	}

	// public CountDownLatch getLatch() {
		// return latch;
	// }

}
