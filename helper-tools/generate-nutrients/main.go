package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"gopkg.in/yaml.v3"
)

type Recipe struct {
	Name        string        `yaml:"name"`
	Ingredients []Ingredients `yaml:"ingredients"`
	Nutrition   Nutrition     `yaml:"nutrition"`
	Time        int           `yaml:"time"`
	Complexity  int           `yaml:"complexity"`
	Origin      string        `yaml:"origin"`
}
type Ingredients struct {
	Name   string `yaml:"name"`
	Amount string `yaml:"amount,omitempty"`
}
type Nutrition struct {
	Kcal          int     `yaml:"kcal"`
	Fat           float64 `yaml:"fat"`
	Carbohydrates float64 `yaml:"carbohydrates"`
	Protein       float64 `yaml:"protein"`
}

func readConf(filename string) (*Recipe, error) {
	buf, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	c := &Recipe{}
	err = yaml.Unmarshal(buf, c)
	if err != nil {
		return nil, fmt.Errorf("in file %q: %w", filename, err)
	}

	return c, err
}

func main() {

	if len(os.Args) != 2 {
		log.Fatalln("Expected exactly one argument")
	}

	yaml_path := os.Args[1]

	recipe, err := readConf(yaml_path)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf(`
- Brennwert: %vkcal
- Fett: %vg
- Kohlenhydrate: %vg
- Eiweiß: %vg`,
		recipe.Nutrition.Kcal,
		recipe.Nutrition.Fat,
		recipe.Nutrition.Carbohydrates,
		recipe.Nutrition.Protein,
	)

	// fmt.Printf("%#v", c)
}
