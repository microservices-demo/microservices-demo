package main

import (
	"net/http"
)

func main() {
	var port string
	port = "8080"
	http.HandleFunc("/paymentAuth", paymentAuthHandler)
	http.ListenAndServe(":" + port, nil)
}

func paymentAuthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
}