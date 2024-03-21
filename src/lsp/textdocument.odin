package lsp

TextDocumentItem :: struct {
	uri:         string `json:"uri"`,
	language_id: string `json:"languageId"`,
	version:     int `json:"version"`,
	text:        string `json:"text"`,
}

TextDocumentIdentifier :: struct {
	uri:     string `json:"uri"`,
	version: int `json:"version"`,
}

TextDocumentPositionParams :: struct {
	text_document: TextDocumentIdentifier `json:"textDocument"`,
	position:      Position `json:"position"`,
}

Position :: struct {
	line:      int `json:"line"`,
	character: int `json:"character"`,
}

Location :: struct {
	uri:   string `json:"uri"`,
	range: Range `json:"range"`,
}

Range :: struct {
	start: Position `json:"start"`,
	end:   Position `json:"end"`,
}

WorkspaceEdit :: struct {
	changes: map[string][]TextEdit `json:"changes"`,
}

TextEdit :: struct {
	range:    Range `json:"range"`,
	new_text: string `json:"newText"`,
}

TextDocumentCodeActionParams :: struct {
	text_document: TextDocumentIdentifier `json:"textDocument"`,
	range:         Range `json:"range"`,
	ctx:           CodeActionContext `json:"context"`,
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

CompletionParams :: TextDocumentPositionParams

CompletionItem :: struct {
	label:         string `json:"label"`,
	detail:        string `json:"detail"`,
	documentation: string `json:"documentation"`,
}

DefinitionParams :: TextDocumentPositionParams

PublishDiagnosticsParams :: struct {
	uri:         string `json:"uri"`,
	diagnostics: []Diagnostic `json:"diagnostics"`,
}

Diagnostic :: struct {
	range:    Range `json:"range"`,
	severity: int `json:"severity"`,
	source:   string `json:"source"`,
	message:  string `json:"message"`,
}

DidChangeTextDocumentParams :: struct {
	text_document:   TextDocumentIdentifier `json:"textDocument"`,
	content_changes: []TextDocumentContentChangeEvent `json:"contentChanges"`,
}

/**
 * An event describing a change to a text document. If only a text is provided
 * it is considered to be the full content of the document.
 */
TextDocumentContentChangeEvent :: struct {
	// The new text of the whole document.
	text: string `json:"text"`,
}

DidOpenTextDocumentParams :: struct {
	text_document: TextDocumentItem `json:"textDocument"`,
}

HoverParams :: TextDocumentPositionParams

HoverResult :: struct {
	contents: string `json:"contents"`,
}
