package main

import (
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

func main() {
	sleepDuration := flag.Duration("sleep", 0, "Duration to sleep after download (e.g., 1s, 500ms, 2m)")
	flag.Parse()

	if flag.NArg() != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s [flags] <url> <destination>\n", os.Args[0])
		flag.PrintDefaults()
		os.Exit(1)
	}

	url := flag.Arg(0)
	dest := flag.Arg(1)

	resp, err := http.Get(url)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error downloading: %v\n", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		fmt.Fprintf(os.Stderr, "Error: received status code %d\n", resp.StatusCode)
		os.Exit(1)
	}

	out, err := os.Create(dest)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating file: %v\n", err)
		os.Exit(1)
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error writing file: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("Downloaded %s to %s\n", url, dest)

	if *sleepDuration > 0 {
		fmt.Printf("Sleeping for %s\n", *sleepDuration)
		time.Sleep(*sleepDuration)
		fmt.Println("Sleep complete")
	}
}
