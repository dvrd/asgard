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

DEBUG_FILE :: "/Users/kakurega/Developer/projects/asgard/debug.log"

main :: proc() {
	logger_options := log.Options{.Level, .Time, .Date}

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

	context.logger = log.create_file_logger(fd, log.Level.Debug, logger_options)

	log.info("Initializing Asgard")

	state := analysis.new_state()
	defer analysis.destroy_state(state)

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
		handle_msg(method, contents, state)
	}

	log.info("Closing Asgard")
}

handle_msg :: proc(method: string, contents: []byte, state: ^analysis.State) {
	log.infof("Received msg with method: %s", method)

	switch method {
	case "initialize":
		request: lsp.Request

		if err := json.unmarshal(contents, &request); err != nil {
			log.errorf("Failed to unmarshal initialize request: %v", err)
			return
		}

		log.infof(
			"Connected to: %s %s",
			request.params.(lsp.InitializeParams).client_info.name,
			request.params.(lsp.InitializeParams).client_info.version,
		)

		write_response(lsp.new_initialize_response(request.id))
		log.info("Sent initialize response")
	case "textDocument/didOpen":
		request: lsp.Notification
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/didOpen: %s", err)
			return
		}
		params := request.params.(lsp.DidOpenTextDocumentParams)

		log.infof("Opened: %s", params.text_document.uri)
		write_response(
			lsp.Notification {
				rpc = "2.0",
				method = "textDocument/publishDiagnostics",
				params = lsp.PublishDiagnosticsParams {
					uri = params.text_document.uri,
					diagnostics = analysis.open_document(
						state,
						params.text_document.uri,
						params.text_document.text,
					),
				},
			},
		)
	case "textDocument/didChange":
		request: lsp.Notification
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/didChange: %s", err)
			return
		}
		params := request.params.(lsp.DidChangeTextDocumentParams)

		log.infof("Changed: %s", params.text_document.uri)
		for change in params.content_changes {
			write_response(
				lsp.Notification {
					rpc = "2.0",
					method = "textDocument/publishDiagnostics",
					params = lsp.PublishDiagnosticsParams {
						uri = params.text_document.uri,
						diagnostics = analysis.update_document(
							state,
							params.text_document.uri,
							change.text,
						),
					},
				},
			)
		}
	case "textDocument/hover":
		request: lsp.Request
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/hover: %s", err)
			return
		}

		params := request.params.(lsp.HoverParams)
		write_response(
			analysis.hover(state, request.id, params.text_document.uri, params.position),
		)
	case "textDocument/definition":
		request: lsp.Request
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/definition: %s", err)
			return
		}

		write_response(
			analysis.definition(
				state,
				request.id,
				request.params.(lsp.DefinitionParams).text_document.uri,
				request.params.(lsp.DefinitionParams).position,
			),
		)
	case "textDocument/codeAction":
		request: lsp.Request
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/codeAction: %s", err)
			return
		}

		write_response(
			analysis.text_document_code_action(
				state,
				request.id,
				request.params.(lsp.TextDocumentCodeActionParams).text_document.uri,
			),
		)
	case "textDocument/completion":
		request: lsp.Request
		if err := json.unmarshal(contents, &request); err != nil {
			log.infof("textDocument/codeAction: %s", err)
			return
		}

		write_response(
			analysis.text_document_completion(
				state,
				request.id,
				request.params.(lsp.CompletionParams).text_document.uri,
			),
		)
	}
}


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
