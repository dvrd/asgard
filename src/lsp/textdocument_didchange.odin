package lsp


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
