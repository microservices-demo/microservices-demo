package works.weave.socks.orders.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import works.weave.socks.orders.eventHandlers.CustomerOrderHandler;

@Configuration
public class RepositoryConfiguration {

    /**
     * Declare an instance of the {@link CustomerOrderHandler}
     *
     * @return
     */
    @Bean
    CustomerOrderHandler agentEvenHandler() {
        System.out.println("Created customer event handler");
        return new CustomerOrderHandler();
    }
}
