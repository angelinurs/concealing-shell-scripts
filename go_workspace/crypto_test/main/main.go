package main

import (
	"fmt"
	"strings"
	"time"

	"crypto_test/handler_argument"
	"crypto_test/handler_crypto"
	"crypto_test/handler_db"
	"crypto_test/handler_file"
	"crypto_test/handler_yaml"
)

const key string = "naru"

/*
 * before build test
 * ex) go run .
 */
// const defaultPath string = "../../../script"

/*
 * after build test
 * ex) go run .
 */
const defaultPath string = "./script"

const dbfile string = ".db.connection.enc"
const path string = ""

func main() {

	check, params := handler_argument.GetFlags()

	if check {
		fmt.Println("Begin")
	}

	ArgumentAnalyzer(params)

	fmt.Println("End")

}

// ecode or decode file
// and then save file
func convertToFile(key string, filename string, kind string) {

	fileContent := handler_file.ReadFile(filename)
	content := string(fileContent)

	var afterContent string
	var newFilename string

	switch kind {
	case "encode":
		afterContent = toEncryptContent(key, content)
		filename = strings.Replace(filename, ".yml", ".enc", -1)
		newFilename = handler_file.ReplaceFileExtension(filename, "yml", "enc")

	case "decode":
		afterContent = toDecryptContent(key, content)
		filename = strings.Replace(filename, ".enc", ".yml", -1)
		newFilename = handler_file.ReplaceFileExtension(filename, "enc", "yml")
	}

	handler_file.WriteFile(newFilename, afterContent, path)
}

// service func
func toEncryptContent(key string, content string) string {
	return handler_crypto.Encrypt(key, content)
}

// service func
func toDecryptContent(key string, content string) string {
	return handler_crypto.Decrypt(key, content)
}

func getQueryPsmNew(app *handler_yaml.Application) []string {

	var queryCollection []string

	now := time.Now()

	// start date
	startDate := now.AddDate(0, 0, app.Date.Now)
	// past duration
	finalDate := app.Date.Now + app.Date.Duration
	dateTale := now.AddDate(0, 0, finalDate)

	// append query
	for now.Before(dateTale) {

		presentDate := startDate.Format("20060102")

		for _, sql := range app.SQL {

			query := strings.Replace(sql.Query, "$now", presentDate, -1)
			queryCollection = append(queryCollection, query)
		}

		startDate = startDate.AddDate(0, 0, 1) // 날짜를 하루씩 증가시킴
	}

	// fmt.Println("### Query Collection ")
	// for _, sql := range queryCollection {
	// 	fmt.Printf("    - Query:\n")
	// 	fmt.Printf("        %s\n", sql)
	// }

	return queryCollection
}

func getQueryPsmNewCustom(app *handler_yaml.Application, beginDate string, endDate string) []string {

	var queryCollection []string

	// start date
	startDate, _ := time.Parse("20060102", beginDate)
	// end date
	dateTale, _ := time.Parse("20060102", endDate)

	// append query
	for startDate.Before(dateTale) || startDate.Equal(dateTale) {

		presentDate := startDate.Format("20060102")

		for _, sql := range app.SQL {

			query := strings.Replace(sql.Query, "$now", presentDate, -1)
			queryCollection = append(queryCollection, query)
		}

		startDate = startDate.AddDate(0, 0, 1) // 날짜를 하루씩 증가시킴
	}

	return queryCollection
}

func getQuerySummary(app *handler_yaml.Application) []string {

	var queryCollection []string

	now := time.Now()

	// get 1 day ago
	now = now.AddDate(0, 0, app.Date.Now)

	nowDate := now.Format("20060102")
	for _, sql := range app.SQL {

		query := strings.Replace(sql.Query, "$now", nowDate, -1)
		queryCollection = append(queryCollection, query)
	}

	return queryCollection
}

func getQueryMonthly(app *handler_yaml.Application) []string {

	var queryCollection []string

	now := time.Now()

	// get 1 day ago
	now = now.AddDate(0, 0, app.Date.Now)

	// Extract the first day of the month from yesterday's date
	firstOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.Local)

	nowDate := now.Format("20060102")
	for _, sql := range app.SQL {

		query := strings.Replace(sql.Query, "$monthOneDay", firstOfMonth.Format("20060102"), -1)
		query = strings.Replace(query, "$monthLastDay", nowDate, -1)
		queryCollection = append(queryCollection, query)
	}

	return queryCollection
}

