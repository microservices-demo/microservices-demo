package works.weave.socks;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.api.command.CreateContainerResponse;
import com.github.dockerjava.api.model.Network;
import com.github.dockerjava.core.DockerClientBuilder;
import com.github.dockerjava.core.DockerClientConfig;
import com.github.dockerjava.core.command.PullImageResultCallback;
import com.github.dockerjava.core.command.ExecStartResultCallback;
import org.springframework.stereotype.Component;

import java.lang.Exception;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.List;

@Component
public class DockerSpawner {
    private final Logger logger = LoggerFactory.getLogger(this.getClass());

	private DockerClient dc;
	private ExecutorService dockerPool;

	// private String imageName = "alpine";
	private String imageName = "weaveworksdemos/worker";
	// private String imageVersion = "3.1";
	private String imageVersion = "latest";
	private String networkId = "weavedemo_backoffice";
	private int poolSize = 50;

	public void init() {
		if (dc == null) {
			DockerClientConfig.DockerClientConfigBuilder builder = DockerClientConfig.createDefaultConfigBuilder();

			// TODO from previous version of dockerjava
            // String dockerHostEnv = System.getenv("DOCKER_HOST");
            // if (dockerHostEnv == null || dockerHostEnv.trim() == "") {
                // builder.withUri("unix:///var/run/docker.sock");
            // }

            DockerClientConfig config = builder.build();
            dc = DockerClientBuilder.getInstance(config).build();

            dc.pullImageCmd(imageName).withTag(imageVersion).exec(new PullImageResultCallback()).awaitSuccess();
		}
		if (dockerPool == null) {
			dockerPool = Executors.newFixedThreadPool(poolSize);
		}
	}

	public void spawn() {
		dockerPool.execute(new Runnable() {
		    public void run() {
				logger.debug("Spawning new container");
				try {
					CreateContainerResponse container = dc.createContainerCmd(imageName + ":" + imageVersion).withNetworkMode(networkId).withCmd("ping", "rabbitmq").exec();
					// CreateContainerResponse container = dc.createContainerCmd(imageName + ":" + imageVersion).withNetworkMode(networkId).withCmd("sleep", "30").exec();
					String containerId = container.getId();
					dc.startContainerCmd(containerId).exec();
					logger.debug("Spawned container with id: " + container.getId() + " on network: " + networkId);
					// TODO instead of just sleeping, call await on the container and remove once it's completed.
					Thread.sleep(45000);
					dc.removeContainerCmd(container.getId()).exec();
					logger.debug("Removed Container:" + container.getId());
				} catch (Exception e) {
					logger.error("Exception trying to launch new container. " + e);
				}
		    }
		});
	}
}