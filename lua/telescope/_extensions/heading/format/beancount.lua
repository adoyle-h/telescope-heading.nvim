local Beancount = {}

function Beancount.get_headings(filepath, start, total)
    local headings = {}
    local index = start
    local matches = {
        '* ',
        '** ',
        '*** ',
    }
    while index <= total do
        local line = vim.fn.getline(index)
        -- match heading
        for _, pattern in pairs(matches) do
            if vim.startswith(line, pattern) then
                table.insert(headings, {
                    heading = vim.trim(line),
                    line = index,
                    path = filepath,
                })
                break
            end
        end

        index = index + 1
    end

    return headings
end

function Beancount.ts_get_headings(filepath, bufnr)
    local ts = vim.treesitter
    local query = [[
    (section) (headline) (item) @heading
    ]]
    local parsed_query = ts.parse_query('beancount', query)
    local parser = ts.get_parser(bufnr, 'beancount')
    local root = parser:parse()[1]:root()
    local start_row, _, end_row, _ = root:range()

    local headings = {}
    for _, node in parsed_query:iter_captures(root, bufnr, start_row, end_row) do
        local row, _ = node:range()
        local line = vim.fn.getline(row + 1)
        table.insert(headings, {
            heading = vim.trim(line),
            line = row + 1,
            path = filepath,
        })
    end
    return headings
end

return Beancount
