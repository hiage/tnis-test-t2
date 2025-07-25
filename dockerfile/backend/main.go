package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"path"
	"strconv"
	"time"
	"github.com/gorilla/mux"
)

type Response struct {
	Status  int    `json:"status"`
	Message string `json:"message"`
}

func homeLink(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Backend its working...")
}

func getHelloTrivia(w http.ResponseWriter, r *http.Request) {
	var response Response

	currentTime := time.Now()
	month := int(currentTime.Month())
	day := currentTime.Day()
	q, err := url.Parse("http://numbersapi.com")
	if err != nil {
		log.Fatal(err)
	}
	q.Path = path.Join(q.Path, strconv.Itoa(month))
	q.Path = path.Join(q.Path, strconv.Itoa(day))
	q.Path = path.Join(q.Path, "date")
	var client http.Client
	resp, err := client.Get(q.String())
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		bodyBytes, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			log.Fatal(err)
		}
		bodyString := string(bodyBytes)
		response.Status = 1
		response.Message = bodyString
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(response)
	}
}

func main() {
	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/", homeLink)
	router.HandleFunc("/hellotrivia", getHelloTrivia).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", router))
}
