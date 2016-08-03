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

	"sort"

	"github.com/weaveworks/weaveDemo/catalogue"
	"golang.org/x/net/context"
	"path/filepath"
)

func main() {
	var (
		dev    = flag.Bool("dev", false, "Shortcut for -file=./socks.json")
		port   = flag.String("port", "8081", "Port to bind HTTP listener") // TODO(pb): should be -addr, default ":8081"
		file   = flag.String("file", "/config/socks.json", "Socks file")
		images = flag.String("images", "./images/", "Image path")
	)
	flag.Parse()

	fmt.Fprintf(os.Stderr, "images: %q\n", *images)
	abs, err := filepath.Abs(*images)
	fmt.Fprintf(os.Stderr, "Abs(images): %q (%v)\n", abs, err)
	pwd, err := os.Getwd()
	fmt.Fprintf(os.Stderr, "Getwd: %q (%v)\n", pwd, err)
	files, _ := filepath.Glob(*images + "/*")
	fmt.Fprintf(os.Stderr, "ls: %q\n", files) // contains a list of all files in the current directory

	// Mechanical stuff.
	errc := make(chan error)
	ctx := context.Background()
	if *dev {
		*file = "./socks.json"
	}

	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
		logger = log.NewContext(logger).With("caller", log.DefaultCaller)
	}

	// Data domain.
	socks, tags, err := readFile(*file)
	if err != nil {
		logger.Log("err", err)
		os.Exit(1)
	}

	// Service domain.
	var service catalogue.Service
	{
		service = catalogue.NewFixedService(socks, tags)
		service = catalogue.LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := catalogue.MakeEndpoints(service)

	// Create and launch the HTTP server.
	go func() {
		logger.Log("transport", "HTTP", "port", *port)
		handler := catalogue.MakeHTTPHandler(ctx, endpoints, *images, logger)
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

func readFile(filename string) ([]catalogue.Sock, []string, error) {
	f, err := os.Open(filename)
	if err != nil {
		return nil, nil, err
	}
	defer f.Close()

	var socks []catalogue.Sock
	if err := json.NewDecoder(f).Decode(&socks); err != nil {
		return nil, nil, err
	}

	tagMap := map[string]struct{}{}
	for _, sock := range socks {
		for _, tag := range sock.Tags {
			tagMap[tag] = struct{}{}
		}
	}
	tags := make([]string, 0, len(tagMap))
	for tag := range tagMap {
		tags = append(tags, tag)
	}
	sort.Sort(sort.StringSlice(tags))

	return socks, tags, nil
}
