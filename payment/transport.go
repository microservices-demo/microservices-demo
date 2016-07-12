package payment

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/go-kit/kit/log"
	httptransport "github.com/go-kit/kit/transport/http"
	"github.com/gorilla/mux"
	"golang.org/x/net/context"
	"io/ioutil"
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
	// Read the content
	var bodyBytes []byte
	if r.Body != nil {
		var err error
		bodyBytes, err = ioutil.ReadAll(r.Body)
		if err != nil {
			return nil, err
		}
	}
	// Save the content
	bodyString := string(bodyBytes)

	// Decode auth request
	var request authoriseRequest
	if err := json.Unmarshal(bodyBytes, &request); err != nil {
		return nil, err
	}

	// If amount isn't present, error
	if request.Amount == 0.0 {
		return nil, &UnmarshalKeyError{
			Key:  "amount",
			JSON: bodyString,
		}
	}
	return request, nil
}

type UnmarshalKeyError struct {
	Key  string
	JSON string
}

func (e *UnmarshalKeyError) Error() string {
	return fmt.Sprintf("Cannot unmarshal object key %q from JSON: %s", e.Key, e.JSON)
}

var ErrInvalidJson = errors.New("Invalid json")

func encodeAuthoriseResponse(ctx context.Context, w http.ResponseWriter, response interface{}) error {
	resp := response.(authoriseResponse)
	if resp.Err != nil {
		encodeError(ctx, resp.Err, w)
		return nil
	}
	return encodeResponse(ctx, w, resp.Authorisation)
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	// All of our response objects are JSON serializable, so we just do that.
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	return json.NewEncoder(w).Encode(response)
}
