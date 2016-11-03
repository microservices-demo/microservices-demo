# Documentation
This directory contains the deployment and internal documentation.

Both are published on https://microservices-demo.github.io/microservices-demo/.

The `local-server.sh` script starts a jekyll server to facilitate previews of the pages.
Note that it mounts `_config.yml.dev` in the place of `_config.yml`, to enable local linking;
otherwise the github.io host is prefixed to all links.

# Executable deployment specifications.
The files in the [deployment](deployment/) directory (potentially) contain executable deployment test
specifications, embedded via HTML comments in the markdown files. See the [doc-tests](../doc-tests)
directory for more information.
