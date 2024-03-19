package rpc

import "core:bytes"
import "core:encoding/json"
import "core:fmt"
import "core:strconv"
import "core:strings"
import "core:testing"

encode :: proc(msg: any) -> string {
	content, err := json.marshal(msg)
	if err != nil {
		panic(fmt.tprintf("%v", err))
	}
	header := fmt.tprintf("Content-Length: %d\r\n\r\n", len(content))

	builder := strings.builder_make()
	strings.write_string(&builder, header)
	strings.write_bytes(&builder, content)

	return strings.to_string(builder)
}

BaseMessage :: struct {
	Method: string,
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

	return base_message.Method, content[:content_len], nil
}
