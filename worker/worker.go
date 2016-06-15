package main

import (
  "flag"
  "fmt"
  "log"
  "time"

  "github.com/streadway/amqp"
)

var dev bool
var rabbitHost string = "rabbitmq:5672/"

func main() {

	fmt.Printf("Starting worker container\n")

	flag.BoolVar(&dev, "dev", false, "Run in development mode")

	if dev {
		rabbitHost = "192.168.99.102:15672/"
	}
	// Connect to rabbitmq
	fmt.Printf("Connecting to rabbitmq at %s\n", rabbitHost)

	conn, _ := amqp.Dial("amqp://guest:" + rabbitHost)
	defer conn.Close()

	// Sleep and die
	time.Sleep(30 * * time.Second)
	fmt.Printf("Container run finished.")
}