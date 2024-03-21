package lsp

TextDocumentCodeActionParams :: struct {
	textdocument: TextDocumentIdentifier `json:"textDocument"`,
	range:        Range `json:"range"`,
	ctx:          CodeActionContext `json:"context"`,
}

CodeActionContext :: struct {}

CodeAction :: struct {
	title:   string `json:"title"`,
	edit:    ^WorkspaceEdit `json:"edit,omitempty"`,
	command: ^Command `json:"command,omitempty"`,
}

Command :: struct {
	title:     string `json:"title"`,
	command:   string `json:"command"`,
	arguments: []any `json:"arguments,omitempty"`,
}
