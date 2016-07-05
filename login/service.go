package login

// service.go contains the definition and implementation (business logic) of the
// login service. Everything here is agnostic to the transport (HTTP).

import (
	"encoding/json"
	"errors"
	"net/http"
	"strings"
)

// Service is the login service, providing operations for users to login and register.
type Service interface {
	Login(username, password string) (User, error)   // GET /login
	// Only used for testing at the moment
	Register(username, password string) bool	// GET /register?username=[username]&password=[password]
}

// User describes the logged in user.
type User struct {
	Id       string `json:"id"`
	Name     string `json:"name"`
	Password string `json:"password"`
	Link     string `json:"link"`
}

// ErrNotAuthorized is returned when there the supplied credentials are not valid.
var ErrNotAuthorized = errors.New("invalid credendtials")

// For Customer Lookup
var customerHost = "accounts"
var customerLookupPath = "/customers/search/findByUsername"

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of users. Replace with db integration?
func NewFixedService(users []User) Service {
	return &fixedService{
		users: users,
	}
}

type fixedService struct {
	users []User
}

func (s *fixedService) Login(username, password string) (User, error) {
	found := false
	for _, user := range s.users {
		if user.Name == username && user.Password == password {
			found = true
		}
	}

	if !found {
		return User{}, ErrNotAuthorized
	}

	c, err := lookupCustomer(username, password)

	if err != nil || len(c.Embedded.Customers) < 1 {
		return User{}, ErrNotAuthorized
	}

	cust := c.Embedded.Customers[0]
	custLink := cust.Links.CustomerLink.Href

	idSplit := strings.Split(custLink, "/")
	id := idSplit[len(idSplit)-1]

	var user User
	user.Name = cust.Username
	user.Link = custLink
	user.Id = id

	return user, nil
}

func (s *fixedService) Register(username, password string) bool {

	// To integrate with Accounts service
	s.users = append(s.users, User{Id: "", Name: username, Password: password})
	
	return true
}

func lookupCustomer(u, p string) (customerResponse, error) {
	var c customerResponse

	reqUrl := "http://" + customerHost + customerLookupPath + "?username=" + u

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