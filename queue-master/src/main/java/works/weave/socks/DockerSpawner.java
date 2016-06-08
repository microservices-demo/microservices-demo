package works.weave.socks;

import java.lang.Exception;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.api.command.CreateContainerResponse;
import com.github.dockerjava.core.DockerClientBuilder;
import com.github.dockerjava.core.DockerClientConfig;
import com.github.dockerjava.core.command.PullImageResultCallback;
import com.github.dockerjava.core.command.ExecStartResultCallback;
import org.springframework.stereotype.Component;


@Component
public class DockerSpawner {
	
	private DockerClient dc;
	private ExecutorService dockerPool;

	private String imageName = "alpine";
	private String imageVersion = "3.1";
	private int poolSize = 50;

	public void init() {
		if (dc == null) {
			DockerClientConfig.DockerClientConfigBuilder builder = DockerClientConfig.createDefaultConfigBuilder();

            String dockerHostEnv = System.getenv("DOCKER_HOST");
            if (dockerHostEnv == null || dockerHostEnv.trim() == "") {
                builder.withUri("unix:///var/run/docker.sock");
            }

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
				System.out.println("Spawning new container");
				try {
					CreateContainerResponse container = dc.createContainerCmd(imageName + ":" + imageVersion).withCmd("sleep", "30").exec();

					dc.startContainerCmd(container.getId()).exec();
					System.out.println("Spawned container with id: " + container.getId());
					// TODO instead of just sleeping, call await on the container and remove once it's completed.
					Thread.sleep(45000);
					dc.removeContainerCmd(container.getId()).exec();
					System.out.println("Removed Container:" + container.getId());
				} catch (Exception e) {
					System.out.println("Exception !!");
				}
		    }
		});
	}
}