package main

import (
  "database/sql"
  "database/sql/driver"
  "encoding/json"
  "fmt"
  "os"
  "log"
  "net/http"

  "github.com/go-sql-driver/mysql"
  "github.com/gorilla/mux"
  "github.com/Pallinder/go-randomdata"
)

type User struct{
  Email     string `json:"email,omitempty"`
  Username  string `json:"username,omitempty"`
  Firstname string `json:"firstname,omitempty"`
  Lastname  string `json:"lastname,omitempty"`
  Password  string `json:"password,omitempty"`
}

type Status struct {
  MySQL        string `json:"mysql,omitempty"`
  RowsAffected int64  `json:"rows_affected,omitempty"`
}

type Response struct {
  Status Status
  User   User
}

type Config struct {
  Host     string
  Port     string
  User     string
  Password string
  Schema   string
}

var cnf Config

var createSchemaStatements = []string{
  `CREATE DATABASE IF NOT EXISTS sandbox DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';`,
}

var createTableStatements = []string{
  `DROP TABLE IF EXISTS sandbox.users;`,
  `CREATE TABLE IF NOT EXISTS sandbox.users (
    id bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT,
    uuid char(36) NOT NULL, -- https://tools.ietf.org/html/rfc4122
    email char(255) NOT NULL,
    username char(255) NOT NULL,
    firstname varchar(90) NOT NULL,
    lastname varchar(90),
    password_hash char(32) NOT NULL,
    genre ENUM('Female', 'Male') NOT NULL,
    state ENUM('Disable', 'Enable', 'Suspended', 'Migrated') NOT NULL,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE (uuid),
    UNIQUE (email),
    UNIQUE (username),
    INDEX timestamp_idx (created_at, modified_at, deleted_at)
  ) ENGINE=InnoDB AUTO_INCREMENT=1;`,
}

func init() {
  fmt.Println("==> Load benchmark API.")

  cnf.Host     = getEnv("MYSQL_HOST", "127.0.0.1")
  cnf.Port     = getEnv("MYSQL_PORT", "3306")
  cnf.User     = getEnv("MYSQL_USERNAME", "root")
  cnf.Password = getEnv("MYSQL_PASSWORD", "")
  cnf.Schema   = getEnv("MYSQL_SCHEMA", "sandbox")
}

func main() {
  fmt.Printf("--> Config: %+v\n", cnf)

  // Check database and table exists. If not, create it.
  ensureSchemaExists();

  // Load API
  r := mux.NewRouter()

  r.HandleFunc("/status/", handleStatus).Methods("GET")
  r.HandleFunc("/user/",handleUserCreate).Methods("POST")
  r.HandleFunc("/user/random/", handleUserGetRandom).Methods("GET")

  http.ListenAndServe(":8080", r)
}

func ensureSchemaExists() {
  db, err := sql.Open("mysql", cnf.User + ":" + cnf.Password + "@tcp(" + cnf.Host + ":" + cnf.Port + ")/")
  if err != nil {
    log.Print(err.Error())
  }
  defer db.Close()

  // Check the connection.
  if db.Ping() == driver.ErrBadConn {
    log.Print(fmt.Errorf("mysql: could not connect to the database. " +
      "could be bad address, or this address is not whitelisted for access."))
  }

  if _, err := db.Exec("USE sandbox"); err != nil {
    // MySQL error 1049 is "database does not exist"
    if mErr, ok := err.(*mysql.MySQLError); ok && mErr.Number == 1049 {
      fmt.Println("--> Create schema.")
      if err := createTable(db, createSchemaStatements); err != nil {
        log.Print(err.Error())
      }
    }
  }

  if _, err := db.Exec("DESCRIBE users"); err != nil {
    // MySQL error 1146 is "table does not exist"
    if mErr, ok := err.(*mysql.MySQLError); ok && mErr.Number == 1146 {
      fmt.Println("--> Create tables.")
      if err := createTable(db, createTableStatements); err != nil {
        log.Print(err.Error())
      }
    }
  }
}

// createTable creates the table, and if necessary, the database.
func createTable(conn *sql.DB, statements []string) error {
  for _, stmt := range statements {
    if _, err := conn.Exec(stmt); err != nil {
      return err
    }
  }
  return nil
}

func handleStatus(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json; charset=UTF-8")

  var status Status

  if _, err := connection(); err != nil {
    status.MySQL = err.Error()
    log.Print(status.MySQL)
    w.WriteHeader(http.StatusInternalServerError)
  } else {
    status.MySQL = "Ok"
  }

  json.NewEncoder(w).Encode(status)
}

func handleUserCreate(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json; charset=UTF-8")

  var rps Response

  profile := randomdata.GenerateProfile(randomdata.RandomGender)

  rps.User.Email     = fmt.Sprintf("%d%s", randomdata.Number(0, 100000), profile.Email)
  rps.User.Username  = fmt.Sprintf("%s%d", profile.Login.Username, randomdata.Number(0, 100000))
  rps.User.Firstname = profile.Name.First
  rps.User.Lastname  = profile.Name.Last
  rps.User.Password  = profile.Login.Md5

  db, err := connection()
  if err != nil {
    log.Print(err.Error())
    w.WriteHeader(http.StatusBadRequest)
    return
  }
  defer db.Close()

  ins, err := db.Prepare("INSERT INTO users " +
    "(uuid, email, username, firstname, lastname, password_hash) " +
    "VALUES (UUID(), ?, ?, ?, ?, ?)")
  if err != nil {
    log.Print(err.Error())
    return
  }
  defer ins.Close()

  _, err = ins.Exec(rps.User.Email, rps.User.Username, rps.User.Firstname, rps.User.Lastname, rps.User.Password)
  if err != nil {
    log.Print(err.Error())
    w.WriteHeader(http.StatusBadRequest)
  } else {
    w.WriteHeader(http.StatusCreated)
    if err = json.NewEncoder(w).Encode(&rps.User); err != nil {
      log.Print(err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
    }
  }
}

func handleUserGetRandom(w http.ResponseWriter, r *http.Request) {
  w.Header().Set("Content-Type", "application/json; charset=UTF-8")

  var rps Response
  db, err := connection()
  if err != nil {
    log.Print(err.Error())
    w.WriteHeader(http.StatusBadRequest)
    return
  }
  defer db.Close()

  // err := db.QueryRow("SELECT email FROM users WHERE id = (SELECT FLOOR(RAND() * (SELECT MAX(id) FROM users))) LIMIT 1;").Scan(&rps.User.Email)
  err = db.QueryRow("SELECT email FROM users ORDER BY RAND() LIMIT 1;").Scan(&rps.User.Email)

  if err != nil && err == sql.ErrNoRows {
    log.Print(err.Error())
    w.WriteHeader(http.StatusBadRequest)
    return
  } else {
    if err := json.NewEncoder(w).Encode(&rps.User); err != nil {
      log.Print(err.Error())
      w.WriteHeader(http.StatusInternalServerError)
      return
    }
  }
}

func connection() (db *sql.DB, err error) {
  db, err = sql.Open("mysql", cnf.User + ":" + cnf.Password + "@tcp(" + cnf.Host + ":" + cnf.Port + ")/" + cnf.Schema)

  if err != nil {
    return nil, err
  }

  if err = db.Ping(); err != nil {
    return nil, err
  }

  return db, nil
}

func getEnv(key, fallback string) string {
  if value, ok := os.LookupEnv(key); ok && len(value) > 0 {
      return value
  }
  return fallback
}
