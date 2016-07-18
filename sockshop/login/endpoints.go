package login

// endpoints.go contains the endpoint definitions, including per-method request
// and response structs. Endpoints are the binding between the service and
// transport.

import (
	"github.com/go-kit/kit/endpoint"
	"golang.org/x/net/context"
)

// Endpoints collects the endpoints that comprise the Service.
type Endpoints struct {
	LoginEndpoint    endpoint.Endpoint
	RegisterEndpoint endpoint.Endpoint
}

// MakeEndpoints returns an Endpoints structure, where each endpoint is
// backed by the given service.
func MakeEndpoints(s Service) Endpoints {
	return Endpoints{
		LoginEndpoint:    MakeLoginEndpoint(s),
		RegisterEndpoint: MakeRegisterEndpoint(s),
	}
}

// MakeLoginEndpoint returns an endpoint via the given service.
func MakeLoginEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(loginRequest)
		u, err := s.Login(req.Username, req.Password)
		return loginResponse{User: u}, err
	}
}

// MakeRegisterEndpoint returns an endpoint via the given service.
func MakeRegisterEndpoint(s Service) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req := request.(registerRequest)
		status := s.Register(req.Username, req.Password)
		return registerResponse{Status: status}, nil
	}
}

type loginRequest struct {
	Username string
	Password string
}

type loginResponse struct {
	User User `json:"user"`
}

type registerRequest struct {
	Username string
	Password string
}

type registerResponse struct {
	Status bool `json:"status"`
}
