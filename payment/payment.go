package payment

import (
	"flag"
	"fmt"
	"net/http"
	"io"
)

var port string

func main() {

	flag.StringVar(&port, "port", "8082", "Port on which to run")
	flag.Parse()

	http.HandleFunc("/paymentAuth", PaymentAuthHandler)
	fmt.Printf("Payment service running on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}

func PaymentAuthHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Header().Set("Content-Type", "application/json")
	io.WriteString(w, `{"authorised": true}`)
}
