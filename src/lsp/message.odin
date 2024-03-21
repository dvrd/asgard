package lsp

RequestId :: union {
	string,
	i64,
}

Request :: struct {
	rpc:    string `json:"jsonrpc"`,
	id:     RequestId `json:"id"`,
	method: string `json:"method"`,
	params: union {
		InitializeParams,
		TextDocumentCodeActionParams,
		CompletionParams,
	} `json:"params"`,
}

Response :: struct {
	rpc:    string `json:"jsonrpc"`,
	id:     RequestId `json:"id"`,
	result: union {
		InitializeResult,
		[]CodeAction,
		[]CompletionItem,
		Location,
		HoverResult,
	} `json:"result"`,
}

Notification :: struct {
	rpc:    string `json:"jsonrpc"`,
	method: string `json:"method"`,
	params: union {
		DidOpenTextDocumentParams,
		DidChangeTextDocumentParams,
		PublishDiagnosticsParams,
	} `json:"params"`,
}
