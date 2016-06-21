package main

import (
  "flag"
  "fmt"
  "log"
  "time"

  "github.com/streadway/amqp"
)

var dev bool
var rabbitHost string = "rabbitmq/"

func main() {

	log.Printf("Starting worker container\n")

	flag.BoolVar(&dev, "dev", false, "Run in development mode")

	if dev {
		rabbitHost = "192.168.99.102:15672/"
	}
	// Connect to rabbitmq
	log.Printf("Connecting to rabbitmq at %s\n", rabbitHost)

	conn, err := amqp.Dial("amqp://guest:guest@" + rabbitHost)

	if err != nil {
		panic(err)
		log.Fatalf("Unable to connect to rabbitmq: %s", err)
		panic(fmt.Sprintf("Unable to connect to rabbitmq: %s", err))
	}
	defer conn.Close()

	// Sleep and die... a true nihilist container
	time.Sleep(30 * time.Second)
	log.Printf("Container run finished.\n")
}