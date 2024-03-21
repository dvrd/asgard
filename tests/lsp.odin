package asgard_tests

import "asgard:lsp"
import "core:encoding/json"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

@(test)
new_response_test :: proc(t: ^testing.T) {
	using testing
	msg := "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"clientInfo\":{\"name\":\"Neovim\",\"version\":\"0.10.0\"}}}"
	request: lsp.Request
	err := json.unmarshal(transmute([]byte)msg, &request)
	if err != nil {
		error(t, err)
	}
	fmt.printf("request: %#v\n", request)

	response := lsp.new_initialize_response(request.id)
	fmt.printf("response: %#v\n", response)

	reply, err_2 := json.marshal(response)
	expected := "Content-Length: 53\r\n\r\n{\"jsonrpc\":\"2.0\",\"id\":1,\"result\":{\"capabilities\":{\"textDocumentSync\":1}}}"
	buf: [4]byte
	actual := strings.concatenate(
		{"Content-Length: ", strconv.itoa(buf[:], len(reply)), "\r\n\r\n", transmute(string)reply},
	)

	expect(t, actual == expected, fmt.tprintf("\nExpected:\n%v\nActual:\n%v", expected, actual))
}
