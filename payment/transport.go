package payment

import (
	"encoding/json"
	"github.com/go-kit/kit/log"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	"golang.org/x/net/context"
	"net/http"
)

// MakeHTTPHandler mounts the endpoints into a REST-y HTTP handler.
func MakeHTTPHandler(ctx context.Context, e Endpoints, logger log.Logger) http.Handler {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	r.Methods("POST").Path("/paymentAuth").Handler(httptransport.NewServer(
		ctx,
		e.AuthoriseEndpoint,
		decodeAuthoriseRequest,
		encodeAuthoriseResponse,
		options...,
	))

	return r
}

func encodeError(_ context.Context, err error, w http.ResponseWriter) {
	code := http.StatusInternalServerError
	w.WriteHeader(code)
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"error":       err.Error(),
		"status_code": code,
		"status_text": http.StatusText(code),
	})
}

func decodeAuthoriseRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return authoriseRequest{}, nil
}

func encodeAuthoriseResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(authoriseResponse)
	return encodeResponse(ctx, w, resp.Authorisation)
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	// All of our response objects are JSON serializable, so we just do that.
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	return json.NewEncoder(w).Encode(response)
}
