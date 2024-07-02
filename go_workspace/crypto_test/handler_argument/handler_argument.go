package handler_argument

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strings"
	"syscall"

	"golang.org/x/crypto/ssh/terminal"
)

// client line tool option
type Arguments struct {
	// mode enc/dec
	Encode bool
	Decode bool

	// sub mode
	Pwd  bool
	File string
	Out  string

	// mode run
	Run    bool
	Script string
}

var Scripts = []string{
	"psm_new",
	"summary_download",
	"summary_misdetect",
	"summary_reqtype",
	"summary_statistics",
	"summary_time",
	"summary_download_month",
	"summary_reqtype_monthly",
	"summary_statistics_monthly",
	"summary_time_monthly",
}

/*
 * @DESC: arguments test
 * @Deprecated
 */
func GetArgs() []string {

	if len(os.Args) < 2 {
		panic("Error : need 2 more argument")
	}

	programName := os.Args[0:1]
	firstArg := os.Args[1:2]
	secondArg := os.Args[2:3]
	allArg := os.Args[1:]

	fmt.Println(programName)
	fmt.Println(firstArg)
	fmt.Println(secondArg)
	fmt.Println(allArg)

	return []string{os.Args[0], os.Args[1], os.Args[2], strings.Join(os.Args[1:], " ")}

}

func GetFlags() (bool, Arguments) {

	defaultParams := Arguments{
		// mode enc/dec
		Encode: false,
		Decode: false,

		// sub mode
		Pwd:  false,
		File: "./script/.db.connection.enc",
		Out:  "stdout",

		// mode run
		Run:    false,
		Script: "",
	}

	var params Arguments

	flag.CommandLine = flag.NewFlagSet(os.Args[0], flag.ExitOnError)

	addPrefix := func(str []string) string {
		mapped := make([]string, len(str))
		for i, v := range Scripts {
			mapped[i] = "- " + v
		}

		return "Select one\n" + strings.Join(mapped, "\n")
	}
	msg := addPrefix(Scripts)

	flag.BoolVar(&params.Encode, "enc", defaultParams.Encode, "Encoding mode")
	flag.BoolVar(&params.Decode, "dec", defaultParams.Decode, "Decoding mode")
	flag.BoolVar(&params.Run, "run", defaultParams.Run, "Running script")
	flag.StringVar(&params.File, "f", defaultParams.File, "Input file")
	flag.StringVar(&params.Out, "o", defaultParams.Out, "script stdout or filename")
	flag.BoolVar(&params.Pwd, "W", defaultParams.Pwd, "encode/decode password")

	flag.StringVar(&params.Script, "script", defaultParams.Script, msg)

	showDisplay := func() {
		fmt.Fprintln(os.Stderr, " __   __     ______     ______     __  __    ")
		fmt.Fprintln(os.Stderr, "/\\ \"-.\\ \\   /\\  __ \\   /\\  == \\   /\\ \\/\\ \\   ")
		fmt.Fprintln(os.Stderr, "\\ \\ \\-.  \\  \\ \\  __ \\  \\ \\  __<   \\ \\ \\_\\ \\  ")
		fmt.Fprintln(os.Stderr, " \\ \\_\\\"\\__\\  \\ \\_\\ \\_\\  \\ \\_\\ \\_\\  \\ \\_____\\ ")
		fmt.Fprintln(os.Stderr, "  \\/_/ \\/_/   \\/_/\\/_/   \\/_/ /_/   \\/_____/ ")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "== Concealing Shell Script v 1.0 ==")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintf(os.Stderr, "Usage of %s:\n", "Concealing Shell Script v 1.0")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "## encode:")
		fmt.Fprintln(os.Stderr, "  scriptor -enc -f <filename> -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -enc -f <filename> -o <new filename> -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -enc -f <filename> -o stdout -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -enc -f <filename> -W")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "## decode:")
		fmt.Fprintln(os.Stderr, "  scriptor -dec -f <filename> -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -dec -f <filename> -o <new filename> -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -dec -f <filename> -o stdout -W")
		// fmt.Fprintln(os.Stderr, "  scriptor -dec -f <filename> -W")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "## run:")
		fmt.Fprintln(os.Stderr, "- scripter -run -script <scriptname : psm_new>")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "## option:")
		flag.PrintDefaults()
	}

	flag.Usage = showDisplay

	flag.Parse()

	if (flag.NFlag() == 0) || (flag.NFlag() > 5) || !wellFormed(params) {
		flag.Usage()
		// fmt.Fprintf(os.Stderr, "Usage of %s:\n", "Concealing Shell Script v 1.0")
		// fmt.Fprintln(os.Stderr, "")
		// fmt.Fprintln(os.Stderr, "## option:")
		// flag.PrintDefaults()

		os.Exit(1)
		// return false, "" /
	}

	return true, params
}

func wellFormed(params Arguments) bool {

	encode := (params.Encode && !params.Decode && !params.Run && len(params.File) > 0 && params.Pwd)
	decode := (!params.Encode && params.Decode && !params.Run && len(params.File) > 0 && params.Pwd)
	run := (!params.Encode && !params.Decode && params.Run && len(params.Script) > 0 && IsInScriptList(params.Script))

	return (encode || decode || run)

}

func GetPassword() string {
	fmt.Print("Enter password: ")
	bytePasword, err := terminal.ReadPassword(int(syscall.Stdin))
	if err != nil {
		fmt.Println("\nFailed to read password:", err)
		log.Fatalf("Failed to read password: %v", err)
	}
	fmt.Println("\n")

	pwd := string(bytePasword)

	// bytePasword clean up
	cleanUp := func(b []byte) []byte {
		return make([]byte, len(b))
	}

	bytePasword = cleanUp(bytePasword)
	_ = bytePasword

	return pwd

}

func IsInScriptList(script string) bool {
	contains := func(strs []string, str string) bool {
		for _, s := range strs {
			if str == s {
				return true
			}
		}
		return false
	}
	return contains(Scripts, script)
}
