package works.weave.socks.orders;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.orm.jpa.EntityScan;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan({"works.weave.socks.orders.entities", "works.weave.socks.accounts.entities", "works.weave.socks.cart.entities"})
@EnableJpaRepositories({"works.weave.socks.orders.repositories", "works.weave.socks.accounts.repositories", "works.weave.socks.cart.repositories"})
public class OrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(OrderApplication.class, args);
    }
}
