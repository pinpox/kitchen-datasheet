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

	// Number of rows is max(5, len(ingredients))
	nRows := len(recipe.Ingredients)
	if nRows < 5 {
		nRows = 5
	}

	// Rowspan is len(ingredients) - 4
	nRowspan := len(recipe.Ingredients) - 4
	if nRowspan < 1 {
		nRowspan = 1
	}

	fmt.Println("<table class='headertable'> <tbody>")

	for i := 0; i < nRows; i++ {
		fmt.Println("<tr>")

		if i == 0 {
			fmt.Printf("<td colspan='2' rowspan='%v'><h1>%v</h1></td>\n", nRowspan, recipe.Name)
		}

		if i == nRows-4 {
			fmt.Printf("<td>Zubereitungszeit</td><td>%v Minuten</td>\n", recipe.Time)
		}

		if i == nRows-3 {
			fmt.Printf("<td>Komplexität</td><td>%v/10</td>\n", recipe.Complexity)
		}

		if i == nRows-2 {
			fmt.Printf("<td>Energie</td><td>%vkcal</td>\n", recipe.Nutrition.Kcal)
		}

		if i == nRows-1 {
			fmt.Printf("<td>Herkunft</td><td>%v</td>\n", recipe.Origin)
		}

		if i < len(recipe.Ingredients) {
			fmt.Printf("<td>%v</td> <td>%v</td>\n", recipe.Ingredients[i].Amount, recipe.Ingredients[i].Name)
		} else {
			fmt.Println("<td></td> <td></td>")
		}

		fmt.Println("</tr>")
	}

	fmt.Println("</tbody> </table>")
}
