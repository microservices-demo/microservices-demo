---
layout: default
---

## Sock Shop via Docker Swarm + Weave Scope

Not possible at the moment. You can install Sock Shop on Docker Swarm (without Weave Scope) by following [these instructions](docker-swarm.md)

### Blockers

Currently, new Docker Swarm does not support running containers in privileged mode.
Maybe it will be allowed in the future.
Please refer to the issue [1030](https://github.com/docker/swarmkit/issues/1030#issuecomment-232299819).
This prevents running Weave Scope in a normal way, since it needs privileged mode.
A work around exists documented [here](https://github.com/weaveworks/scope-global-swarm-service)

Running global plugins is not supported either.
