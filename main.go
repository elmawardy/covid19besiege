package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"

	"github.com/elmawardy/covid19besiege/database"
	"github.com/valyala/fastjson"

	"github.com/dgrijalva/jwt-go"
	"github.com/gorilla/mux"
)

// Contact ..
type Contact struct {
	FromDeviceID    string `json:"fromdevice_id"`
	ToDeviceID      string `json:"to_deviceid"`
	InitialLocation string `json:"initial_location"`
	LastLocation    string `json:"last_location"`
	FirstTime       string `json:"first_time"`
	LastTime        string `json:"last_time"`
}

// PersonContacts ...
type PersonContacts struct {
	FromDeviceID string    `json:"from_deviceid"`
	Contacts     []Contact `json:"contacts"`
}

func main() {
	r := mux.NewRouter().StrictSlash(true)

	r.HandleFunc("/contacts/add", contactAddHandler)
	r.HandleFunc("/contacts/get", contactsGetHandler)
	r.HandleFunc("/person/getstate", getPersonState)
	r.HandleFunc("/login/fb", loginUserByFacebookToken)

	r.PathPrefix("/static/").
		Handler(http.StripPrefix("/static/", http.FileServer(http.Dir("./static"))))

	log.Fatal(http.ListenAndServe(":8000", r))
}

func getPersonState(w http.ResponseWriter, r *http.Request) {
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type,Accept")

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))

	var p fastjson.Parser
	responseJSON, err := p.Parse(string(body))

	personState, err := database.GetPersonState(string(responseJSON.GetStringBytes("deviceId")))
	if err != nil {
		log.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error processing DB"}`)
		return
	}

	fmt.Fprintf(w, `{"Status":"Success","PersonState":"%v"}`, personState)
	return
}

func contactAddHandler(w http.ResponseWriter, r *http.Request) {
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type,Accept")

	// decoder := json.NewDecoder(r.Body)
	// contacts := database.PersonContacts{}
	// if err := json.Unmarshal(, &contacts); err != nil {
	// 	fmt.Fprintf(w, `{"Status":"Error","Msg":"Error parsing request"}`)
	// 	log.Print(err)
	// 	return
	// }

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))

	var p fastjson.Parser
	responseJSON, err := p.Parse(string(body))
	token := string(responseJSON.GetStringBytes("jwt"))
	if token == "" {
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}

	claims, err := ParseToken(token)
	if claims == nil {
		// log.Println(err)
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}

	var contacts PersonContacts
	err = json.Unmarshal(body, &contacts)
	if err != nil {
		panic(err)
	}

	tokenDeviceID := fmt.Sprintf("%v", claims["deviceID"])
	if tokenDeviceID != contacts.FromDeviceID {
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}

	dbContacts := database.PersonContacts{FromDeviceID: contacts.FromDeviceID}
	for _, contact := range contacts.Contacts {
		tempDbContact := database.Contact{}
		tempDbContact.FirstTime = contact.FirstTime
		tempDbContact.LastTime = contact.LastTime
		tempDbContact.ToDeviceID = contact.ToDeviceID
		tempDbContact.InitialLatitude = strings.Split(contact.InitialLocation, ",")[0]
		tempDbContact.InitialLongitude = strings.Split(contact.InitialLocation, ",")[1]
		tempDbContact.LastLatitude = strings.Split(contact.LastLocation, ",")[0]
		tempDbContact.LastLongitude = strings.Split(contact.LastLocation, ",")[1]

		dbContacts.Contacts = append(dbContacts.Contacts, tempDbContact)
	}

	err = database.SavePersonContacts(dbContacts)
	if err != nil {
		fmt.Fprintf(w, `%v`, err)
		return
	}

	fmt.Fprintf(w, `%v`, `{"Status":"Success","Msg":"Done"}`)

	return
}

func contactsGetHandler(w http.ResponseWriter, r *http.Request) {
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type,Accept")

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))

	var p fastjson.Parser
	responseJSON, err := p.Parse(string(body))
	if err != nil {
		log.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error parsing request"}`)
		return
	}

	token := string(responseJSON.GetStringBytes("jwt"))
	if token == "" {
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}

	claims, err := ParseToken(token)
	if claims == nil {
		// log.Println(err)
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}
	tokenDeviceID := fmt.Sprintf("%v", claims["deviceID"])
	if tokenDeviceID != string(responseJSON.GetStringBytes("fromDeviceId")) {
		fmt.Fprintf(w, `{"Status":"Error","Msg":"Unauthorized"}`)
		return
	}

	if responseJSON.GetInt("count") > 100 {
		log.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Count reached limit"}`)
		return
	}

	contacts, err := database.GetContacts(string(responseJSON.GetStringBytes("fromDeviceId")), responseJSON.GetInt("offset"), responseJSON.GetInt("count"))
	if err != nil {
		log.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error processing DB"}`)
		return
	}

	contactsJSON, err := json.Marshal(contacts)
	if err != nil {
		log.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error processing DB Response"}`)
		return
	}
	fmt.Fprintf(w, `%s`, contactsJSON)
	return

}

func loginUserByFacebookToken(w http.ResponseWriter, r *http.Request) {
	//Allow CORS here By * or specific origin
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type,Accept")

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	log.Println(string(body))

	var p fastjson.Parser
	responseJSON, err := p.Parse(string(body))

	if err != nil {
		fmt.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error parsing request"}`)
		return
	}

	resp, err := http.Get(fmt.Sprintf(`https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=%v`, string(responseJSON.GetStringBytes("token"))))
	if err != nil || resp.StatusCode != 200 {
		fmt.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error parsing request"}`)
		return
	}

	body, err = ioutil.ReadAll(resp.Body)
	if err != nil {
		fmt.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error parsing fb response"}`)
		return
	}
	responseJSON, err = p.Parse(string(body))
	if err != nil {
		fmt.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error parsing facebook response"}`)
		return
	}

	deviceID, personState, err := database.LoginPerson(string(body))
	if err != nil {
		fmt.Println(err)
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error saving user in the DB"}`)
		return
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email":    string(responseJSON.GetStringBytes("email")),
		"deviceID": deviceID,
	})

	tokenString, err := token.SignedString([]byte("my-token-key"))

	if err != nil {
		fmt.Fprintf(w, `%v`, `{"Status":"Error","Msg":"Error building jwt"}`)
		return
	}

	responseData := fmt.Sprintf(`{"Status":"Success","nativeToken":"%v","deviceID":"%s","personState":"%s"}`, tokenString, deviceID, personState)
	fmt.Fprintf(w, responseData)
	return

}

// ParseToken parses the JWT token string and returns claims
func ParseToken(userToken string) (jwt.MapClaims, error) {
	// Parse takes the token string and a function for looking up the key. The latter is especially
	// useful if you use multiple keys for your application.  The standard is to use 'kid' in the
	// head of the token to identify which key to use, but the parsed token (head and claims) is provided
	// to the callback, providing flexibility.

	token, err := jwt.Parse(userToken, func(token *jwt.Token) (interface{}, error) {
		// Don't forget to validate the alg is what you expect:
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}

		// hmacSampleSecret is a []byte containing your secret, e.g. []byte("my_secret_key")
		return []byte("asd"), nil
	})

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	} else {
		return claims, err
	}
}
