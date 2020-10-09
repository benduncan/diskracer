package main

/*

    .___.__        __
  __| _/|__| _____|  | ______________    ____  ___________
 / __ | |  |/  ___/  |/ /\_  __ \__  \ _/ ___\/ __ \_  __ \
/ /_/ | |  |\___ \|    <  |  | \// __ \\  \__\  ___/|  | \/
\____ | |__/____  >__|_ \ |__|  (____  /\___  >___  >__|
	 \/         \/     \/            \/     \/    \/

@bennydee

*/

/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import (
	"bufio"
	"compress/bzip2"
	"fmt"
	"log"
	"os"
	"strconv"
)

func main() {

	fmt.Println("Testing")

	inputFilePath := os.Args[1]

	fmt.Printf("Opening %s", inputFilePath)

	f, err := os.Open(inputFilePath)

	if err != nil {
		log.Fatal(err)
	}

	f.Seek(7078469, 0)

	inputFile := bufio.NewReader(f)

	header, err := inputFile.Peek(256)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(header[0:10])

	// Header
	fmt.Printf("Header = %s\n%x\n", header[0:2], header[0:2])

	// non-Huffman entropy encoding
	fmt.Printf("Entrop encoding = %s\n%x\n", header[2:3], header[2:3])

	// compression level
	fmt.Printf("Compression level = %s\n%x\n", header[3:4], header[3:4])

	level, _ := strconv.Atoi(string(header[3:4]))

	blockSize := 100 * 1000 * (level)

	fmt.Println("Blocksize = ", level, blockSize)

	inputReader := bzip2.NewReader(inputFile)

	// Empty byte slice.

	for {

		result := make([]byte, 1024)

		// Read in data.
		count, _ := inputReader.Read(result)

		if count == 0 {
			break
		}

		// Print our decompressed data.
		fmt.Println(count)
		fmt.Println(string(result))

	}

	//decoder := xml.NewDecoder(inputFile)

}
