package catalogue

// service.go contains the definition and implementation (business logic) of the
// catalogue service. Everything here is agnostic to the transport (HTTP).

import (
	"errors"
	"sort"
)

// Service is the catalogue service, providing read operations on a saleable
// catalogue of sock products.
type Service interface {
	List(tags []string, order string, pageNum, pageSize int) []Sock // GET /catalogue
	Count(tags []string) int                                        // GET /catalogue/size
	Get(id string) (Sock, error)                                    // GET /catalogue/{id}
	Tags() []string                                                 // GET /tags
}

// Sock describes the thing on offer in the catalogue.
type Sock struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	ImageURL    []string `json:"imageUrl"`
	Price       float32  `json:"price"`
	Count       int      `json:"count"`
	Tags        []string `json:"tag"`
}

// ErrNotFound is returned when there is no sock for a given ID.
var ErrNotFound = errors.New("not found")

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of socks and tags. In a real service you'd
// probably construct this with a database handle to your socks DB, etc.
func NewFixedService(socks []Sock, tags []string) Service {
	return &fixedService{
		socks: socks,
		tags:  tags,
	}
}

type fixedService struct {
	socks []Sock
	tags  []string
}

func (s *fixedService) List(tags []string, order string, pageNum, pageSize int) []Sock {
	var socks []Sock
	{
		socks = s.socks
		socks = filter(socks, tags)
		socks = sortBy(socks, order)
		socks = cut(socks, pageNum, pageSize)
	}
	return socks
}

func (s *fixedService) Count(tags []string) int {
	var socks []Sock
	{
		socks = s.socks
		socks = filter(socks, tags)
	}
	return len(socks)
}

func (s *fixedService) Get(id string) (Sock, error) {
	for _, sock := range s.socks {
		if sock.ID == id {
			return sock, nil
		}
	}
	return Sock{}, ErrNotFound
}

func (s *fixedService) Tags() []string {
	return s.tags
}

func filter(socks []Sock, tags []string) []Sock {
	if len(tags) == 0 || len(tags) == 1 && tags[0] == "true" {
		return socks[:]
	}
	r := []Sock{}
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

func sortBy(socks []Sock, order string) []Sock {
	cp := make(sockz, len(socks))
	copy(cp, socks) // sort will mutate, so we make a copy
	switch order {
	case "id":
		sort.Sort(byID{cp})
	case "name":
		sort.Sort(byName{cp})
	case "description":
		sort.Sort(byDescription{cp})
	case "price":
		sort.Sort(byPrice{cp})
	case "count":
		sort.Sort(byCount{cp})
	case "tag":
		sort.Sort(byTag{cp})
	}
	return cp
}

func cut(socks []Sock, pageNum, pageSize int) []Sock {
	if pageNum == 0 || pageSize == 0 {
		return []Sock{} // pageNum is 1-indexed
	}
	start := (pageNum * pageSize) - pageSize
	if start > len(socks) {
		return []Sock{}
	}
	end := (pageNum * pageSize)
	if end > len(socks) {
		end = len(socks)
	}
	return socks[start:end]
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

// https://talks.golang.org/2014/go4gophers.slide#14

type sockz []Sock

func (s sockz) Len() int      { return len(s) }
func (s sockz) Swap(i, j int) { s[i], s[j] = s[j], s[i] }

type byID struct{ sockz }
type byName struct{ sockz }
type byDescription struct{ sockz }
type byPrice struct{ sockz }
type byCount struct{ sockz }
type byTag struct{ sockz }

func (s byID) Less(i, j int) bool          { return s.sockz[i].ID < s.sockz[j].ID }
func (s byName) Less(i, j int) bool        { return s.sockz[i].Name < s.sockz[j].Name }
func (s byDescription) Less(i, j int) bool { return s.sockz[i].Description < s.sockz[j].Description }
func (s byPrice) Less(i, j int) bool       { return s.sockz[i].Price < s.sockz[j].Price }
func (s byCount) Less(i, j int) bool       { return s.sockz[i].Count < s.sockz[j].Count }
func (s byTag) Less(i, j int) bool         { return len(s.sockz[i].Tags) < len(s.sockz[j].Tags) }
