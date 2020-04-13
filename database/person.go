package database

import (
	"github.com/teris-io/shortid"
	"github.com/valyala/fastjson"

	// "database/sql"

	"errors"
	"fmt"
	"time"

	"github.com/jmoiron/sqlx"
	// Postgresql driver for golang
	_ "github.com/lib/pq"
)

// Person ...
type Person struct {
	ID         int    `db:"id"`
	Phone      string `db:"phone"`
	NationalID string `db:"national_id"`
	DeviceID   string `db:"deviceid"`
	Age        int    `db:"age"`
	Gender     string `db:"gender"`
}

// Contact ..
type Contact struct {
	FromDeviceID     string `db:"from_deviceid"`
	ToDeviceID       string `db:"to_deviceid"`
	InitialLatitude  string `db:"initial_latitude"`
	InitialLongitude string `db:"initial_longitude"`
	LastLatitude     string `db:"last_latitude"`
	LastLongitude    string `db:"last_longitude"`
	FirstTime        string `db:"first_time"`
	LastTime         string `db:"last_time"`
	ID               string `db:"id"`
}

// PersonContacts ...
type PersonContacts struct {
	FromDeviceID string    `json:"from_deviceid"`
	Contacts     []Contact `json:"contacts"`
}

// SavePersonContacts ...
func SavePersonContacts(contacts PersonContacts) error {

	db, err := sqlx.Connect(DB["driver"], DB["constring"])
	if err != nil {
		return err
	}

	// fromUserID := 0
	// err = db.Get(&fromUserID, "SELECT id from person where deviceid = $1", contacts.FromDeviceID)
	// if err != nil || fromUserID == 0 {
	// 	defer db.Close()
	// 	return errors.New("User not found")
	// }

	for _, contact := range contacts.Contacts {
		toDeviceID := contact.ToDeviceID
		initialLatitude := contact.InitialLatitude
		initialLongitude := contact.InitialLongitude
		lastLatitude := contact.LastLatitude
		lastLongitude := contact.LastLongitude
		firstTime := contact.FirstTime
		lastTime := contact.LastTime

		// toUserID := 0
		// err = db.Get(&toUserID, "SELECT id from person where deviceid = $1", toDeviceID)
		// if err != nil || toUserID == 0 {
		// 	defer db.Close()
		// 	return errors.New("User not found")
		// }

		query := "INSERT INTO person_contacts (from_deviceid,to_deviceid,initial_latitude,initial_longitude,last_latitude,last_longitude,first_time,last_time) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)"
		db.MustExec(query, contacts.FromDeviceID, toDeviceID, initialLatitude, initialLongitude, lastLatitude, lastLongitude, firstTime, lastTime)
	}

	defer db.Close()
	return nil
}

// GetContacts ...
func GetContacts(fromDeviceID string, offset int, count int) ([]Contact, error) {
	db, err := sqlx.Connect(DB["driver"], DB["constring"])
	if err != nil {
		return nil, err
	}

	contacts := []Contact{}
	db.Select(&contacts, "SELECT * FROM person_contacts where from_deviceid = $1 order by last_time desc limit $2 offset $3", fromDeviceID, count, offset)

	for i := 0; i < len(contacts); i++ {
		// deviceID := "0"
		// err = db.Get(&deviceID, "SELECT deviceid from person where id = $1", contacts[i].ToDeviceID)
		// if err != nil || fromUserID == 0 {
		// 	defer db.Close()
		// 	return nil, errors.New("Error processing DB")
		// }

		// contacts[i].ToDeviceID = deviceID

		epoch, err := time.Parse(time.RFC3339, contacts[i].FirstTime)
		if err != nil {
			defer db.Close()
			return nil, errors.New("Error parsing time")
		}

		contacts[i].FirstTime = fmt.Sprintf("%v", epoch.Unix())

		epoch, err = time.Parse(time.RFC3339, contacts[i].LastTime)
		if err != nil {
			defer db.Close()
			return nil, errors.New("Error parsing time")
		}

		contacts[i].LastTime = fmt.Sprintf("%v", epoch.Unix())

	}

	defer db.Close()
	return contacts, err

}

// GetPersonState ...
func GetPersonState(deviceID string) (string, error) {
	db, err := sqlx.Connect(DB["driver"], DB["constring"])
	if err != nil {
		return "", err
	}

	userID := 0
	err = db.Get(&userID, "SELECT id from person where deviceid = $1", deviceID)
	if err != nil || userID == 0 {
		defer db.Close()
		return "", errors.New("User not found")
	}

	personState := "Unknown"
	err = db.Get(&personState, "SELECT state from person where id = $1", userID)
	if err != nil {
		defer db.Close()
		return "", errors.New("User not found")
	}

	defer db.Close()
	return personState, err

}

// LoginPerson ...
func LoginPerson(stringData string) (string, string, error) {
	db, err := sqlx.Connect(DB["driver"], DB["constring"])
	if err != nil {
		return "", "", err
	}

	var p fastjson.Parser
	jsonData, err := p.Parse(stringData)

	personData := struct {
		deviceID    string `db:"deviceid"`
		personState string `db:"state"`
	}{}

	row := db.QueryRow("SELECT deviceid,state from person where email = $1", string(jsonData.GetStringBytes("email")))
	row.Scan(&personData.deviceID, &personData.personState)

	if personData.deviceID != "" {
		defer db.Close()
		return personData.deviceID, personData.personState, nil
	}

	personData.deviceID, err = shortid.Generate()
	if err != nil {
		defer db.Close()
		return "", "", errors.New("error optaining deviceId")
	}

	query := "INSERT INTO person (state,name,email,deviceid) VALUES ($1,$2,$3,$4)"
	db.MustExec(query, "green", string(jsonData.GetStringBytes("name")), string(jsonData.GetStringBytes("email")), personData.deviceID)

	defer db.Close()
	return personData.deviceID, personData.personState, nil

}
