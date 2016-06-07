package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
)

var customerUrl = "http://accounts/customers/search/findByUsername"
var dev bool
var port string
var users []User

func main() {

	flag.StringVar(&port, "port", "8084", "Port on which to run")
	flag.BoolVar(&dev, "dev", false, "Run in development mode")
	flag.Parse()

	var file string
	if dev {
		file = "./users.json"
	} else {
		file = "/config/users.json"
	}
	loadUsers(file)

	http.HandleFunc("/login", loginHandler)
	http.HandleFunc("/register", registerHandler)
	fmt.Printf("Login service running on port %s\n", port)
	http.ListenAndServe(":"+port, nil)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	u, p, ok := r.BasicAuth()
	if !ok {
		fmt.Printf("No Authorization header present.\n")
		w.WriteHeader(401)
		return
	}

	fmt.Printf("Lookup for user %s and password: %s.\n", u, p)

	found := false
	for _, user := range users {
		if user.Name == u && user.Password == p {
			found = true
		}
	}

	if !found {
		fmt.Printf("User not authorized.\n")
		w.WriteHeader(401)
		return
	}

	if dev {
		customerUrl = "http://localhost:8082/customers/search/findByUsername"
	}
	res, err := http.Get(customerUrl + "?username=" + u)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()
	fmt.Printf("Body: %s", res.Body)
	decoder := json.NewDecoder(res.Body)

	var s Search
	err = decoder.Decode(&s)
	if err != nil {
		panic(err)
	}
	fmt.Printf("Parsed: %s", s)

	if len(s.Embedded.Customers) < 1 {
		panic(errors.New("No customers found for that username."))
	}

	c := s.Embedded.Customers[0]
	fmt.Printf("Customer: %s", c)

	customer := c.Links.Customer.Href
	fmt.Printf("Customer link: %s", customer)

	idSplit := strings.Split(customer, "/")
	id := idSplit[len(idSplit)-1]
	fmt.Printf("Customer id: %s", id)

	var response Response
	response.Username = c.Username
	response.Customer = customer
	response.Id = id

	js, err := json.Marshal(response)
	fmt.Printf("Marshalled: %s", js)

	if err != nil {
		panic(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
	// respond with customer id OR 401 not authorized
	w.WriteHeader(200)
}

func registerHandler(w http.ResponseWriter, r *http.Request) {
	// Create new customer via accounts service

	// Store id? user and password
	username := r.FormValue("username")
	password := r.FormValue("password")
	users = append(users, User{Id: "", Name: username, Password: password})

	w.WriteHeader(200)
	// Not yet implemented
	// w.WriteHeader(501)
}

func loadUsers(file string) {
	f, err := ioutil.ReadFile(file)
	if err != nil {
		panic(err)
	}
	json.Unmarshal(f, &users)
	fmt.Printf("Loaded %d users.", len(users))
}

type User struct {
	Id       string `json:"id"`
	Name     string `json:"name"`
	Password string `json:"password"`
}

type Search struct {
	Embedded Embedded `json:"_embedded"`
}

type Embedded struct {
	Customers []Customer `json:"customer"`
}

type Customer struct {
	Username string `json:"username"`
	Links    Links  `json:"_links"`
}

type Links struct {
	Customer Link `json:"customer"`
}

type Link struct {
	Href string `json:"href"`
}

type Response struct {
	Username string `json:"username"`
	Customer string `json:"customer"`
	Id       string `json:"id"`
}
