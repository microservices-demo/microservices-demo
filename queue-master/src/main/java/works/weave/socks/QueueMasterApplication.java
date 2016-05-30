package works.weave.socks;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class QueueMasterApplication implements CommandLineRunner {

	final static String queueName = "shipping-task";

	@Autowired
	RabbitTemplate rabbitTemplate;

	public static void main(String[] args) throws InterruptedException {
		SpringApplication.run(QueueMasterApplication.class, args);
	}

	@Bean
	Queue queue() {
		return new Queue(queueName, false);
	}

	@Bean
	TopicExchange exchange() {
		return new TopicExchange("shipping-task-exchange");
	}

	@Bean
	Binding binding(Queue queue, TopicExchange exchange) {
		return BindingBuilder.bind(queue).to(exchange).with(queueName);
	}

    @Override
    public void run(String... args) throws Exception {
        System.out.println("Starting QueueMasterApplication...");
    }
}
