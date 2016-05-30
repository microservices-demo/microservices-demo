package main

import (
	"flag"
	"fmt"
	"net/http"
)

var port string

func main() {

	flag.StringVar(&port, "port", "8082", "Port on which to run")
	flag.Parse()

	http.HandleFunc("/paymentAuth", paymentAuthHandler)
	fmt.Printf("Payment service running on port %s\n", port)
	http.ListenAndServe(":" + port, nil)
}

func paymentAuthHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Printf("Received payment auth request... Authorized.\n")
	w.WriteHeader(200)
}