func getQueryMonthlyCustom(app *handler_yaml.Application, beginDate string, endDate string) []string {

	var queryCollection []string

	// start date
	startDate, _ := time.Parse("20060102", beginDate)
	// end date
	dateTale, _ := time.Parse("20060102", endDate)

	nowDate := startDate.Format("20060102")
	for _, sql := range app.SQL {

		query := strings.Replace(sql.Query, "$monthOneDay", dateTale.Format("20060102"), -1)
		query = strings.Replace(query, "$monthLastDay", nowDate, -1)
		queryCollection = append(queryCollection, query)
	}

	return queryCollection
}

func ArgumentAnalyzer(params handler_argument.Arguments) {

	if params.Encode && !params.Decode && !params.Run && len(params.File) > 0 && params.Pwd {
		/*
		 * Encode
		 */

		// password check
		if pwd := handler_argument.GetPassword(); strings.Compare(key, pwd) != 0 {
			fmt.Println("> - password is wrong")
			return
		}

		// file encode
		kind := "encode"
		script_filename := params.File
		convertToFile(key, script_filename, kind)

	} else if !params.Encode && params.Decode && !params.Run && len(params.File) > 0 && params.Pwd {
		/*
		 * Decode
		 */

		// password check
		if pwd := handler_argument.GetPassword(); strings.Compare(key, pwd) != 0 {
			fmt.Println("> - password is wrong")
			return
		}

		// file decode
		kind := "decode"
		script_filename := params.File
		convertToFile(key, script_filename, kind)

	} else {

		/*
		 * Run
		 */

		if !params.Encode && !params.Decode && params.Run && !handler_argument.IsInScriptList(params.Script) {
			fmt.Printf("> - %s is not on the script list\n", params.Script)
			return
		} else if !params.Encode && !params.Decode && params.Run && handler_argument.IsInScriptList(params.Script) {

			// encrypt 된 file 로 강제
			scriptFile := fmt.Sprintf("%s/%s.enc", defaultPath, params.Script)
			if !handler_file.IsFileExist(scriptFile) {
				fmt.Println("> - script file is not exist")
				return
			}

			// DB 정보 있는지 확인
			dbFile := fmt.Sprintf("%s/%s", defaultPath, dbfile)
			if !handler_file.IsFileExist(dbFile) {
				fmt.Println("> - DB connection file is not exist")
				return
			}

			// DB 정보 decoding
			dbContent := handler_file.ReadFile(dbFile)
			dbEncryptContent := string(dbContent)
			dbDecryptContent := toDecryptContent(key, dbEncryptContent)
			config := handler_yaml.ReadConfigYamlByString(dbDecryptContent)

			// get db connection
			db := handler_db.Dbconnection(&config)

			defer db.Close()

			// script decoding
			scriptContent := handler_file.ReadFile(scriptFile)
			scriptEncryptContent := string(scriptContent)
			scriptDecryptContent := toDecryptContent(key, scriptEncryptContent)
			app := handler_yaml.ReadApplicationYamlByString(scriptDecryptContent)

			var queryCollection []string

			// script selector
			switch {
			case strings.Contains(app.Name, "psm_new"):
				if check, _ := handler_argument.IsDate(params.StartDate, params.EndDate); check {
					queryCollection = getQueryPsmNewCustom(&app, params.StartDate, params.EndDate)
				} else {
					queryCollection = getQueryPsmNew(&app)
				}
			case strings.Contains(app.Name, "summary"):
				queryCollection = getQuerySummary(&app)
			case strings.Contains(app.Name, "month"):
				if check, _ := handler_argument.IsDate(params.StartDate, params.EndDate); check {
					queryCollection = getQueryPsmNewCustom(&app, params.StartDate, params.EndDate)
				} else {
					queryCollection = getQueryPsmNew(&app)
				}
			default:
				fmt.Println("??? : The corresponding sql script is not on the list")
			}

			// run script
			for idx, query := range queryCollection {
				fmt.Printf("++ query : %d\n", idx)

				handler_db.ExecQuery(db, query)
			}

			fmt.Printf("app [ %s ] read finish\n", app.Name)

		}
	}

}
