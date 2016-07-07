package payment

import (
	"testing"
)

func TestAuthorise(t *testing.T) {
	result := NewAuthorisationService().Authorise()
	expected := true
	if result.Authorised != expected {
		t.Errorf("Authorise returned unexpected result: got %v want %v",
			result.Authorised, expected)
	}
}
