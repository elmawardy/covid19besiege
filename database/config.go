package database

// DB is global DB Config
var DB = map[string]string{
	"driver":    "postgres",
	"constring": "host=db port=5432 user=postgres dbname=covidtracker password=123456 sslmode=disable",
	"redishost": "redis",
}
