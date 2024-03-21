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
