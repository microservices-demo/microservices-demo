package catalogue

import (
	"os"
	"reflect"
	"strings"
	"testing"

	"github.com/go-kit/kit/log"
	"github.com/jmoiron/sqlx"
	"gopkg.in/DATA-DOG/go-sqlmock.v1"
)

var (
	s1 = Sock{ID: "1", Name: "name1", Description: "description1", Price: 1.1, Count: 1, ImageURL: []string{"ImageUrl_11", "ImageUrl_21"}, ImageURL_1: "ImageUrl_11", ImageURL_2: "ImageUrl_21", Tags: []string{"odd", "prime"}, TagString: "odd,prime"}
	s2 = Sock{ID: "2", Name: "name2", Description: "description2", Price: 1.2, Count: 2, ImageURL: []string{"ImageUrl_12", "ImageUrl_22"}, ImageURL_1: "ImageUrl_12", ImageURL_2: "ImageUrl_22", Tags: []string{"even", "prime"}, TagString: "even,prime"}
	s3 = Sock{ID: "3", Name: "name3", Description: "description3", Price: 1.3, Count: 3, ImageURL: []string{"ImageUrl_13", "ImageUrl_23"}, ImageURL_1: "ImageUrl_13", ImageURL_2: "ImageUrl_23", Tags: []string{"odd", "prime"}, TagString: "odd,prime"}
	s4 = Sock{ID: "4", Name: "name4", Description: "description4", Price: 1.4, Count: 4, ImageURL: []string{"ImageUrl_14", "ImageUrl_24"}, ImageURL_1: "ImageUrl_14", ImageURL_2: "ImageUrl_24", Tags: []string{"even"}, TagString: "even"}
	s5 = Sock{ID: "5", Name: "name5", Description: "description5", Price: 1.5, Count: 5, ImageURL: []string{"ImageUrl_15", "ImageUrl_25"}, ImageURL_1: "ImageUrl_15", ImageURL_2: "ImageUrl_25", Tags: []string{"odd", "prime"}, TagString: "odd,prime"}

	socks = []Sock{s1, s2, s3, s4, s5}
	tags  = []string{"odd", "even", "prime"}
)

var logger log.Logger

func TestCatalogueServiceList(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"id", "name", "description", "price", "count", "image_url_1", "image_url_2", "tag_name"}

	// Test Case 1
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s1.ID, s1.Name, s1.Description, s1.Price, s1.Count, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Tags, ",")).
		AddRow(s2.ID, s2.Name, s2.Description, s2.Price, s2.Count, s2.ImageURL[0], s2.ImageURL[1], strings.Join(s2.Tags, ",")).
		AddRow(s3.ID, s3.Name, s3.Description, s3.Price, s3.Count, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Tags, ",")).
		AddRow(s4.ID, s4.Name, s4.Description, s4.Price, s4.Count, s4.ImageURL[0], s4.ImageURL[1], strings.Join(s4.Tags, ",")).
		AddRow(s5.ID, s5.Name, s5.Description, s5.Price, s5.Count, s5.ImageURL[0], s5.ImageURL[1], strings.Join(s5.Tags, ",")))

	// Test Case 2
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s4.ID, s4.Name, s4.Description, s4.Price, s4.Count, s4.ImageURL[0], s4.ImageURL[1], strings.Join(s4.Tags, ",")).
		AddRow(s1.ID, s1.Name, s1.Description, s1.Price, s1.Count, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Tags, ",")).
		AddRow(s2.ID, s2.Name, s2.Description, s2.Price, s2.Count, s2.ImageURL[0], s2.ImageURL[1], strings.Join(s2.Tags, ",")))

	// // Test Case 3
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s1.ID, s1.Name, s1.Description, s1.Price, s1.Count, s1.ImageURL[0], s1.ImageURL[1], strings.Join(s1.Tags, ",")).
		AddRow(s3.ID, s3.Name, s3.Description, s3.Price, s3.Count, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Tags, ",")).
		AddRow(s5.ID, s5.Name, s5.Description, s5.Price, s5.Count, s5.ImageURL[0], s5.ImageURL[1], strings.Join(s5.Tags, ",")))

	s := NewCatalogueService(sqlxDB, logger)
	for _, testcase := range []struct {
		tags     []string
		order    string
		pageNum  int
		pageSize int
		want     []Sock
	}{
		{
			tags:     []string{},
			order:    "",
			pageNum:  1,
			pageSize: 5,
			want:     []Sock{s1, s2, s3, s4, s5},
		},
		{
			tags:     []string{},
			order:    "tag",
			pageNum:  1,
			pageSize: 3,
			want:     []Sock{s4, s1, s2},
		},
		{
			tags:     []string{"odd"},
			order:    "id",
			pageNum:  2,
			pageSize: 2,
			want:     []Sock{s5},
		},
	} {
		have, err := s.List(testcase.tags, testcase.order, testcase.pageNum, testcase.pageSize)
		if err != nil {
			t.Errorf(
				"List(%v, %s, %d, %d): returned error %s",
				testcase.tags, testcase.order, testcase.pageNum, testcase.pageSize,
				err.Error(),
			)
		}
		if want := testcase.want; !reflect.DeepEqual(want, have) {
			t.Errorf(
				"List(%v, %s, %d, %d): want %v, have %v",
				testcase.tags, testcase.order, testcase.pageNum, testcase.pageSize,
				want, have,
			)
		}
	}
}

