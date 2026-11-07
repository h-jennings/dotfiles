-- Import updates for renamed `.vue` files (see the oil spec in plugins/tree.lua).
local M = {}

local function vtsls_for(path)
	for _, client in ipairs(vim.lsp.get_clients({ name = "vtsls" })) do
		local root = client.root_dir
		if root and vim.fs.relpath(root, path) then
			return client
		end
	end
end

function M.update_imports(src, dest)
	local client = vtsls_for(src)
	if not client then
		vim.notify("vtsls not running here; imports of " .. vim.fs.basename(src) .. " not updated", vim.log.levels.WARN)
		return
	end
	client:exec_cmd({
		title = "vue_rename",
		command = "typescript.tsserverRequest",
		arguments = { "getEditsForFileRename", { oldFilePath = src, newFilePath = dest } },
	}, {}, function(err, res)
		local body = res and res.body
		if err or type(body) ~= "table" or #body == 0 then
			return
		end
		-- tsserver positions are 1-based line/offset in UTF-16 units.
		local changes = {}
		for _, file in ipairs(body) do
			local edits = {}
			for _, c in ipairs(file.textChanges) do
				edits[#edits + 1] = {
					range = {
						start = { line = c.start.line - 1, character = c.start.offset - 1 },
						["end"] = { line = c["end"].line - 1, character = c["end"].offset - 1 },
					},
					newText = c.newText,
				}
			end
			changes[vim.uri_from_fname(file.fileName)] = edits
		end
		vim.lsp.util.apply_workspace_edit({ changes = changes }, "utf-16")
		vim.notify(("Updated imports in %d file(s)"):format(vim.tbl_count(changes)))
	end)
end

return M
