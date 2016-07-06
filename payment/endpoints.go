package payment

import (
	"github.com/go-kit/kit/endpoint"
	"golang.org/x/net/context"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	AuthoriseEndpoint endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service) Endpoints {
	return Endpoints{
		AuthoriseEndpoint: MakeAuthoriseEndpoint(s),
	}
}

// MakeListEndpoint returns an endpoint via the given service.
func MakeAuthoriseEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		_ = request.(authoriseRequest)
		authorisation := s.Authorise()
		return authoriseResponse{Authorisation: authorisation}, nil
	}
}

type authoriseRequest struct {
}

type authoriseResponse struct {
	Authorisation Authorisation
}
