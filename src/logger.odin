package asgard

import "core:fmt"
import "core:log"
import "core:os"
import "errors"

DEBUG_FILE :: "/tmp/asgard.log"

BLUE :: "\x1B[34m"
RED :: "\x1B[91m"
PURPLE :: "\x1B[35m"
END :: "\x1b[0m"

ERROR :: "\x1B[91m\x1b[0m"
SUCCESS :: "\x1B[32m\x1b[0m"
WARNING :: "\x1B[33m\x1b[0m"
INFO :: "\x1B[34m\x1B[0m"
DEBUG :: "\x1B[35m\x1B[0m"

when ODIN_DEBUG {
	lowest :: log.Level.Debug
} else {
	lowest :: log.Level.Info
}

inform :: proc(message: string, args: ..any) {
	fmt.print(INFO, "")
	log.infof(message, ..args)
}

debug :: proc(message: string, args: ..any) {
	when ODIN_DEBUG {fmt.print(DEBUG, "")}
	log.debugf(message, ..args)
}

error :: proc(message: string, args: ..any) {
	fmt.print(ERROR, "")
	log.errorf(message, ..args)
}

open_file :: proc(filepath: string) -> os.Handle {
	fd, err := os.open(
		filepath,
		os.O_RDWR | os.O_CREATE | os.O_APPEND,
		os.S_IRUSR | os.S_IWUSR | os.S_IRGRP | os.S_IROTH,
	)
	if err != os.ERROR_NONE {
		fmt.eprintln(errors.NO_MSGS[err])
		os.exit(1)
	}
	return fd
}

create_logger :: proc() -> (logger: ^log.Logger, fd: os.Handle) {
	logger = new(log.Logger)
	logger_options := log.Options{.Level, .Time, .Date}
	fd = open_file(DEBUG_FILE)
	logger^ = log.create_file_logger(fd, lowest, logger_options)
	return
}
