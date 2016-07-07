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
		req := request.(authoriseRequest)
		authorisation, err := s.Authorise(req.Amount)
		return authoriseResponse{Authorisation: authorisation, Err: err}, nil
	}
}

type authoriseRequest struct {
	Amount float32 `json:"amount"`
}

type authoriseResponse struct {
	Authorisation Authorisation
	Err           error
}
