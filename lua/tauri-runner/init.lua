local M = {}

function M.setup(opts)
	local tauri_workflow_group = vim.api.nvim_create_augroup("TauriWorkflow", { clear = true })

	local tauri_term = nil

	vim.api.nvim_create_autocmd("BufEnter", {
		group = tauri_workflow_group,
		pattern = "*",
		callback = function(args)
			local project_root = vim.fs.find({ "tauri.conf.json" }, {
				upward = true,
				path = vim.api.nvim_buf_get_name(args.buf),
			})[1]

			if not project_root then
				return
			end

			local cwd = project_root:match("(.*/)") or project_root
			vim.keymap.set("n", "<leader>td", function()
				if tauri_term and not tauri_term.closed then
					tauri_term:focus()
					return
				end
				tauri_term = require("snacks").terminal({ "pnpm", "tauri", "dev" }, {
					cwd = cwd,
					show = false,
					on_exit = function()
						tauri_term = nil
					end,
				})
				vim.notify("Tauri Dev server started.", vim.log.levels.INFO)
			end, { buffer = args.buf, silent = true, desc = "Tauri Dev (Start/Focus)" })

			vim.keymap.set("n", "<leader>tk", function()
				if tauri_term and not tauri_term.closed then
					tauri_term:destroy()
				else
					vim.notify("Tauri Dev process not running.", vim.log.levels.WARN)
				end
			end, { buffer = args.buf, silent = true, desc = "Tauri Dev (Kill)" })
		end,
	})

	vim.notify(
		"Tauri Runner is active and watching for Tauri projects.",
		vim.log.levels.INFO,
		{ title = "Tauri Runner" }
	)
end

return M
