package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHomePage(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/", nil)
	w := httptest.NewRecorder()

	homeHandler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "home")
	})
	homeHandler.ServeHTTP(w, req)

	resp := w.Result()
	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status OK; got %v", resp.Status)
	}

	// Check if it mentions AI/ML Engineering
	if !strings.Contains(string(body), "AI/ML Engineering") {
		t.Errorf("expected body to contain 'AI/ML Engineering'")
	}
}

func TestAIMLEngineeringPage(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/ai-ml-engineering", nil)
	w := httptest.NewRecorder()

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "ai-ml")
	})
	handler.ServeHTTP(w, req)

	resp := w.Result()
	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status OK; got %v", resp.Status)
	}

	// Check if page talks about AI/ML
	if !strings.Contains(string(body), "Artificial Intelligence and Machine Learning") {
		t.Errorf("expected body to mention 'Artificial Intelligence and Machine Learning'")
	}
}

func TestCloudDevOpsEngineeringPage(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/cloud-devops-engineering", nil)
	w := httptest.NewRecorder()

	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "cloud-devops")
	})
	handler.ServeHTTP(w, req)

	resp := w.Result()
	body, _ := io.ReadAll(resp.Body)

	if resp.StatusCode != http.StatusOK {
		t.Errorf("expected status OK; got %v", resp.Status)
	}

	// Check if page talks about Cloud and DevOps
	if !strings.Contains(string(body), "Cloud and DevOps engineers are critical") {
		t.Errorf("expected body to mention 'Cloud and DevOps engineers are critical'")
	}
}
