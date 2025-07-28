package main

import (
	"html/template"
	"log"
	"net/http"
)

func renderTemplate(w http.ResponseWriter, tmpl string) {
	t, err := template.ParseFiles("templates/" + tmpl + ".html")
	if err != nil {
		http.Error(w, "Page not found", http.StatusNotFound)
		log.Println(err)
		return
	}
	t.Execute(w, nil)
}

func main() {
	// Serve static files
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// App routes
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "home")
	})
	http.HandleFunc("/ai-ml-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "ai-ml")
	})
	http.HandleFunc("/cloud-devops-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "cloud-devops")
	})

	// Health check endpoints
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	http.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		// If readiness involves external systems, add logic here.
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ready"))
	})

	log.Println("Server started at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}

/*
package main

import (
	"html/template"
	"log"
	"net/http"
	"sync/atomic"
	"time"
)

var ready atomic.Value
var healthy atomic.Value

func renderTemplate(w http.ResponseWriter, tmpl string) {
	t, err := template.ParseFiles("templates/" + tmpl + ".html")
	if err != nil {
		http.Error(w, "Page not found", http.StatusNotFound)
		log.Println(err)
		return
	}
	t.Execute(w, nil)
}

func main() {
	// Start unready and healthy
	ready.Store(false)
	healthy.Store(true)

	// After 10 seconds, app becomes ready
	go func() {
		time.Sleep(10 * time.Second)
		ready.Store(true)
		log.Println("App is now READY")
	}()

	// After 60 seconds, app becomes unhealthy
	go func() {
		time.Sleep(60 * time.Second)
		healthy.Store(false)
		log.Println("App is now UNHEALTHY")
	}()

	// Serve static files
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))

	// App routes
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "home")
	})
	http.HandleFunc("/ai-ml-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "ai-ml")
	})
	http.HandleFunc("/cloud-devops-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "cloud-devops")
	})

	// Liveness probe
	http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		if healthy.Load().(bool) {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ok"))
		} else {
			http.Error(w, "unhealthy", http.StatusInternalServerError)
		}
	})

	// Readiness probe
	http.HandleFunc("/readyz", func(w http.ResponseWriter, r *http.Request) {
		if ready.Load().(bool) {
			w.WriteHeader(http.StatusOK)
			w.Write([]byte("ready"))
		} else {
			http.Error(w, "not ready", http.StatusServiceUnavailable)
		}
	})

	log.Println("Server started at http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

*/
