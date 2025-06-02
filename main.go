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

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "home")
	})
	http.HandleFunc("/ai-ml-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "ai-ml")
	})
	http.HandleFunc("/cloud-devops-engineering", func(w http.ResponseWriter, r *http.Request) {
		renderTemplate(w, "cloud-devops")
	})

	log.Println("Server started at http://localhost:8080")
	http.ListenAndServe(":8080", nil)
}
