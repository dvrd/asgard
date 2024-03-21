package rpc

import "core:bufio"
import "core:bytes"
import "core:encoding/json"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

encode :: proc(msg: any) -> (string, json.Marshal_Error) {
	content, err := json.marshal(msg)
	if err != nil {
		return "", err
	}
	header := fmt.tprintf("Content-Length: %d\r\n\r\n", len(content))

	builder := strings.builder_make()
	strings.write_string(&builder, header)
	strings.write_bytes(&builder, content)

	return strings.to_string(builder), nil
}

BaseMessage :: struct {
	method: string `json:"method"`,
}

HEADER_LEN :: 16

DecodeError :: enum {
	MissingDelimeter,
	HeaderTooShort,
	ContentLengthMismatch,
	UnmarshalError,
}

decode :: proc(msg: []byte) -> (string, []byte, DecodeError) {
	data := bytes.split(msg, {'\r', '\n', '\r', '\n'})
	if len(data) != 2 {
		return "", nil, .MissingDelimeter
	}

	header := data[0]
	if len(header) <= HEADER_LEN {
		return "", nil, .HeaderTooShort
	}

	content_len_bytes := header[HEADER_LEN:]
	content_len := strconv.atoi(transmute(string)content_len_bytes)

	if content_len > len(data[1]) {
		return "", nil, .ContentLengthMismatch
	}

	content := data[1][:content_len]

	base_message := BaseMessage{}
	err := json.unmarshal(content, &base_message)
	if err != nil {
		return "", nil, .UnmarshalError
	}

	return base_message.method, content[:content_len], nil
}

split :: proc(
	data: []byte,
	at_eof: bool,
) -> (
	advance: int,
	token: []byte,
	err: bufio.Scanner_Error,
	final_token: bool,
) {
	split_data := bytes.split(data, {'\r', '\n', '\r', '\n'})
	if len(split_data) != 2 {
		return 0, nil, nil, false
	}

	header := split_data[0]
	content_len_bytes := header[HEADER_LEN:]
	content_len := strconv.atoi(transmute(string)content_len_bytes)

	if content_len > len(split_data[1]) {
		return 0, nil, nil, false
	}

	total_len := len(split_data[0]) + 4 + content_len
	content := data[:total_len]

	return total_len, content, nil, true
}

send_response :: proc(response: any, writer: ^Writer) -> bool {
	data, error := marshal(response, {}, context.temp_allocator)

	header := fmt.tprintf("Content-Length: %v\r\n\r\n", len(data))

	if error != nil {
		return false
	}

	if !write_sized(writer, transmute([]u8)header) {
		return false
	}

	if !write_sized(writer, data) {
		return false
	}

	return true
}
