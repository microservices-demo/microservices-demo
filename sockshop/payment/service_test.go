package payment

import (
	"testing"
)

func TestAuthorise(t *testing.T) {
	result, _ := NewAuthorisationService(100).Authorise(10)
	expected := true
	if result.Authorised != expected {
		t.Errorf("Authorise returned unexpected result: got %v want %v",
			result.Authorised, expected)
	}
}

func TestFailOverCertainAmount(t *testing.T) {
	result, _ := NewAuthorisationService(10).Authorise(100)
	expected := false
	if result.Authorised != expected {
		t.Errorf("Authorise returned unexpected result: got %v want %v",
			result.Authorised, expected)
	}
}

func TestFailIfAmountIsZero(t *testing.T) {
	_, err := NewAuthorisationService(10).Authorise(0)
	_, ok := err.(error)
	if !ok {
		t.Errorf("Authorise returned unexpected result: got %v want %v",
			err, "Zero payment")
	}
}

func TestFailIfAmountNegative(t *testing.T) {
	_, err := NewAuthorisationService(10).Authorise(-1)
	_, ok := err.(error)
	if !ok {
		t.Errorf("Authorise returned unexpected result: got %v want %v",
			err, "Negative payment")
	}
}
