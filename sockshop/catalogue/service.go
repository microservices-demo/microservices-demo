package catalogue

// service.go contains the definition and implementation (business logic) of the
// catalogue service. Everything here is agnostic to the transport (HTTP).

import (
	"database/sql"
	"errors"
	"fmt"
	"strings"
)

// Service is the catalogue service, providing read operations on a saleable
// catalogue of sock products.
type Service interface {
	List(tags []string, order string, pageNum, pageSize int) ([]Sock, error) // GET /catalogue
	Count(tags []string) (int, error)                                        // GET /catalogue/size
	Get(id string) (Sock, error)                                             // GET /catalogue/{id}
	Tags() ([]string, error)                                                 // GET /tags
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

// ErrDBConnection is returned when connection with the database fails.
var ErrDBConnection = errors.New("database connection error")

var baseQuery = "SELECT Sock.SockID AS id, Sock.name, Sock.description, Sock.price, Sock.count, Sock.ImageUrl_1, Sock.ImageUrl_2, GROUP_CONCAT(Tag.name) AS TagName FROM Sock JOIN SockTag ON Sock.SockID=SockTag.SockID JOIN Tag ON SockTag.TagID=Tag.TagID"

// NewFixedService returns a simple implementation of the Service interface,
// fixed over a predefined set of socks and tags. In a real service you'd
// probably construct this with a database handle to your socks DB, etc.
func NewFixedService(db *sql.DB) Service {
	return &fixedService{
		db: db,
	}
}

type fixedService struct {
	db *sql.DB
}

func (s *fixedService) List(tags []string, order string, pageNum, pageSize int) ([]Sock, error) {
	var socks []Sock
	query := baseQuery

	var args []interface{}

	for i, t := range tags {
		if i == 0 {
			query += " WHERE Tag.name=?"
			args = append(args, t)
		} else {
			query += " OR Tag.name=?"
			args = append(args, t)
		}
	}

	query += " GROUP BY id"

	if order != "" {
		query += " ORDER BY ?"
		args = append(args, order)
	}

	query += ";"
	// fmt.Println("Query: " + query)
	sel, err := s.db.Prepare(query)

	if err != nil {
		fmt.Println("here: " + err.Error())
		return []Sock{}, ErrDBConnection
	}
	defer sel.Close()

	rows, err := sel.Query(args...)
	if err != nil {
		fmt.Println("there: " + err.Error())
		return []Sock{}, ErrDBConnection
	}
	// fmt.Println("before")
	for rows.Next() {
		// fmt.Println("next...")
		sock := rowToSock(rows)
		socks = append(socks, sock)
	}

	socks = cut(socks, pageNum, pageSize)

	return socks, nil
}

func (s *fixedService) Count(tags []string) (int, error) {
	query := "SELECT COUNT(*) FROM Sock JOIN SockTag ON Sock.SockID=SockTag.SockID JOIN Tag ON SockTag.TagID=Tag.TagID"

	var args []interface{}

	for i, t := range tags {
		if i == 0 {
			query += " WHERE Tag.name=?"
			args = append(args, t)
		} else {
			query += " OR Tag.name=?"
			args = append(args, t)
		}
	}

	query += " GROUP BY Sock.SockID;"

	// fmt.Println("Query: " + query)
	sel, err := s.db.Prepare(query)

	if err != nil {
		fmt.Println("here: " + err.Error())
		return 0, ErrDBConnection
	}
	defer sel.Close()

	rows, err := sel.Query(args...)

	if err != nil {
		return 0, ErrDBConnection
	}
	var count int
	rows.Next()
	err = rows.Scan(&count)
	if err != nil {
		return 0, ErrDBConnection
	}
	return count, nil
}

func (s *fixedService) Get(id string) (Sock, error) {
	query := baseQuery + " WHERE Sock.SockID =? GROUP BY Sock.SockID;"

	sel, err := s.db.Prepare(query)
	if err != nil {
		return Sock{}, ErrDBConnection
	}
	defer sel.Close()

	rows, err := sel.Query(id)
	if err != nil {
		return Sock{}, ErrDBConnection
	}

	if !rows.Next() {
		return Sock{}, ErrNotFound
	}

	sock := rowToSock(rows)

	return sock, nil
}

func (s *fixedService) Tags() ([]string, error) {
	var tags []string
	query := "SELECT name FROM Tag;"
	rows, err := s.db.Query(query)
	if err != nil {
		return []string{}, ErrDBConnection
	}
	var tag string
	for rows.Next() {
		rows.Scan(&tag)
		tags = append(tags, tag)
	}
	return tags, nil
}

func rowToSock(rows *sql.Rows) Sock {
	var sock Sock
	var url1, url2, tagName string
	err := rows.Scan(&sock.ID, &sock.Name, &sock.Description, &sock.Price, &sock.Count, &url1, &url2, &tagName)
	if err != nil {
		// logger.Log("Error:", "Unable to read data")
		return Sock{}
	}
	sock.Tags = strings.Split(tagName, ",")
	sock.ImageURL = []string{url1, url2}
	return sock
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
