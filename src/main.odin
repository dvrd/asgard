package asgard

import "analysis"
import "core:bufio"
import "core:encoding/json"
import "core:fmt"
import "core:io"
import "core:log"
import "core:os"
import "lsp"
import "rpc"
import "server"


main :: proc() {
	logger, fd := create_logger()
	defer os.close(fd)
	context.logger = logger^

	log.info("Initializing Asgard")

	server.start()

	log.info("Closing Asgard")
}
