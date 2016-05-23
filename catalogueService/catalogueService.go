package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

var catalogue []Sock 

func main() {
	var file string
	file = "/config/socks.json"
	loadCatalogue(file)

	var port string
	port = "8081"
	http.HandleFunc("/catalogue", catalogueHandler)
	http.ListenAndServe(":" + port, nil)
}

func catalogueHandler(w http.ResponseWriter, r *http.Request) {
	var data []byte
	var err error

	data, err = json.Marshal(catalogue)
	if err != nil {
		panic(err)
	}
	w.Write(data)
}

func loadCatalogue(file string) {
	f, err := ioutil.ReadFile(file)
    if err != nil {
        panic(err)
    }

    json.Unmarshal(f, &catalogue)
    fmt.Printf("Results: %v\n", catalogue)
}

type Sock struct {
	Id string `json:id`
	Price int `json:price`
	Count int `json:"count"`
	// Size, image, name?
}