-- data.codecompanion-skills.lua

------------------------------------------------------------------------
-- Skillloader
-- Reads .md files from skillsdir and builds rulegroups
-- Gracefully handles missing dirs or empty folders
------------------------------------------------------------------------
-- TODO Move folder to better location
local skills_dir = vim.fn.expand("~/.config/nvim/codecompanion/skills")

local function load_skills(dir)
    local rules = {}

    -- Check if directory exists at all
    local stat = vim.loop.fs_stat(dir)
    if not stat or stat.type ~= "directory" then
        return rules    -- silently return empty, no error
    end

    -- Scan the dir for .md files
    local handle = vim.loop.fs_scandir(dir)
    if not handle then
        return rules  -- can't open dir, bail silently
    end

    -- TODO Check that we can load multiple "rules", maybe subfolders to group? Maybe even create custom plugin 
    -- to manage these if there is not yet such a thing?
    while true do
        local name, ftype = vim.loop.fs_scandir_next(handle)
        if not name then break end

        -- Only pick up .md files
        if (ftype == "file" or ftype == nil) and name:match("%.md$") then
            local skill_name = name:gsub("%.md$", "")
            local full_path  = dir .. "/" .. name

            -- Verify the file actually exists and is readable
            local fstat = vim.loop.fs_stat(full_path)
            if fstat and fstat.type == "file" then
                rules[skill_name] = {
                    description = "Skill: " .. skill_name,
                    files = {
                        { path = full_path, parser = "codecompanion" },
                    },
                }
            end
        end
    end

    return rules
end

return load_skills(skills_dir)
