package login

import (
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

// TODO Remove passwords from Logging.

func (mw loggingMiddleware) Login(username, password string) (user User, err error) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Login",
			"username", username,
			"password", password,
			"result", user.ID,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Login(username, password)
}

func (mw loggingMiddleware) Register(username, password string) (status bool) {
	defer func(begin time.Time) {
		mw.logger.Log(
			"method", "Register",
			"username", username,
			"password", password,
			"result", status,
			"took", time.Since(begin),
		)
	}(time.Now())
	return mw.next.Register(username, password)
}
