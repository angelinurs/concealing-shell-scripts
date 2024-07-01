package handler_yaml

import (
	"fmt"
	"log"
	"strings"

	"os"

	// "gopkg.in/yaml.v2"
	"gopkg.in/yaml.v3"
)

type Config struct {
	Hostname   string `yaml:"HOSTNAME"`
	Username   string `yaml:"USERNAME"`
	Password   string `yaml:"PASSWORD"`
	Database   string `yaml:"DATABASE"`
	Port       string `yaml:"PORT"`
	DriverName string `yaml:"DRIVERNAME"`
}

type Application struct {
	Name string `yaml:"name"`
	Desc string `yaml:"desc"`
	Date struct {
		Now      int `yaml:"now"`
		Duration int `yaml:"duration"`
	} `yaml:"date"`
	SQL []struct {
		ID    int    `yaml:"id"`
		Query string `yaml:"query"`
	} `yaml:"sql"`
}

/*
 * Not use yaml.Unmarshal
 * @Deprecated
 */
// func ExtractConfigFromYaml(content []byte, config *Config) {
// 	err := yaml.Unmarshal(content, &config)

// 	if err != nil {
// 		fmt.Println(err)
// 	}
// }

func ReadYAMLFile(filePath string, v interface{}) error {
	// 파일 열기
	file, err := os.Open(filePath)
	if err != nil {
		return fmt.Errorf("failed to open file: %v", err)
	}
	defer file.Close()

	// YAML 디코더 생성
	decoder := yaml.NewDecoder(file)

	// YAML 데이터를 구조체로 읽어오기
	if err := decoder.Decode(v); err != nil {
		return fmt.Errorf("failed to decode YAML: %v", err)
	}

	return nil
}

func readYAMLContent(content string, v interface{}) error {

	reader := strings.NewReader(content)

	// YAML 디코더 생성
	decoder := yaml.NewDecoder(reader)

	// YAML 데이터를 구조체로 읽어오기
	if err := decoder.Decode(v); err != nil {
		return fmt.Errorf("failed to decode YAML: %v", err)
	}

	return nil
}

func ReadConfigYamlByString(content string) Config {
	var app Config

	// YAML string 읽기 및 구조체로 언마샬링
	if err := readYAMLContent(content, &app); err != nil {
		log.Fatalf("error reading %s YAML Content: %v", content, err)
	}

	return app
}

func ReadApplicationYamlByString(content string) Application {
	var app Application

	// YAML string 읽기 및 구조체로 언마샬링
	if err := readYAMLContent(content, &app); err != nil {
		log.Fatalf("error reading %s YAML Content: %v", content, err)
	}

	return app
}

/*
 * Not use runScript
 * @Deprecated
 */
// func RunScript(script string) {
// 	cmd := exec.Command(script)
// 	// cmd := exec.Command("ls", "-al")
// 	cmd.Stdout = os.Stdout

// 	if err := cmd.Run(); err != nil {
// 		fmt.Println(err)
// 	}
// }
