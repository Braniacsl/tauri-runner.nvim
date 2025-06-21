local M = {}

function M.setup(opts)
	local tauri_workflow_group = vim.api.nvim_create_augroup("TauriWorkflow", { clear = true })
	local tauri_term = nil

	vim.api.nvim_create_autocmd("BufEnter", {
		group = tauri_workflow_group,
		pattern = "*",
		callback = function(args)
			local git_root_dir = vim.fs.find({ ".git" }, {
				upward = true,
				type = "directory",
				path = vim.api.nvim_buf_get_name(args.buf),
			})[1]

			if not git_root_dir then
				return
			end

			local project_root = vim.fn.fnamemodify(git_root_dir, ":h")

			local tauri_config_path = project_root .. "/src-tauri/tauri.conf.json"

			if vim.fn.filereadable(tauri_config_path) == 1 then
				vim.notify(
					"Tauri project detected. Keymaps enabled for this buffer.",
					vim.log.levels.INFO,
					{ title = "Tauri Runner" }
				)

				vim.keymap.set("n", "<leader>td", function()
					if tauri_term and not tauri_term.closed then
						tauri_term:focus()
						return
					end
					tauri_term = require("snacks").terminal({ "pnpm", "tauri", "dev" }, {

						cwd = project_root,
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
			end
		end,
	})
end

return M
