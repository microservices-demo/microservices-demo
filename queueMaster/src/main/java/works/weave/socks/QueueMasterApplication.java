package works.weave.socks;

import java.util.concurrent.TimeUnit;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.amqp.rabbit.listener.adapter.MessageListenerAdapter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class QueueMasterApplication implements CommandLineRunner {

	final static String queueName = "shipping-task";

	@Autowired
	RabbitTemplate rabbitTemplate;

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

	// @Bean
	// SimpleMessageListenerContainer container(ConnectionFactory connectionFactory, MessageListenerAdapter listenerAdapter) {
	// 	SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
	// 	container.setConnectionFactory(connectionFactory);
	// 	container.setQueueNames(queueName);
	// 	container.setMessageListener(listenerAdapter);
	// 	return container;
	// }

 //    @Bean
 //    ShippingTaskReceiver receiver() {
 //        return new ShippingTaskReceiver();
 //    }

	// @Bean
	// MessageListenerAdapter listenerAdapter(ShippingTaskReceiver receiver) {
	// 	return new MessageListenerAdapter(receiver, "receiveMessage");
	// }

    public static void main(String[] args) throws InterruptedException {
        SpringApplication.run(QueueMasterApplication.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("Starting QueueMasterApplication...");
        // Thread.sleep(5000);
        // System.out.println("Sending message...");
        // rabbitTemplate.convertAndSend(queueName, "Hello from RabbitMQ!");
        // receiver().getLatch().await(10000, TimeUnit.MILLISECONDS);
    }
}
