-- lua/makefile_template.lua
-- Generate a Makefile from nvim-tree view based on lower cpp Files. Only works for cpp for now
local M = {}

M.create_makefile_template = function()
    -- Get selected node from NvimTree
    local node = require('nvim-tree.api').tree.get_node_under_cursor()
    if not node then return end

    -- Get the directory path (if file is selected, use its parent)
    local path = node.type == 'directory' and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ':h')

    -- Find all cpp files recursively
    local cpp_files = vim.fn.glob(path .. "/**/*.cpp", false, true)
    local sources = {}
    for i, file in ipairs(cpp_files) do
        sources[i] = file:gsub(path .. "/", "")
    end

    local makefile = [[
CXX = g++
CXXFLAGS = -Wall -Wextra -std=c++17
INCLUDES = -I./include
TARGET = main

# Source files
SRCS = ]] .. table.concat(sources, " \\\n\t") .. [[

# Object files
OBJS = $(SRCS:.cpp=.o)

# Main target
$(TARGET): $(OBJS)
    $(CXX) $(OBJS) -o $(TARGET)

# Compile source files
%.o: %.cpp
    $(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

run:
    ./$(TARGET)

# Create include directory if it doesn't exist
create_dirs:
    @mkdir -p include

# Clean build files
clean:
    rm -f $(OBJS) $(TARGET)

.PHONY: clean create_dirs run
]]

    -- Create include directory
    vim.fn.mkdir("include", "p")

    -- Replace leading spaces with tabs
    makefile = makefile:gsub("\n    ", "\n\t")

    -- Write Makefile
    local file = io.open(path .. "/Makefile", "w")
    file:write(makefile)
    file:close()
end

return M
