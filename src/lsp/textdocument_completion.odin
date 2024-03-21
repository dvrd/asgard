package lsp

CompletionParams :: TextDocumentPositionParams

CompletionItem :: struct {
	label:         string `json:"label"`,
	detail:        string `json:"detail"`,
	documentation: string `json:"documentation"`,
}
