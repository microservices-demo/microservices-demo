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

var catalogue []Sock 

var dev bool
var port string
var tagList []string = []string{"blue", "brown", "green", "smelly", "large", "short", "magic", "toes", "formal"}

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
	http.ListenAndServe(":" + port, router)
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

	var sorted []Sock = filter(catalogue, tagField)

	switch sortOn {
		case "id":
			sort.Sort(IdSorter(sorted))
		case "name":
			sort.Sort(NameSorter(sorted))
		case "description":
			sort.Sort(DescriptionSorter(sorted))
		case "price":
			sort.Sort(PriceSorter(sorted))
		case "count":
			sort.Sort(CountSorter(sorted))
		case "tag":
			sort.Sort(TagSorter(sorted))
	}
	end := (pageCount * perPage)
	if (end > len(sorted)) {
	    end = len(sorted)
	}
	start := end - perPage
	if (start < 0) {
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
			sock.ImageURL = "http://" + r.Host + sock.ImageURL
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
	if err != nil { panic(err) }
	w.Header().Set("Content-Type", "application/json")
	w.Write(body)
}

func sizeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte("{\"size\":" + strconv.Itoa(len(catalogue)) + "}"))
}
func loadCatalogue(file string) {
	f, err := ioutil.ReadFile(file)
    if err != nil {
        panic(err)
    }

    json.Unmarshal(f, &catalogue)
    fmt.Printf("Loaded %d items into catalogue.\n", len(catalogue))
}

func filter(socks []Sock, tagString string) []Sock {
	if len(tagString) < 1 {
		return socks[:]
	}
	var r []Sock
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
		if (len(count) == len(tags)) {
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

type Sock struct {
	Id string `json:id`
	Name string `json:"name"`
	Description string `json:"description"`
	ImageURL string `json:"imageUrl"`
	Price int `json:price`
	Count int `json:"count"`
	Tags []string `json:"tag"`
}

type IdSorter []Sock

func (a IdSorter) Len() int           { return len(a) }
func (a IdSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a IdSorter) Less(i, j int) bool { return a[i].Id < a[j].Id }

type NameSorter []Sock

func (a NameSorter) Len() int           { return len(a) }
func (a NameSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a NameSorter) Less(i, j int) bool { return a[i].Name < a[j].Name }

type DescriptionSorter []Sock

func (a DescriptionSorter) Len() int           { return len(a) }
func (a DescriptionSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a DescriptionSorter) Less(i, j int) bool { return a[i].Description < a[j].Description }

type PriceSorter []Sock

func (a PriceSorter) Len() int           { return len(a) }
func (a PriceSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a PriceSorter) Less(i, j int) bool { return a[i].Price < a[j].Price }

type CountSorter []Sock

func (a CountSorter) Len() int           { return len(a) }
func (a CountSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a CountSorter) Less(i, j int) bool { return a[i].Count < a[j].Count }

type TagSorter []Sock

func (a TagSorter) Len() int           { return len(a) }
func (a TagSorter) Swap(i, j int)      { a[i], a[j] = a[j], a[i] }
func (a TagSorter) Less(i, j int) bool { return len(a[i].Tags) < len(a[j].Tags) }