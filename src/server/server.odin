package server

import "asgard:analysis"
import "asgard:lsp"
import "asgard:rpc"

import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:log"
import "core:os"

start :: proc() {
	state := analysis.new_state()
	defer analysis.destroy_state(state)

	scanner: bufio.Scanner
	bufio.scanner_init(&scanner, os.stream_from_handle(os.stdin))
	scanner.split = rpc.split
	defer bufio.scanner_destroy(&scanner)

	for bufio.scanner_scan(&scanner) {
		msg := bufio.scanner_bytes(&scanner)
		method, contents, err := rpc.decode(msg);if err != nil {
			log.errorf("Failed to decode message: %v", err)
			continue
		}
		message_handler(method, contents, state)
	}
}
