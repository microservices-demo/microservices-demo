package works.weave.socks;

import com.github.dockerjava.api.command.CreateContainerResponse;
import com.github.dockerjava.api.DockerClient;
import com.github.dockerjava.core.DockerClientBuilder;
import com.github.dockerjava.core.DockerClientConfig;
import org.springframework.stereotype.Component;

@Component
public class DockerSpawner {
	
	private DockerClient dc;

	public void init() {
		if (dc == null) {
			DockerClientConfig.DockerClientConfigBuilder builder = DockerClientConfig.createDefaultConfigBuilder();

            String dockerHostEnv = System.getenv("DOCKER_HOST");
            if (dockerHostEnv == null || dockerHostEnv.trim() == "") {
                builder.withUri("unix:///var/run/docker.sock");
            }

            DockerClientConfig config = builder.build();
            dc = DockerClientBuilder.getInstance(config).build();
			// dc = DockerClientBuilder.getInstance("http://localhost:2375").build();
		}
	}

	public void spawn() {
		System.out.println("Spawning new container");
		CreateContainerResponse container = dc.createContainerCmd("alpine:3.1").withCmd("sleep", "30").exec();

		dc.startContainerCmd(container.getId()).exec();
		// dc.stopContainerCmd(container.getId()).exec();
		// dc.waitContainerCmd(container.getId()).exec();
		System.out.println("Finished spawn.");
	}
}