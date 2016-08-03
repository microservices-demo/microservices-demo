package catalogue

import (
	"strings"
	"time"

	"github.com/go-kit/kit/log"
)

// Middleware decorates a service.
type Middleware func(Service) Service

// LoggingMiddleware logs method calls, parameters, results, and elapsed time.
func LoggingMiddleware(logger log.Logger) Middleware {
	return func(next Service) Service {
		return loggingMiddleware{
			next:   next,
			logger: logger,
		}
	}
}

type loggingMiddleware struct {
	next   Service
	logger log.Logger
}

func (mw loggingMiddleware) List(tags []string, order string, pageNum, pageSize int) (socks []Sock) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "List",
			"tags", strings.Join(tags, ", "),
			"order", order,
			"pageNum", pageNum,
			"pageSize", pageSize,
			"result", len(socks),
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.List(tags, order, pageNum, pageSize)
}

func (mw loggingMiddleware) Count(tags []string) (n int) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Count",
			"tags", strings.Join(tags, ", "),
			"result", n,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Count(tags)
}

func (mw loggingMiddleware) Get(id string) (s Sock, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Get",
			"id", id,
			"sock", s.ID,
			"err", err,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Get(id)
}

func (mw loggingMiddleware) Tags() (tags []string) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Tags",
			"result", len(tags),
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Tags()
}
