package analysis

import "asgard:lsp"
import "core:fmt"
import "core:strings"

State :: struct {
	documents: map[string]string,
}

new_state :: proc() -> State {
	documents := make(map[string]string)
	return State{documents}
}

get_diagnostics_for_file :: proc(text: string) -> []lsp.Diagnostic {
	diagnostics := [dynamic]lsp.Diagnostic{}
	for line, row in strings.split(text, "\n") {
		if strings.contains(line, "VS Code") {
			idx := strings.index(line, "VS Code")
			append(
				&diagnostics,
				lsp.Diagnostic {
					range = line_range(row, idx, idx + len("VS Code")),
					severity = 1,
					source = "Common Sense",
					message = "Please make sure we use good language in this video",
				},
			)
		}

		if strings.contains(line, "Neovim") {
			idx := strings.index(line, "Neovim")
			append(
				&diagnostics,
				lsp.Diagnostic {
					range = line_range(row, idx, idx + len("Neovim")),
					severity = 2,
					source = "Common Sense",
					message = "Great choice :)",
				},
			)

		}
	}

	return diagnostics[:]
}

open_document :: proc(state: ^State, uri, text: string) -> []lsp.Diagnostic {
	state.documents[uri] = text

	return get_diagnostics_for_file(text)
}

update_document :: proc(state: ^State, uri, text: string) -> []lsp.Diagnostic {
	state.documents[uri] = text

	return get_diagnostics_for_file(text)
}

hover :: proc(state: ^State, id: int, uri: string, position: lsp.Position) -> lsp.Response {
	document := state.documents[uri]

	return(
		lsp.Response {
			rpc = "2.0",
			id = i64(id),
			result = lsp.HoverResult {
				contents = fmt.tprintf("File: %s, Characters: %d", uri, len(document)),
			},
		} \
	)
}

definition :: proc(state: ^State, id: int, uri: string, position: lsp.Position) -> lsp.Response {
	return(
		lsp.Response {
			rpc = "2.0",
			id = i64(id),
			result = lsp.Location {
				uri = uri,
				range = lsp.Range {
					start = lsp.Position{line = position.line - 1, character = 0},
					end = lsp.Position{line = position.line - 1, character = 0},
				},
			},
		} \
	)
}

text_document_code_action :: proc(state: ^State, id: int, uri: string) -> lsp.Response {
	text := state.documents[uri]

	actions := [dynamic]lsp.CodeAction{}
	for line, row in strings.split(text, "\n") {
		idx := strings.index(line, "VS Code")
		if idx >= 0 {
			replaceChange := map[string][]lsp.TextEdit{}
			replaceChange[uri] = []lsp.TextEdit {
				{range = line_range(row, idx, idx + len("VS Code")), new_text = "Neovim"},
			}

			append(
				&actions,
				lsp.CodeAction {
					title = "Replace VS C*de with a superior editor",
					edit = &lsp.WorkspaceEdit{changes = replaceChange},
				},
			)

			censorChange := map[string][]lsp.TextEdit{}
			censorChange[uri] = []lsp.TextEdit {
				{range = line_range(row, idx, idx + len("VS Code")), new_text = "VS C*de"},
			}

			append(
				&actions,
				lsp.CodeAction {
					title = "Censor to VS C*de",
					edit = &lsp.WorkspaceEdit{changes = censorChange},
				},
			)
		}
	}

	response := lsp.Response {
		rpc    = "2.0",
		id     = i64(id),
		result = actions[:],
	}

	return response
}

text_document_completion :: proc(state: ^State, id: int, uri: string) -> lsp.Response {
	// Ask your static analysis tools to figure out good completions
	items := []lsp.CompletionItem {
		 {
			label = "Neovim (BTW)",
			detail = "Very cool editor",
			documentation = "Fun to watch in videos. Don't forget to like & subscribe to streamers using it :)",
		},
	}

	response := lsp.Response {
		rpc    = "2.0",
		id     = i64(id),
		result = items,
	}

	return response
}

line_range :: proc(line, start, end: int) -> lsp.Range {
	return(
		lsp.Range {
			start = lsp.Position{line = line, character = start},
			end = lsp.Position{line = line, character = end},
		} \
	)
}
