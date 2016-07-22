package catalogue

// endpoints.go contains the endpoint definitions, including per-method request
// and response structs. Endpoints are the binding between the service and
// transport.

import (
	"github.com/go-kit/kit/endpoint"
	"golang.org/x/net/context"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	ListEndpoint  endpoint.Endpoint
	CountEndpoint endpoint.Endpoint
	GetEndpoint   endpoint.Endpoint
	TagsEndpoint  endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service) Endpoints {
	return Endpoints{
		ListEndpoint:  MakeListEndpoint(s),
		CountEndpoint: MakeCountEndpoint(s),
		GetEndpoint:   MakeGetEndpoint(s),
		TagsEndpoint:  MakeTagsEndpoint(s),
	}
}

// MakeListEndpoint returns an endpoint via the given service.
func MakeListEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(listRequest)
		socks := s.List(req.Tags, req.Order, req.PageNum, req.PageSize)
		return listResponse{Socks: socks}, nil
	}
}

// MakeCountEndpoint returns an endpoint via the given service.
func MakeCountEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(countRequest)
		n := s.Count(req.Tags)
		return countResponse{N: n}, nil
	}
}

// MakeGetEndpoint returns an endpoint via the given service.
func MakeGetEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(getRequest)
		sock, err := s.Get(req.ID)
		return getResponse{Sock: sock, Err: err}, nil
	}
}

// MakeTagsEndpoint returns an endpoint via the given service.
func MakeTagsEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		tags := s.Tags()
		return tagsResponse{Tags: tags}, nil
	}
}

type listRequest struct {
	Tags     []string `json:"tags"`
	Order    string `json:"order"`
	PageNum  int `json:"pageNum"`
	PageSize int `json:"pageSize"`
}

type listResponse struct {
	Socks []Sock `json:"sock"`
}

type countRequest struct {
	Tags []string `json:"tags"`
}

type countResponse struct {
	N int `json:"size"` // to match original
}

type getRequest struct {
	ID string `json:"id"`
}

type getResponse struct {
	Sock Sock `json:"sock"`
	Err  error `json:"err"`
}

type tagsRequest struct {
	//
}

type tagsResponse struct {
	Tags []string `json:"tags"`
}
