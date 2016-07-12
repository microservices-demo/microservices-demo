package payment

type Service interface {
	Authorise() Authorisation // GET /paymentAuth
}

type Authorisation struct {
	Authorised bool `json:"authorised"`
}

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of socks and tags. In a real service you'd
// probably construct this with a database handle to your socks DB, etc.
func NewAuthorisationService() Service {
	return &service{}
}

type service struct {
}

func (s *service) Authorise() Authorisation {
	return Authorisation{
		Authorised: true,
	}
}
