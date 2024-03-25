package server

import "asgard:rpc"
import "core:io"
import "core:log"
import "core:os"

write_response :: proc(msg: any) {
	response, err := rpc.encode(msg);if err != nil {
		log.errorf("Failed to encode initialize response: %v", err)
		return
	}
	stdout := os.stream_from_handle(os.stdout)
	if _, err = io.write_string(stdout, response); err != nil {
		log.error("Failed to send initialize response")
		return
	}
}
