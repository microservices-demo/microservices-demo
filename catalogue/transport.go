package catalogue

// transport.go contains the binding from endpoints to a concrete transport.
// In our case we just use a REST-y HTTP transport.

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
	"golang.org/x/net/context"

	"github.com/go-kit/kit/log"
	httptransport "github.com/go-kit/kit/transport/http"
)

// MakeHTTPHandler mounts the endpoints into a REST-y HTTP handler.
func MakeHTTPHandler(ctx context.Context, e Endpoints, imagePath string, logger log.Logger) http.Handler {
	r := mux.NewRouter().StrictSlash(false)
	options := []httptransport.ServerOption{
		httptransport.ServerErrorLogger(logger),
		httptransport.ServerErrorEncoder(encodeError),
	}

	// GET /catalogue       List
	// GET /catalogue/size  Count
	// GET /catalogue/{id}  Get
	// GET /tags            Tags

	r.Methods("GET").Path("/catalogue").Handler(httptransport.NewServer(
		ctx,
		e.ListEndpoint,
		decodeListRequest,
		encodeResponse,
		options...,
	))
	r.Methods("GET").Path("/catalogue/size").Handler(httptransport.NewServer(
		ctx,
		e.CountEndpoint,
		decodeCountRequest,
		encodeResponse,
		options...,
	))
	r.Methods("GET").Path("/catalogue/{id}").Handler(httptransport.NewServer(
		ctx,
		e.GetEndpoint,
		decodeGetRequest,
		encodeResponse,
		options...,
	))
	r.Methods("GET").Path("/tags").Handler(httptransport.NewServer(
		ctx,
		e.TagsEndpoint,
		decodeTagsRequest,
		encodeResponse,
		options...,
	))
	r.Methods("GET").PathPrefix("/catalogue/images/").Handler(http.StripPrefix(
		"/catalogue/images/",
		http.FileServer(http.Dir(imagePath)),
	))

	return r
}

func encodeError(_ context.Context, err error, w http.ResponseWriter) {
	code := http.StatusInternalServerError
	switch err {
	case ErrNotFound:
		code = http.StatusNotFound
	}
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(map[string]interface{}{
		"error":       err.Error(),
		"status_code": code,
		"status_text": http.StatusText(code),
	})
}

func decodeListRequest(_ context.Context, r *http.Request) (interface{}, error) {
	pageNum, err := strconv.Atoi(r.FormValue("page"))
	if err != nil {
		return struct{}{}, err
	}
	pageSize, err := strconv.Atoi(r.FormValue("size"))
	if err != nil {
		return struct{}{}, err
	}
	return listRequest{
		Tags:     strings.Split(r.FormValue("tags"), ","),
		Order:    strings.ToLower(r.FormValue("sort")),
		PageNum:  pageNum,
		PageSize: pageSize,
	}, nil
}

func decodeCountRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return countRequest{
		Tags: strings.Split(r.FormValue("tags"), ","),
	}, nil
}

func decodeGetRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return getRequest{
		ID: mux.Vars(r)["id"],
	}, nil
}

func decodeTagsRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return struct{}{}, nil
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	// All of our response objects are JSON serializable, so we just do that.
	return json.NewEncoder(w).Encode(response)
}