func TestCatalogueServiceCount(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"count"}

	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(5))
	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(4))
	mock.ExpectPrepare("SELECT *").ExpectQuery().WillReturnRows(sqlmock.NewRows(cols).AddRow(1))

	s := NewCatalogueService(sqlxDB, logger)
	for _, testcase := range []struct {
		tags []string
		want int
	}{
		{[]string{}, 5},
		{[]string{"prime"}, 4},
		{[]string{"even", "prime"}, 1},
	} {
		have, err := s.Count(testcase.tags)
		if err != nil {
			t.Errorf(
				"Count(%v): returned error %s",
				testcase.tags, err.Error(),
				err.Error(),
			)
		}
		if want := testcase.want; want != have {
			t.Errorf("Count(%v): want %d, have %d", testcase.tags, want, have)
		}
	}
}

func TestCatalogueServiceGet(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"id", "name", "description", "price", "count", "image_url_1", "image_url_2", "tag_name"}

	// (Error) Test Cases 1
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols))

	// Test Case 2
	mock.ExpectQuery("SELECT *").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(s3.ID, s3.Name, s3.Description, s3.Price, s3.Count, s3.ImageURL[0], s3.ImageURL[1], strings.Join(s3.Tags, ",")))

	s := NewCatalogueService(sqlxDB, logger)
	{
		// Error case
		for _, id := range []string{
			"0",
		} {
			want := ErrNotFound
			if _, have := s.Get(id); want != have {
				t.Errorf("Get(%s): want %v, have %v", id, want, have)
			}
		}
	}
	{
		// Success case
		for id, want := range map[string]Sock{
			"3": s3,
		} {
			have, err := s.Get(id)
			if err != nil {
				t.Errorf("Get(%s): %v", id, err)
				continue
			}
			if !reflect.DeepEqual(want, have) {
				t.Errorf("Get(%s): want %s, have %s", id, want.ID, have.ID)
				continue
			}
		}
	}
}

func TestCatalogueServiceTags(t *testing.T) {
	logger = log.NewLogfmtLogger(os.Stderr)
	db, mock, err := sqlmock.New()
	if err != nil {
		t.Fatalf("an error '%s' was not expected when opening stub database connection", err)
	}
	defer db.Close()
	sqlxDB := sqlx.NewDb(db, "sqlmock")

	var cols []string = []string{"name"}

	mock.ExpectQuery("SELECT name FROM tag").WillReturnRows(sqlmock.NewRows(cols).
		AddRow(tags[0]).
		AddRow(tags[1]).
		AddRow(tags[2]))

	s := NewCatalogueService(sqlxDB, logger)

	have, err := s.Tags()
	if err != nil {
		t.Errorf("Tags(): %v", err)
	}
	if !reflect.DeepEqual(tags, have) {
		t.Errorf("Tags(): want %v, have %v", tags, have)
	}
}

func TestCut(t *testing.T) {
	for _, testcase := range []struct {
		pageNum  int
		pageSize int
		want     []Sock
	}{
		{0, 1, []Sock{}}, // pageNum 0 is invalid
		{1, 0, []Sock{}}, // pageSize 0 is invalid
		{1, 1, []Sock{s1}},
		{1, 2, []Sock{s1, s2}},
		{1, 5, []Sock{s1, s2, s3, s4, s5}},
		{1, 9, []Sock{s1, s2, s3, s4, s5}},
		{2, 0, []Sock{}},
		{2, 1, []Sock{s2}},
		{2, 2, []Sock{s3, s4}},
		{2, 3, []Sock{s4, s5}},
		{2, 4, []Sock{s5}},
		{2, 5, []Sock{}},
		{2, 6, []Sock{}},
		{3, 0, []Sock{}},
		{3, 1, []Sock{s3}},
		{3, 2, []Sock{s5}},
		{3, 3, []Sock{}},
		{4, 1, []Sock{s4}},
		{4, 2, []Sock{}},
	} {
		have := cut(socks, testcase.pageNum, testcase.pageSize)
		if want := testcase.want; !reflect.DeepEqual(want, have) {
			t.Errorf("cut(%d, %d): want %s, have %s", testcase.pageNum, testcase.pageSize, printIDs(want), printIDs(have))
		}
	}
}

// Make test output nicer: just print sock IDs.
type printIDs []Sock

func (s printIDs) String() string {
	ids := make([]string, len(s))
	for i, ss := range s {
		ids[i] = ss.ID
	}
	return "[" + strings.Join(ids, ", ") + "]"
}
