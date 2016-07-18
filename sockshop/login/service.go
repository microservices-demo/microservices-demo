package login

// service.go contains the definition and implementation (business logic) of the
// login service. Everything here is agnostic to the transport (HTTP).

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
	"sync"
)

// Service is the login service, providing operations for users to login and register.
type Service interface {
	Login(username, password string) (User, error) // GET /login
	// Only used for testing at the moment
	Register(username, password string) bool // GET /register?username=[username]&password=[password]
}

// User describes the logged in user.
type User struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Password string `json:"password"`
	Link     string `json:"link"`
}

// ErrUnauthorized is returned when there the supplied credentials are not valid.
var ErrUnauthorized = errors.New("Unauthorized")

// For Customer Lookup
const (
	customerHost       = "accounts"
	customerLookupPath = "/customers/search/findByUsername"
)

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of users. Replace with db integration?
func NewFixedService(users []User, domain string) Service {
	return &fixedService{
		users:  users,
		domain: domain,
	}
}

type fixedService struct {
	mtx    sync.RWMutex
	users  []User
	domain string
}

func (s *fixedService) Login(username, password string) (User, error) {
	found := false
	s.mtx.RLock()
	for _, user := range s.users {
		if user.Name == username && user.Password == password {
			found = true
		}
	}
	s.mtx.RUnlock()

	if !found {
		return User{}, ErrUnauthorized
	}

	c, err := lookupCustomer(username, password, s.domain)

	if err != nil || len(c.Embedded.Customers) < 1 {
		return User{}, ErrUnauthorized
	}

	cust := c.Embedded.Customers[0]
	custLink := cust.Links.CustomerLink.Href

	idSplit := strings.Split(custLink, "/")
	id := idSplit[len(idSplit)-1]

	return User{
		Name: cust.Username,
		Link: custLink,
		ID:   id,
	}, nil
}

func (s *fixedService) Register(username, password string) bool {

	s.mtx.Lock()
	defer s.mtx.Unlock()

	// To integrate with Accounts service
	s.users = append(s.users, User{ID: "", Name: username, Password: password})

	return true
}

func lookupCustomer(u, p, domain string) (customerResponse, error) {
	var c customerResponse
	var host string
	if domain != "" {
		host = customerHost + "." + domain
	} else {
		host = customerHost
	}
	reqUrl := "http://" + host + customerLookupPath + "?username=" + u

	res, err := http.Get(reqUrl)
	if err != nil {
		return c, err
	}

	defer res.Body.Close()
	json.NewDecoder(res.Body).Decode(&c)

	if err != nil {
		return c, err
	}

	return c, nil
}

type customerResponse struct {
	Embedded struct {
		Customers []struct {
			Username string `json:"username"`
			Links    struct {
				CustomerLink struct {
					Href string `json:"href"`
				} `json:"customer"`
			} `json:"_links"`
		} `json:"customer"`
	} `json:"_embedded"`
}
