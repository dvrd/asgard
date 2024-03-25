package server

import "asgard:analysis"
import "asgard:lsp"

import "core:encoding/json"
import "core:log"

message_handler :: proc(method: string, contents: []byte, state: ^analysis.State) {
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
