-- git.yazi shows per-file VCS status in the file list. `order` places its
-- column to the right of the size/mtime linemodes.
require("git"):setup({
	order = 1500,
})
