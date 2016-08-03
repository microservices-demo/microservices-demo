package payment

import (
	"github.com/go-kit/kit/log"
	"golang.org/x/net/context"
	"net/http"
	"os"
)

func WireUp(ctx context.Context, declineAmount float32) (http.Handler, log.Logger) {
	// Log domain.
	var logger log.Logger
	{
		logger = log.NewLogfmtLogger(os.Stderr)
		logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)
		logger = log.NewContext(logger).With("caller", log.DefaultCaller)
	}

	// Service domain.
	var service Service
	{
		service = NewAuthorisationService(declineAmount)
		service = LoggingMiddleware(logger)(service)
	}

	// Endpoint domain.
	endpoints := MakeEndpoints(service)

	handler := MakeHTTPHandler(ctx, endpoints, logger)
	return handler, logger
}
