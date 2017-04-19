package catalogue

import (
	"reflect"
	"strings"
	"testing"
)

var (
	s1 = Sock{ID: "1", Tags: []string{"odd", "prime"}}
	s2 = Sock{ID: "2", Tags: []string{"even", "prime"}}
	s3 = Sock{ID: "3", Tags: []string{"odd", "prime"}}
	s4 = Sock{ID: "4", Tags: []string{"even"}}
	s5 = Sock{ID: "5", Tags: []string{"odd", "prime"}}

	socks = []Sock{s1, s2, s3, s4, s5}
	tags  = []string{"odd", "even", "prime"}
)

func TestFixedServiceList(t *testing.T) {
	s := NewFixedService(socks, tags)
	for _, testcase := range []struct {
		tags     []string
		order    string
		pageNum  int
		pageSize int
		want     []Sock
	}{
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
		have := s.List(testcase.tags, testcase.order, testcase.pageNum, testcase.pageSize)
		if want := testcase.want; !reflect.DeepEqual(want, have) {
			t.Errorf(
				"List(%v, %s, %d, %d): want %s, have %s",
				testcase.tags, testcase.order, testcase.pageNum, testcase.pageSize,
				printIDs(want), printIDs(have),
			)
		}
	}
}

func TestFixedServiceCount(t *testing.T) {
	s := NewFixedService(socks, tags)
	for _, testcase := range []struct {
		tags []string
		want int
	}{
		{[]string{}, 5},
		{[]string{"prime"}, 4},
		{[]string{"odd"}, 3},
		{[]string{"even"}, 2},
		{[]string{"even", "prime"}, 1},
		{[]string{"even", "odd"}, 0},
		{[]string{"no matches"}, 0},
	} {
		have := s.Count(testcase.tags)
		if want := testcase.want; want != have {
			t.Errorf("Count(%v): want %d, have %d", testcase.tags, want, have)
		}
	}
}

func TestFixedServiceGet(t *testing.T) {
	s := NewFixedService(socks, tags)
	{
		// Error cases
		for _, id := range []string{
			"invalid",
			"",
			"0",
		} {
			want := ErrNotFound
			if _, have := s.Get(id); want != have {
				t.Errorf("Get(%s): want %v, have %v", id, want, have)
			}
		}
	}
	{
		// Success cases
		for id, want := range map[string]Sock{
			"1": s1,
			"2": s2,
			"3": s3,
			"4": s4,
			"5": s5,
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

func TestFixedServiceTags(t *testing.T) {
	// This test is kind of pointless, I guess.
	s := NewFixedService(socks, tags)
	if want, have := tags, s.Tags(); !reflect.DeepEqual(want, have) {
		t.Errorf("Tags(): want %v, have %v", want, have)
	}
}

func TestFilter(t *testing.T) {
	for _, testcase := range []struct {
		tags []string
		want []Sock
	}{
		{[]string{}, []Sock{s1, s2, s3, s4, s5}}, // no tags, return all
		{[]string{""}, []Sock{}},
		{[]string{"true"}, []Sock{s1, s2, s3, s4, s5}}, // special case
		{[]string{"odd"}, []Sock{s1, s3, s5}},
		{[]string{"even"}, []Sock{s2, s4}},
		{[]string{"odd", "even"}, []Sock{}}, // impossibility result
		{[]string{"prime", "odd"}, []Sock{s1, s3, s5}},
		{[]string{"prime", "even"}, []Sock{s2}}, // AND semantics
	} {
		if want, have := testcase.want, filter(socks, testcase.tags); !reflect.DeepEqual(want, have) {
			t.Errorf("filter(%v): want %s, have %s", testcase.tags, printIDs(want), printIDs(have))
		}
	}
}

func TestSortBy(t *testing.T) {
	for _, testcase := range []struct {
		input []Sock
		order string
		want  []Sock
	}{
		{[]Sock{s5, s4, s3, s2, s1}, "undefined, should be no-op", []Sock{s5, s4, s3, s2, s1}},
		{[]Sock{s5, s4, s3, s2, s1}, "id", []Sock{s1, s2, s3, s4, s5}},
		{[]Sock{s1, s2, s3, s4, s5}, "tag", []Sock{s4, s1, s2, s3, s5}},
	} {
		if want, have := testcase.want, sortBy(testcase.input, testcase.order); !reflect.DeepEqual(want, have) {
			t.Errorf("sortBy(%s): want %s, have %s", testcase.order, printIDs(want), printIDs(have))
		}
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
