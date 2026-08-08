# Package gaps

The image build must stay passing rather than guess at package substitutions. Items remain here until `dnf5 repoquery` confirms a Fedora 44, RPM Fusion, or explicitly approved signed repository package.

| Nix capability | Status | Fedora action |
| --- | --- | --- |
| Filen desktop | Vendor RPM lacks a pinned, repository-signed Fedora channel in the archived implementation | Install manually only after a signed, versioned source is selected. |
| Cider 2 | No verified Fedora 44 RPM mapping | Use an explicitly selected upstream distribution later. |
| SearXNG plus Redis service integration | No verified Fedora 44 package mapping | Keep disabled; do not silently replace the localhost service. |
| Typst, resvg, vvenc, rmpc, and cosign | No verified Fedora 44 package mapping | Record the missing capability; cosign is not needed for local-only publishing policy. |
| basedpyright, deno, fish-lsp, Harper, Lua language server, Prettier, StyLua, Tinymist, VS Code JSON/YAML language servers, yamlfmt, Elixir LS, TypeScript language server, and ZLS | No verified Fedora 44 package mapping | Do not guess package names or install floating binaries during the image build. |
| Symbols Nerd Font Mono, Victor Mono, and Nerd Font variants | No verified Fedora 44 package mapping | Fedora owns verified fonts; keep configured family fallbacks explicit. |
| Nix-specific language tools (`nil`, `nixd`, `nixfmt`, `alejandra`) | Deliberately unavailable in the no-Nix profile | Retained only in `mydots`. |
| `mcp-nixos` | Deliberately unavailable in the no-Nix profile | Removed from Codex, OpenCode, and global MCP configuration. |
| `init-gum` and NixOS `update` scripts | Deliberately unavailable in the Fedora profile | Retained only in `mydots`. |

Before adding anything from Terra, COPR, or a vendor repository, verify the Fedora 44 release path, repository signature configuration, and exact `dnf5 repoquery` result. Do not use `--nogpgcheck` or a floating direct RPM URL.
