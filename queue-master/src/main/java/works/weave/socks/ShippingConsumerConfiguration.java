package works.weave.socks;

import org.springframework.amqp.core.Queue;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.amqp.rabbit.listener.adapter.MessageListenerAdapter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ShippingConsumerConfiguration extends RabbitMqConfiguration
{
	protected final String queueName = "shipping-task";

    @Autowired
    private ShippingTaskHandler shippingTaskHandler;

	@Bean
	public RabbitTemplate rabbitTemplate() {
		RabbitTemplate template = new RabbitTemplate(connectionFactory());
		template.setQueue(this.queueName);
        template.setMessageConverter(jsonMessageConverter());
		return template;
	}

    @Bean
	public Queue queueName() {
		return new Queue(this.queueName, false);
	}

	@Bean
	public SimpleMessageListenerContainer listenerContainer() {
		SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
		container.setConnectionFactory(connectionFactory());
		container.setQueueNames(this.queueName);
		container.setMessageListener(messageListenerAdapter());

		return container;
	}

    @Bean
    public MessageListenerAdapter messageListenerAdapter() {
        return new MessageListenerAdapter(shippingTaskHandler, jsonMessageConverter());
    }
}