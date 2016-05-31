package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
)

var customerUrl = "http://accounts/customers/findByUsername"
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
	fmt.Printf("Login service running on port %s\n", port)
	http.ListenAndServe(":" + port, nil)
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

	// TODO lookup customer id via accounts service
	if dev {
		customerUrl = "http://localhost:8082/customers/findByUsername"
	}
	res, err := http.Get(customerUrl + "?username=" + u)
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()
	decoder := json.NewDecoder(res.Body)
	var c Customer
	err = decoder.Decode(&c)
	if err != nil {
		panic(err)
	}
	js, err := json.Marshal(c)
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

	// Not yet implemented
	w.WriteHeader(501)
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
	Id string `json:"id"`
	Name string `json:"name"`
	Password string `json:"password"`
}

type Customer struct {
	Id int `json:"id"`
	FirstName string `json:"firstName"`
    LastName string `json:"lastName"`
    Username string `json:"username"`
}