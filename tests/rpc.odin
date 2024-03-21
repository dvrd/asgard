package asgard_tests

import "asgard:rpc"
import "core:encoding/json"
import "core:fmt"
import "core:testing"

MessageExample :: struct {
	testing: bool,
}

@(test)
encode_test :: proc(t: ^testing.T) {
	using testing
	msg := rpc.BaseMessage{"hi"}
	expected := "Content-Length: 15\r\n\r\n{\"method\":\"hi\"}"
	actual, err := rpc.encode(msg)

	expect(t, actual == expected, fmt.tprintf("\nExpected:\n%v\nActual:\n%v", expected, actual))
}

@(test)
decode_test :: proc(t: ^testing.T) {
	using testing
	msg := "Content-Length: 15\r\n\r\n{\"method\":\"hi\"}"
	expected := "hi"
	actual, content, err := rpc.decode(transmute([]u8)msg)

	expect(t, err == nil, fmt.tprintf("Expected: %v, Actual: %v", nil, err))
	expect(t, actual == expected, fmt.tprintf("Expected: %v, Actual: %v", expected, actual))
	expect(t, len(content) == 15, fmt.tprintf("Expected: %v, Actual: %v", 15, len(content)))
}

@(test)
decode_error_test :: proc(t: ^testing.T) {
	using testing

	msg := "hello"
	expected := rpc.DecodeError.MissingDelimeter
	method, content, actual := rpc.decode(transmute([]u8)msg)

	expect(t, actual == expected, fmt.tprintf("Expected: %v, Actual: %v", expected, actual))

	msg = "content-length\r\n\r\n{\"testing\":true}"
	expected = rpc.DecodeError.HeaderTooShort
	method, content, actual = rpc.decode(transmute([]u8)msg)

	expect(t, actual == expected, fmt.tprintf("Expected: %v, Actual: %v", expected, actual))

	msg = "content-length: 16\r\n\r\n{\"t\": \"hello\"}"
	expected = rpc.DecodeError.ContentLengthMismatch
	method, content, actual = rpc.decode(transmute([]u8)msg)

	expect(t, actual == expected, fmt.tprintf("Expected: %v, Actual: %v", expected, actual))

	msg = "content-length: 18\r\n\r\n{testing: 'hello'}"
	expected = rpc.DecodeError.UnmarshalError
	method, content, actual = rpc.decode(transmute([]u8)msg)

	expect(t, actual == expected, fmt.tprintf("Expected: %v, Actual: %v", expected, actual))
}
