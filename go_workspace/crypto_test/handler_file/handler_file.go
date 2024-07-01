package handler_file

import (
	"fmt"
	"io"
	"path/filepath"
	"time"

	// "io/ioutil"
	"os"
)

func CheckError(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func ReadFile(filePath string) []byte {

	// open file
	// data, err := ioutil.ReadFile(filename)
	file, err := os.ReadFile(filePath)

	CheckError(err)

	return file

}

func ReadFileToReader(filePath string) (io.Reader, error) {
	// 파일 열기
	file, err := os.Open(filePath)

	CheckError(err)

	// 파일을 읽고 닫기
	// defer file.Close()

	// 파일을 읽어서 io.Reader로 반환
	return file, nil
}

func WriteFile(filename string, content string, path string) {
	// var byts []byte = []byte(content)

	newFilename := getUniqueFilename(filename)
	if path != "" {
		newFilename = path + "/" + filepath.Base(newFilename)
	}
	fmt.Printf("> + new filename:\t%s\n", newFilename)

	file, err := os.Create(newFilename)

	CheckError(err)

	defer file.Close()

	// fmt.Fprintf(file, string(byts))

	fmt.Fprint(file, content)
}

// remove file extention
func GetFileName(p string) string {
	return p[0 : len(p)-len(filepath.Ext(p))]
}

// replace file extention
func ReplaceFileExtension(filename string, preExt string, postExt string) string {
	// filepath.Ext(filename) => .yml | .enc
	if filepath.Ext(filename)[1:] == preExt {
		filename = GetFileName(filename) + "." + postExt
	}

	return filename
}

// 기존에 저장된 파일을 유지하기 위해
// 중복될 경우 파일이름을 날짜_시간_순번으로 표기
func getUniqueFilename(filename string) string {
	var newFilename string

	base := GetFileName(filename)
	ext := filepath.Ext(filename)

	// fmt.Printf(">+ base filename : %s\n", base)

	// not exist default yaml
	_, err := os.Stat(filename)
	if os.IsNotExist(err) {

		newFilename = fmt.Sprintf("%s%s", base, ext)

		return newFilename
	}

	// not exist default yaml
	// time format : YYYYMMDD_HHMMSS
	timestamp := time.Now().Format("20060102_150405")

	newFilename = fmt.Sprintf("%s_%s%s", base, timestamp, ext)

	counter := 0
	for {
		_, err := os.Stat(newFilename)
		if os.IsNotExist(err) {
			break
		}
		counter++
		newFilename = fmt.Sprintf("%s_%s_%d%s", base, timestamp, counter, ext)
	}

	return newFilename
}

func IsFileExist(file string) bool {
	// not exist default yaml
	_, err := os.Stat(file)

	return !os.IsNotExist(err)

}
