package asgard

import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:log"
import "core:os"
import "lsp"
import "rpc"

DEBUG_FILE :: "/Users/kaku/dev/projects/asgard/debug.log"

main :: proc() {
	logger_options := log.Options{.Level, .Time, .Date}
	console_logger := log.create_console_logger(log.Level.Debug, logger_options)

	fd, err := os.open(
		DEBUG_FILE,
		os.O_RDWR | os.O_CREATE | os.O_APPEND,
		os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IROTH,
	)
	if err != os.ERROR_NONE {
		fmt.eprintln(ERRORNO_MSGS[err])
		os.exit(1)
	}
	defer os.close(fd)

	file_logger := log.create_file_logger(fd, log.Level.Debug, logger_options)
	context.logger = log.create_multi_logger(file_logger, console_logger)

	log.info("Initializing Asgard")

	scanner: bufio.Scanner
	bufio.scanner_init(&scanner, os.stream_from_handle(os.stdin))
	scanner.split = rpc.split
	defer bufio.scanner_destroy(&scanner)

	for bufio.scanner_scan(&scanner) {
		msg := bufio.scanner_bytes(&scanner)
		method, contents, err := rpc.decode(msg)
		if err != nil {
			log.errorf("Failed to decode message: %v", err)
			continue
		}
		handle_msg(method, contents)
	}
}

handle_msg :: proc(method: string, contents: []byte) {
	switch method {
	case "initialize":
		request: lsp.Request

		if err := json.unmarshal(contents, &request); err != nil {
			log.errorf("Failed to unmarshal initialize request: %v", err)
			return
		}
		log.infof("Received message:\n%#v", request)

		msg := lsp.new_initialize_response(request.id)
		response, err := rpc.encode(msg);if err != nil {
			log.errorf("Failed to encode initialize response: %v", err)
			return
		}

		stdout := os.stream_from_handle(os.stdout)
		if _, err = io.write_string(stdout, response); err != nil {
			log.error("Failed to send initialize response")
			return
		}
		log.infof("Message sent:\n%v", response)
	case:
		log.errorf("Unknown method: %v", method)
	}
}
