package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"reflect"
	"time"
)

var myLogger *log.Logger

func main() {
	fpLog, err := os.OpenFile("logfile.txt", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err != nil {
		panic(err)
	}
	defer fpLog.Close()

	/*
		* log format
		INFO: 2024/05/20 09:56:57 test.go:28: Test
		INFO: 2024/05/20 09:56:57 test.go:24: End of Program
	*/

	myLogger = log.New(fpLog, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	// 파일과 화면에 같이 출력하기 위해 MultiWriter 생성
	multiWriter := io.MultiWriter(fpLog, os.Stdout)
	myLogger.SetOutput(multiWriter)

	run()
	myLogger.Println("End of Program")
	myLogger.Println("-- begin example time --")
	exTime()

	myLogger.Println("-- begin get time Formatting --")
	getTimeFormatting()

	myLogger.Println("-- begin subtract time Formatting --")
	subTime()

	myLogger.Println("-- begin subtract Day/Year Formatting --")
	subDayYear()

	myLogger.Println("-- begin get time --")
	restoreTime, _ := getTime("20250515")
	fmt.Println(restoreTime)

	var input string
	fmt.Scanln(&input)
	fmt.Println(input)
}

func run() {
	myLogger.Print("Test")
}

func exTime() {
	now := time.Now()
	secs := now.Unix()
	nanos := now.UnixNano()

	millis := nanos / 1000000

	fmt.Println(now)
	fmt.Println(secs)
	fmt.Println(millis)
	fmt.Println(nanos)

	fmt.Println(time.Unix(secs, 0))
	fmt.Println(time.Unix(0, nanos))
}

func getTimeFormatting() {
	p := fmt.Println
	t := time.Now()

	p(t.Format(time.RFC3339))

	t1, e := time.Parse(
		time.RFC3339,
		"2012-11-01T22:08:41+00:00")

	p(t1)

	p(t.Format("3:04PM"))
	p(t.Format("Mon Jan _2 15:04:05 2006"))
	p(t.Format("2006-01-02T15:04:05.999999-07:00"))

	form := "3 04 PM"
	t2, e := time.Parse(form, "8 41 PM")
	p(t2)

	fmt.Printf("%d-%02d-%02dT%02d:%02d:%02d-00:00\n",
		t.Year(), t.Month(), t.Day(),
		t.Hour(), t.Minute(), t.Second())

	ansic := "Mon Jan _2 15:04:05 2006"
	_, e = time.Parse(ansic, "8:41PM")
	p(e)
}

func subTime() {
	now := time.Now()

	convMinutes, _ := time.ParseDuration("10m")
	convHours, _ := time.ParseDuration("1h")
	diffMinutes := now.Add(-convMinutes).Format("2006-01-02 15:04:05")
	diffHours := now.Add(-convHours).Format("2006-01-02 15:04:05")

	fmt.Println(now)
	fmt.Println(diffMinutes)
	fmt.Println(diffHours)

}

func subDayYear() {
	now := time.Now()

	convDays := 1
	convMonths := 1
	convYears := 1

	diffDays := now.AddDate(0, 0, -convDays).Format("2006-01-02 15:04:05")
	diffMonths := now.AddDate(0, -convMonths, 0).Format("2006-01-02 15:04:05")
	diffYears := now.AddDate(-convYears, 0, 0).Format("2006-01-02 15:04:05")

	fmt.Println(now)
	fmt.Println(diffDays)
	fmt.Println(diffMonths)
	fmt.Println(diffYears)

	yesterday := now.AddDate(0, 0, -convDays).Format("20060102")
	fmt.Println(yesterday)
	fmt.Println(reflect.TypeOf(yesterday))

	restoration := fmt.Sprintf("%s-%s-%s", yesterday[:4], yesterday[4:6], yesterday[6:8])
	fmt.Println(time.Parse(time.DateOnly, restoration))
}

func getTime(dateString string) (time.Time, error) {
	restoration := fmt.Sprintf("%s-%s-%s", dateString[:4], dateString[4:6], dateString[6:8])
	return time.Parse(time.DateOnly, restoration)

}
