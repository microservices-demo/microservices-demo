package payment

import "errors"

type Service interface {
	Authorise(total float32) (Authorisation, error) // GET /paymentAuth
}

type Authorisation struct {
	Authorised bool `json:"authorised"`
}

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of socks and tags. In a real service you'd
// probably construct this with a database handle to your socks DB, etc.
func NewAuthorisationService(declineOverAmount float32) Service {
	return &service{
		declineOverAmount: declineOverAmount,
	}
}

type service struct {
	declineOverAmount float32
}

func (s *service) Authorise(amount float32) (Authorisation, error) {
	if amount == 0 {
		return Authorisation{}, ErrInvalidPaymentAmount
	}
	if amount < 0 {
		return Authorisation{}, ErrInvalidPaymentAmount
	}
	authorised := false
	if amount <= s.declineOverAmount {
		authorised = true
	}
	return Authorisation{
		Authorised: authorised,
	}, nil
}

var ErrInvalidPaymentAmount = errors.New("Invalid payment amount")
