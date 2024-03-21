package lsp

InitializeParams :: struct {
	client_info: ClientInfo `json:"clientInfo"`,
}

ClientInfo :: struct {
	name:    string `json:"name"`,
	version: string `json:"version"`,
}

InitializeResult :: struct {
	capabilities: ServerCapabilities `json:"capabilities"`,
	server_info:  ServerInfo `json:"serverInfo"`,
}

ServerCapabilities :: struct {
	text_document_sync:   int `json:"textDocumentSync"`,
	hover_provider:       bool `json:"hoverProvider"`,
	definition_provider:  bool `json:"definitionProvider"`,
	code_action_provider: bool `json:"codeActionProvider"`,
	completion_provider:  map[string]any `json:"completionProvider"`,
}

ServerInfo :: struct {
	name:    string `json:"name"`,
	version: string `json:"version"`,
}

new_initialize_response :: proc(id: RequestId) -> Response {
	return(
		Response {
			rpc = "2.0",
			id = id,
			result = InitializeResult {
				capabilities = ServerCapabilities {
					text_document_sync = 1,
					hover_provider = true,
					definition_provider = true,
					code_action_provider = true,
					completion_provider = map[string]any{},
				},
				server_info = ServerInfo{name = "asgard", version = "0.0.0.0.0.0-beta1.final"},
			},
		} \
	)
}
