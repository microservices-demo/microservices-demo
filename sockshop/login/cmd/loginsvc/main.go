package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/go-kit/kit/log"

	"net/http"

	"github.com/weaveworks/weaveDemo/login"
	"golang.org/x/net/context"
)

func main() {
	var (
		dev    = flag.Bool("dev", false, "Dev mode.")
		port   = flag.String("port", "8081", "Port to bind HTTP listener") // TODO(pb): should be -addr, default ":8081"
		file   = flag.String("file", "/config/users.json", "Users file")
		domain = flag.String("domain", "", "Domain for the accounts service")
	)
	flag.Parse()

	// Mechanical stuff.
	errc := make(chan error)
	ctx := context.Background()
	if *dev {
		*file = "./users.json"
	}

	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
		logger = log.NewContext(logger).With("caller", log.DefaultCaller)
	}

	// Data domain.
	users, err := readFile(*file)
	if err != nil {
		logger.Log("err", err)
		os.Exit(1)
	}

	// Service domain.
	var service login.Service
	{
		service = login.NewFixedService(users, *domain)
		service = login.LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := login.MakeEndpoints(service)

	// Create and launch the HTTP server.
	go func() {
		logger.Log("transport", "HTTP", "port", *port)
		handler := login.MakeHTTPHandler(ctx, endpoints, logger)
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

func readFile(filename string) ([]login.User, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var users []login.User
	if err := json.NewDecoder(f).Decode(&users); err != nil {
		return nil, err
	}

	return users, nil
}