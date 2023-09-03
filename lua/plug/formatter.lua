return {
	"nvimdev/guard.nvim",
	config = function()
		local ft = require("guard.filetype")
		ft("c"):fmt("clang-format")
		ft("cpp"):fmt("clang-format")
		ft("java"):fmt("google-java-format")
		ft("lua"):fmt("stylua")
		ft("json"):fmt("prettier")
		ft("yaml"):fmt("prettier")
		ft("css"):fmt("prettier")
		ft("html"):fmt("prettier")
		ft("js"):fmt("prettier")
		ft("md"):fmt("prettier")
		ft("scss"):fmt("prettier")
		ft("less"):fmt("prettier")

		require("guard").setup({
			-- the only options for the setup function
			fmt_on_save = true,
			-- Use lsp if no formatter was defined for this filetype
			lsp_as_default_formatter = false,
		})
	end,
}
