package lsp

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
