package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"sort"
	"strconv"
	"strings"

	"github.com/gorilla/mux"
)

var catalogue []sock

var dev bool
var port string
var tagList []string = []string{"geek", "blue", "brown", "green", "black", "sport", "action", "skin", "smelly", "large", "short", "magic", "toes", "formal"}

func main() {

	flag.BoolVar(&dev, "dev", false, "Run in development mode")
	flag.StringVar(&port, "port", "8081", "Port on which to run")
	flag.Parse()

	var file string
	if dev {
		file = "./socks.json"
	} else {
		file = "/config/socks.json"
	}
	loadCatalogue(file)

	router := mux.NewRouter().StrictSlash(false)
	router.HandleFunc("/catalogue", catalogueHandler)
	router.HandleFunc("/catalogue/size", sizeHandler)
	router.HandleFunc("/catalogue/{catId}", itemHandler)
	router.HandleFunc("/tags", tagHandler)
	router.PathPrefix("/catalogue/images/").Handler(http.StripPrefix("/catalogue/images/", http.FileServer(http.Dir("./images/"))))
	fmt.Printf("Catalogue service running on port %s\n", port)
	http.ListenAndServe(":"+port, router)
}

func catalogueHandler(w http.ResponseWriter, r *http.Request) {

	page := r.FormValue("page")
	size := r.FormValue("size")
	sortField := r.FormValue("sort")
	tagField := r.FormValue("tags")

	pageCount := 1
	if len(page) > 0 {
		pageCount, _ = strconv.Atoi(page)
	}
	perPage := 10
	if len(size) > 0 {
		perPage, _ = strconv.Atoi(size)
	}
	sortOn := "id"
	if len(sortField) > 0 {
		sortOn = strings.ToLower(sortField)
	}

	var sorted []sock = filter(catalogue, tagField)

	switch sortOn {
	case "id":
		sort.Sort(idSorter(sorted))
	case "name":
		sort.Sort(nameSorter(sorted))
	case "description":
		sort.Sort(descriptionSorter(sorted))
	case "price":
		sort.Sort(priceSorter(sorted))
	case "count":
		sort.Sort(countSorter(sorted))
	case "tag":
		sort.Sort(tagSorter(sorted))
	}
	end := (pageCount * perPage)
	if end > len(sorted) {
		end = len(sorted)
	}
	start := end - perPage
	if start < 0 {
		start = 0
	}
	var data []byte
	var err error

	fmt.Printf("Fetching items from %d to %d. Sorted by %s\n", start, end, sortOn)

	data, err = json.Marshal(sorted[start:end])
	if err != nil {
		panic(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(data)
}

func itemHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	catId := vars["catId"]

	for _, sock := range catalogue {
		if sock.Id == catId {
			data, _ := json.Marshal(sock)
			w.Header().Set("Content-Type", "application/json")
			w.Write(data)
			return
		}
	}
	w.WriteHeader(404)
}

func tagHandler(w http.ResponseWriter, r *http.Request) {
	body, err := json.Marshal(tagList)
	if err != nil {
		panic(err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(body)
}

func sizeHandler(w http.ResponseWriter, r *http.Request) {
	tagField := r.FormValue("tags")
	cat := filter(catalogue, tagField)
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte("{\"size\":" + strconv.Itoa(len(cat)) + "}"))
}
func loadCatalogue(file string) {
	f, err := ioutil.ReadFile(file)
	if err != nil {
		panic(err)
	}

	json.Unmarshal(f, &catalogue)
	fmt.Printf("Loaded %d items into catalogue.\n", len(catalogue))
}

func filter(socks []sock, tagString string) []sock {
	if len(tagString) < 1 {
		return socks[:]
	}
	var r []sock
	tags := strings.Split(tagString, ",")
	for _, s := range socks {
		var count []string
		for _, m := range tags {
		TAGLABEL:
			for _, t := range s.Tags {
				if t == m && !contains(count, t) {
					count = append(count, t)
					break TAGLABEL
				}
			}
		}
		if len(count) == len(tags) {
			r = append(r, s)
		}
	}
	return r
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

type sock struct {
	Id          string   `json:"id"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	ImageURL    []string `json:"imageUrl"`
	Price       float32  `json:"price"`
	Count       int      `json:"count"`
	Tags        []string `json:"tag"`
}

type idSorter []sock

func (a idSorter) Len() int           { return len(a) }
func (a idSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a idSorter) Less(i, j int) bool { return a[i].Id < a[j].Id }

type nameSorter []sock

func (a nameSorter) Len() int           { return len(a) }
func (a nameSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a nameSorter) Less(i, j int) bool { return a[i].Name < a[j].Name }

type descriptionSorter []sock

func (a descriptionSorter) Len() int           { return len(a) }
func (a descriptionSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a descriptionSorter) Less(i, j int) bool { return a[i].Description < a[j].Description }

type priceSorter []sock

func (a priceSorter) Len() int           { return len(a) }
func (a priceSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a priceSorter) Less(i, j int) bool { return a[i].Price < a[j].Price }

type countSorter []sock

func (a countSorter) Len() int           { return len(a) }
func (a countSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a countSorter) Less(i, j int) bool { return a[i].Count < a[j].Count }

type tagSorter []sock

func (a tagSorter) Len() int           { return len(a) }
func (a tagSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a tagSorter) Less(i, j int) bool { return len(a[i].Tags) < len(a[j].Tags) }
