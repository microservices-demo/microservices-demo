package main

import (
	"flag"
	"fmt"
	"math/rand"
	"net/http"
	"time"
)

var port string

var rando *rand.Rand

func main() {

	s := rand.NewSource(time.Now().UnixNano())
    rando = rand.New(s)

	flag.StringVar(&port, "port", "8082", "Port on which to run")
	flag.Parse()

	http.HandleFunc("/paymentAuth", paymentAuthHandler)
	fmt.Printf("Payment service running on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}

func paymentAuthHandler(w http.ResponseWriter, r *http.Request) {
	id := rando.Intn(10000)
	fmt.Printf("Received payment auth request. Payment id=%d \n", id)
	abuseCPU(10, 20, id)
	w.WriteHeader(200)
}

func abuseCPU(n, s, id int) {
	for i := 0; i < n; i++ {
		go useful(s, id)
	}
}

func useful(s, id int) {
	fmt.Printf("payment validation attempt for id=%d\n", id)
	end := time.Now().Add(time.Second * time.Duration(s));
	count := 0
	for time.Now().Before(end) {
		count = count + 1
		count = 0
	}
	fmt.Printf("Payment authorized. ID=%d\n", id)
}