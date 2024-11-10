function SetColorScheme(color)
	--color = color or "material"
	--color = color or "material-darker"
	--color = color or "material-deep-ocean"
	--color = color or "material-palenight"
	--color = color or "torte"
	color = color or "tokyonight"

    vim.cmd.colorscheme(color)
end

function SetTransparentBackground()
	vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
	vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
end

SetColorScheme()
SetTransparentBackground()
