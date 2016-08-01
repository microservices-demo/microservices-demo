job "weavedemo" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  # - frontend #
  group "frontend" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - frontend app - #
    task "front-end" {
      driver = "docker"

      config {
        image = "weaveworksdemos/front-end"
        hostname = "front-end.weave.local"
        network_mode = "external"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-front-end"
        tags = ["frontend", "front-end"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 128 # 128MB
        network {
          mbits = 10
        }
      }
    }
    # - end frontend app - #

    # - edge-router - #
    task "edgerouter" {
      driver = "docker"

      config {
        image = "weaveworksdemos/edge-router"
        hostname = "edge-router.weave.local"
        network_mode = "external"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
        port_map = {
          http = 80
          https = 443
        }
      }

      service {
        name = "${TASKGROUP}-edgerouter"
        tags = ["router", "edgerouter"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 32 # 32MB
        network {
          mbits = 10
          port "http" {
            static = 80
          }
          port "https" {
            static = 443
          }
        }
      }
    } # - end edge-router - #
  } # - end frontend - #

  # - accounts - #
  group "accounts" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "accounts" {
      driver = "docker"

      config {
        image = "weaveworksdemos/accounts"
        hostname = "accounts.weave.local"
        network_mode = "secure"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-accounts"
        tags = ["accounts"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }
    } # - end app - #

    # - db - #
    task "accountsdb" {
      driver = "docker"

      config {
        image = "mongo"
        hostname = "accounts-db.weave.local"
        network_mode = "secure"
      }

      service {
        name = "${TASKGROUP}-accountsdb"
        tags = ["db", "accounts", "accountsdb"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 96 # 96MB
        network {
          mbits = 10
        }
      }
    } # - end db - #
  } # - end accounts - #

  # - catalogue - #
  group "catalogue" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "catalogue" {
      driver = "docker"

      config {
        image = "weaveworksdemos/catalogue"
        hostname = "catalogue.weave.local"
        network_mode = "external"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-catalogue"
        tags = ["frontend", "front-end", "catalogue"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 32 # 32MB
        network {
          mbits = 10
        }
      }
    } # - end app - #
  } # - end catalogue - #

  # - cart - #
  group "cart" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "cart" {
      driver = "docker"

      config {
        image = "weaveworksdemos/cart"
        hostname = "cart.weave.local"
        network_mode = "internal"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-cart"
        tags = ["cart"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }
    } # - end app - #

    # - db - #
    task "cartdb" {
      driver = "docker"

      config {
        image = "mongo"
        hostname = "cart-db.weave.local"
        network_mode = "internal"
      }

      service {
        name = "${TASKGROUP}-cartdb"
        tags = ["db", "cart", "cartdb"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 128 # 128MB
        network {
          mbits = 10
        }
      }
    } # - end db - #
  } # - end cart - #

  # - shipping - #
  group "shipping" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "shipping" {
      driver = "docker"

      config {
        image = "weaveworksdemos/shipping"
        hostname = "shipping.weave.local"
        network_mode = "backoffice"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-shipping"
        tags = ["shipping"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }
    } # - end app - #
  } # - end shipping - #

  # - login - #
  group "login" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "login" {
      driver = "docker"

      config {
        image = "weaveworksdemos/login"
        hostname = "login.weave.local"
        network_mode = "secure"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-login"
        tags = ["login"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 16 # 16MB
        network {
          mbits = 10
        }
      }
    } # - end app - #
  } # - end login - #

  # - payment - #
  group "payment" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "payment" {
      driver = "docker"

      config {
        image = "weaveworksdemos/payment"
        hostname = "payment.weave.local"
        network_mode = "secure"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-payment"
        tags = ["payment"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 16 # 16MB
        network {
          mbits = 10
        }
      }
    } # - end app - #
  } # - end payment - #


  # - orders - #
  group "orders" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - app - #
    task "orders" {
      driver = "docker"

      config {
        image = "weaveworksdemos/orders"
        hostname = "orders.weave.local"
        network_mode = "internal"
        dns_servers = ["172.17.0.1"]
        dns_search_domains = ["weave.local."]
      }

      service {
        name = "${TASKGROUP}-orders"
        tags = ["orders"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }
    } # - end app - #

    # - db - #
    task "ordersdb" {
      driver = "docker"

      config {
        image = "mongo"
        hostname = "orders-db.weave.local"
        network_mode = "internal"
      }

      service {
        name = "${TASKGROUP}-orders"
        tags = ["db", "orders", "ordersdb"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 64 # 64MB
        network {
          mbits = 10
        }
      }
    } # - end db - #
  } # - end orders - #

  # - queue-master #
  group "queue-master" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - queue-master app - #
    task "queue-master" {
      driver = "raw_exec"

      config {
        command = "/usr/bin/docker"
        args = ["run", "--name", "queue-master-${NOMAD_ALLOC_ID}", "--volume", "/var/run/docker.sock:/var/run/docker.sock", "--restart", "always", "--dns", "172.17.0.1", "--dns-search", "weave.local.", "--net", "backoffice", "--hostname", "queue-master.weave.local", "weaveworksdemos/queue-master"]
      }

      service {
        name = "${TASKGROUP}-container"
        tags = ["queuemaster"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 256 # 256MB
        network {
          mbits = 10
        }
      }
    } # - end queue-master app - #
  } # - end queue-master - #

  # - rabbitmq - #
  group "rabbitmq" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    # - proc - #
    task "rabbitmq" {
      driver = "docker"

      config {
        image = "rabbitmq:3"
        hostname = "rabbitmq.weave.local"
        network_mode = "backoffice"
      }

      service {
        name = "${TASKGROUP}-rabbitmq"
        tags = ["db"]
      }

      resources {
        cpu = 100 # 100 Mhz
        memory = 160 # 160MB
        network {
          mbits = 10
        }
      }
    } # - end proc - #
  } # - end rabbitmq - #
}
