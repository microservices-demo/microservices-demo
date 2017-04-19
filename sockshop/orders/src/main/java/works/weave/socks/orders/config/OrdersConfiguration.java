package works.weave.socks.orders.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OrdersConfiguration {
    @Bean
    @ConditionalOnMissingBean(OrdersConfigurationProperties.class)
    public OrdersConfigurationProperties frameworkMesosConfigProperties() {
        return new OrdersConfigurationProperties();
    }
}
