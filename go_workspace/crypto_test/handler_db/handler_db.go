package handler_db

import (
	"database/sql"
	"fmt"

	"crypto_test/handler_yaml"
	"log"

	_ "github.com/lib/pq"
)

// const (
// 	host       = "localhost"
// 	port       = 5431
// 	user       = "user1"
// 	password   = "dlwltjxl1!"
// 	dbname     = "db1"
// 	driverName = "postgres"
// )

// type Config struct {
// 	Hostname   string `yaml:"HOSTNAME"`
// 	Username   string `yaml:"USERNAME"`
// 	Password   string `yaml:"PASSWORD"`
// 	Database   string `yaml:"DATABASE"`
// 	Port       string `yaml:"PORT"`
// 	DriverName string `yaml:"DRIVERNAME"`
// }

// func main() {
// 	db := Dbconnection()

// 	defer db.Close()

// 	// Read(db)
// 	JustRawBytes(db)

// }

func Dbconnection(config *handler_yaml.Config) *sql.DB {
	// connection string
	// psqlconn := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable", host, port, user, password, dbname)
	psqlconn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable", config.Hostname, config.Port, config.Username, config.Password, config.Database)

	// open database
	// db, err := sql.Open(driverName, psqlconn)
	db, err := sql.Open(config.DriverName, psqlconn)

	CheckError(err)

	// close database
	// defer db.Close()

	// check db
	err = db.Ping()
	CheckError(err)

	fmt.Println("Connected.")

	return db
}

func CheckError(err error) {
	if err != nil {
		log.Fatal(err)
		panic(err)
	}

	/* another case */

	// if err != nil {
	// 	panic(err.Error()) // proper error handling instead of panic in your app
	// }
}

func ExecQuery(db *sql.DB, query string) {
	result, err := db.Exec(query)

	CheckError(err)

	fmt.Printf("[ Success ]: %s\n", query)

	// 영향을 받은 행 수 확인
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		log.Fatalf("Failed to get affected rows: %v", err)
	}

	fmt.Printf("Rows affected: %d\n", rowsAffected)

}

func Read(db *sql.DB) {
	rows, err := db.Query("select * from pg_catalog.pg_user")

	if err != nil {
		fmt.Println()
	} else {

		var row string

		for rows.Next() {
			rows.Scan(&row, TrashScanner{}, TrashScanner{}, TrashScanner{}, TrashScanner{}, TrashScanner{}, TrashScanner{}, TrashScanner{}, TrashScanner{})
			fmt.Println(row)
		}
	}
}

type TrashScanner struct{}

func (TrashScanner) Scan(interface{}) error {
	return nil
}

/* other case 1 */
// just RawBytes
func JustRawBytes(db *sql.DB, query string) {
	// Open database connection
	// db, err := sql.Open("mysql", "user:password@/dbname")
	// if err != nil {
	// 	panic(err.Error())  // Just for example purpose. You should use proper error handling instead of panic
	// }
	// defer db.Close()

	// Execute the query
	// rows, err := db.Query("select * from pg_catalog.pg_user")
	rows, err := db.Query(query)
	if err != nil {
		panic(err.Error()) // proper error handling instead of panic in your app
	}

	// Get column names
	columns, err := rows.Columns()
	if err != nil {
		panic(err.Error()) // proper error handling instead of panic in your app
	}

	// Make a slice for the values
	values := make([]sql.RawBytes, len(columns))

	// rows.Scan wants '[]interface{}' as an argument, so we must copy the
	// references into such a slice
	// See http://code.google.com/p/go-wiki/wiki/InterfaceSlice for details
	scanArgs := make([]interface{}, len(values))
	for i := range values {
		scanArgs[i] = &values[i]
	}

	// Fetch rows
	for rows.Next() {
		// get RawBytes from data
		err = rows.Scan(scanArgs...)
		if err != nil {
			panic(err.Error()) // proper error handling instead of panic in your app
		}

		// Now do something with the data.
		// Here we just print each column as a string.
		var value string
		for i, col := range values {
			// Here we can check if the value is nil (NULL value)
			if col == nil {
				value = "NULL"
			} else {
				value = string(col)
			}
			fmt.Println(columns[i], ": ", value)
		}
		fmt.Println("-----------------------------------")
	}

	if err = rows.Err(); err != nil {
		panic(err.Error()) // proper error handling instead of panic in your app
	}
}

/* other case 2 */
// using a map
// type mapStringScan struct {
// 	// cp are the column pointers
// 	cp []interface{}
// 	// row contains the final result
// 	row      map[string]string
// 	colCount int
// 	colNames []string
// }

// func newMapStringScan(columnNames []string) *mapStringScan {
// 	lenCN := len(columnNames)
// 	s := &mapStringScan{
// 		cp:       make([]interface{}, lenCN),
// 		row:      make(map[string]string, lenCN),
// 		colCount: lenCN,
// 		colNames: columnNames,
// 	}

// 	for i := 0; i < lenCN; i++ {
// 		s.cp[i] = new(sql.RawBytes)
// 	}

// 	return s
// }

// func (s *mapStringScan) Update(rows *sql.Rows) error {
// 	if err := rows.Scan(s.cp...); err != nil {
// 		return err
// 	}

// 	for i := 0; i < s.colCount; i++ {
// 		if rb, ok := s.cp[i].(*sql.RawBytes); ok {
// 			s.row[s.colNames[i]] = string(*rb)
// 			*rb = nil
// 		} else {
// 			return fmt.Errorf("")
// 		}
// 	}

// 	return nil
// }
