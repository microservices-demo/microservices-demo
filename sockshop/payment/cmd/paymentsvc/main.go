package main

import (
	"flag"
	"fmt"
	"github.com/go-kit/kit/log"
	"github.com/weaveworks/microservices-demo/sockshop/payment"
	"golang.org/x/net/context"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	var (
		port          = flag.String("port", "8080", "Port to bind HTTP listener")
		declineAmount = flag.Float64("decline", 100, "Decline payments over certain amount")
	)
	flag.Parse()

	// Mechanical stuff.
	errc := make(chan error)
	ctx := context.Background()

	handler, logger := Handler(ctx, float32(*declineAmount))

	// Create and launch the HTTP server.
	go func() {
		logger.Log("transport", "HTTP", "port", *port)
		errc <- http.ListenAndServe(":"+*port, handler)
	}()

	// Capture interrupts.
	go func() {
		c := make(chan os.Signal)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		errc <- fmt.Errorf("%s", <-c)
	}()

	logger.Log("exit", <-errc)
}

func Handler(ctx context.Context, declineAmount float32) (http.Handler, log.Logger) {
	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
		logger = log.NewContext(logger).With("caller", log.DefaultCaller)
	}

	// Service domain.
	var service payment.Service
	{
		service = payment.NewAuthorisationService(declineAmount)
		service = payment.LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := payment.MakeEndpoints(service)

	handler := payment.MakeHTTPHandler(ctx, endpoints, logger)
	return handler, logger
}
