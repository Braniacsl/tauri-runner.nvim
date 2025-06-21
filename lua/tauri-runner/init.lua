local M = {}

function M.setup(opts)
	local tauri_term = nil

	vim.keymap.set("n", "<leader>td", function()
		if tauri_term and not tauri_term.closed then
			tauri_term:focus()
			vim.notify("Focused existing Tauri Dev terminal.", vim.log.levels.INFO)
			return
		end

		tauri_term = require("snacks").terminal({ "pnpm", "tauri", "dev" }, {
			cwd = require("lazyvim.util").root.get(),
			show = false,
			on_exit = function()
				tauri_term = nil
			end,
		})
		vim.notify("Tauri Dev server started in the background.", vim.log.levels.INFO)
	end, { desc = "Tauri Dev (Start/Focus)" })

	vim.keymap.set("n", "<leader>tk", function()
		if tauri_term and not tauri_term.closed then
			tauri_term:destroy()
			vim.notify("Tauri Dev process killed.", vim.log.levels.INFO)
		else
			vim.notify("Tauri Dev process not running.", vim.log.levels.WARN)
		end
	end, { desc = "Tauri Dev (Kill)" })

	vim.notify("Tauri Runner keymaps enabled for this project.", vim.log.levels.INFO, { title = "Tauri Runner" })
end

return M
