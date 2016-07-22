package payment

import (
	"bytes"
	"encoding/json"
	"fmt"
	"golang.org/x/net/context"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestNewAuthorisationService(t *testing.T) {
	// Create a request to pass to our handler. We don't have any query parameters for now, so we'll
	// pass 'nil' as the third parameter.
	req, err := http.NewRequest("POST", "/paymentAuth", bytes.NewBuffer([]byte(`{"amount": 10}`)))
	if err != nil {
		t.Fatal(err)
	}

	// We create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response.
	rr := httptest.NewRecorder()

	ctx := context.Background()
	// Service domain.
	var service Service
	{
		service = NewAuthorisationService(99999)
	}

	// Endpoint domain.
	endpoints := MakeEndpoints(service)

	// Create and launch the HTTP server.
	handler := MakeHTTPHandler(ctx, endpoints, nil)
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect.
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	buffer := new(bytes.Buffer)
	if err := json.Compact(buffer, rr.Body.Bytes()); err != nil {
		fmt.Println(err)
	}

	// Check the response body is what we expect.
	expected := `{"authorised":true}`
	if buffer.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			buffer.String(), expected)
	}
}
