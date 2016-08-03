package payment

import (
	"bytes"
	"encoding/json"
	"golang.org/x/net/context"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestComponent(t *testing.T) {
	// Mechanical stuff.
	ctx := context.Background()

	handler, logger := WireUp(ctx, float32(99.99))

	ts := httptest.NewServer(handler)
	defer ts.Close()

	var request AuthoriseRequest
	request.Amount = 9.99
	requestBytes, err := json.Marshal(request)
	if err != nil {
		t.Fatal("ERROR", err)
	}

	res, err := http.Post(ts.URL+"/paymentAuth", "application/json", bytes.NewReader(requestBytes))
	if err != nil {
		t.Fatal("ERROR", err)
	}
	greeting, err := ioutil.ReadAll(res.Body)
	res.Body.Close()
	if err != nil {
		t.Fatal("ERROR", err)
	}
	var response Authorisation
	json.Unmarshal(greeting, &response)

	logger.Log("Authorised", response.Authorised)

	expected := true
	if response.Authorised != expected {
		t.Errorf("Authorise returned unexpected result: got %v expected %v",
			response.Authorised, expected)
	}

}
