local M = {}

local function get_char(bufnr, row, col)
	local line = (vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1] or "")
	return line:sub(col + 1, col + 1)
end

local function add_edits_for_parens(bufnr, node, edits)
	local sr, sc, er, ec = node:range()

	local first = get_char(bufnr, sr, sc)
	local last = (ec > 0) and get_char(bufnr, er, ec - 1) or ""

	if first ~= "(" or last ~= ")" then
		return false
	end

	local did = false

	-- after '('
	local nextc = get_char(bufnr, sr, sc + 1)
	if nextc ~= "" and not nextc:match("%s") then
		table.insert(edits, { row = sr, col = sc + 1, text = " " })
		did = true
	end

	-- before ')'
	local prevc = (ec >= 2) and get_char(bufnr, er, ec - 2) or ""
	if prevc ~= "" and not prevc:match("%s") then
		table.insert(edits, { row = er, col = ec - 1, text = " " })
		did = true
	end

	return did
end

local function add_edits_around_value_parens(bufnr, value_node, edits)
	local sr, sc, er, ec = value_node:range()

	-- '(' is expected right before value start
	local open_col = sc - 1
	if open_col >= 0 and get_char(bufnr, sr, open_col) == "(" then
		local nextc = get_char(bufnr, sr, sc)
		if nextc ~= "" and not nextc:match("%s") then
			table.insert(edits, { row = sr, col = sc, text = " " }) -- after '('
		end
	end

	-- ')' is expected right after value end
	local close_col = ec
	if get_char(bufnr, er, close_col) == ")" then
		local prevc = (ec > 0) and get_char(bufnr, er, ec - 1) or ""
		if prevc ~= "" and not prevc:match("%s") then
			table.insert(edits, { row = er, col = ec, text = " " }) -- before ')'
		end
	end

	return true
end

local function is_ws(ch)
	return ch ~= nil and ch ~= "" and ch:match("%s") ~= nil
end

local function add_edits_for_for_header(bufnr, for_node, edits)
	-- Pick first/last existing header part (some can be absent)
	local init = for_node:field("initializer")[1]
	local cond = for_node:field("condition")[1]
	local upd = for_node:field("update")[1]

	local first = init or cond or upd
	local last = upd or cond or init

	if not first or not last then
		return false
	end

	local fsr, fsc = first:range() -- start of first part
	local lsr, lsc, ler, lec = last:range() -- end of last part (end is exclusive)

	-- Expect '(' immediately before first part (maybe with whitespace already handled by your style)
	-- We only insert a space right AFTER '(' if next char is not whitespace/newline.
	local open_col = fsc - 1
	if open_col >= 0 and get_char(bufnr, fsr, open_col) == "(" then
		local nextc = get_char(bufnr, fsr, fsc)
		if nextc ~= "" and not is_ws(nextc) then
			table.insert(edits, { row = fsr, col = fsc, text = " " })
		end
	end

	-- Expect ')' immediately after last part
	local close_col = lec
	if get_char(bufnr, ler, close_col) == ")" then
		local prevc = (lec > 0) and get_char(bufnr, ler, lec - 1) or ""
		if prevc ~= "" and not is_ws(prevc) then
			table.insert(edits, { row = ler, col = lec, text = " " })
		end
	end

	return true
end

function M.run(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local ft = vim.bo[bufnr].filetype
	if ft ~= "c" and ft ~= "cpp" and ft ~= "objc" and ft ~= "objcpp" then
		vim.notify("pad_control_parens: filetype not supported: " .. ft, vim.log.levels.WARN)
		return
	end

	local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
	if not ok_parser or not parser then
		vim.notify("pad_control_parens: no treesitter parser for " .. ft, vim.log.levels.ERROR)
		return
	end

	local tree = parser:parse()[1]
	if not tree then
		vim.notify("pad_control_parens: parse() returned no tree", vim.log.levels.ERROR)
		return
	end
	local root = tree:root()

	local edits = {}
	local stmt_count, paren_count, match_count = 0, 0, 0

	local function walk(node)
		local t = node:type()

		if t == "if_statement" or t == "while_statement" then
			stmt_count = stmt_count + 1
			local cond = node:field("condition")[1]
			if cond then
				if cond:type() == "parenthesized_expression" then
					paren_count = paren_count + 1
					if add_edits_for_parens(bufnr, cond, edits) then
						match_count = match_count + 1
					end
				elseif cond:type() == "condition_clause" then
					local v = cond:field("value")[1]
					if v then
						paren_count = paren_count + 1
						if add_edits_around_value_parens(bufnr, v, edits) then
							match_count = match_count + 1
						end
					end
				end
			end
		elseif t == "switch_statement" then
			stmt_count = stmt_count + 1
			local cond = node:field("condition")[1]
			if cond then
				if cond:type() == "parenthesized_expression" then
					paren_count = paren_count + 1
					if add_edits_for_parens(bufnr, cond, edits) then
						match_count = match_count + 1
					end
				elseif cond:type() == "condition_clause" then
					local v = cond:field("value")[1]
					if v then
						paren_count = paren_count + 1
						if add_edits_around_value_parens(bufnr, v, edits) then
							match_count = match_count + 1
						end
					end
				end
			end
		elseif t == "for_statement" then
			stmt_count = stmt_count + 1
			-- for(...) header: parens aren't a parenthesized_expression in TS-C
			if add_edits_for_for_header(bufnr, node, edits) then
				paren_count = paren_count + 1
				match_count = match_count + 1
			end
		end

		for child in node:iter_children() do
			walk(child)
		end
	end

	walk(root)

	-- Apply edits bottom-right -> top-left
	table.sort(edits, function(a, b)
		if a.row ~= b.row then
			return a.row > b.row
		end
		return a.col > b.col
	end)

	for _, e in ipairs(edits) do
		vim.api.nvim_buf_set_text(bufnr, e.row, e.col, e.row, e.col, { e.text })
	end

	vim.notify(
		string.format(
			"pad_control_parens: stmts=%d parens=%d matched=%d edits=%d",
			stmt_count,
			paren_count,
			match_count,
			#edits
		),
		vim.log.levels.INFO
	)
end

return M
