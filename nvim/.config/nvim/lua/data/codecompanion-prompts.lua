-- codecompanion-prompts.lua
-- Module for managing system prompts for CodeCompanion

-- Prompts that are shared between all my environments
local _public_prompts = {
    system_architect = [[
You are an experienced and brutally honest system architect. Your primary goal is to provide clear, direct, and unvarnished feedback on software architecture decisions, even if your opinions may be unpopular or challenge assumptions. You never simply agree to please; instead, you critically evaluate every proposal and point out potential flaws, risks, and trade-offs without sugarcoating.

You always ask clarifying questions when requirements, constraints, or goals are ambiguous or incomplete. You proactively seek missing context and highlight any gaps in information that could impact architectural choices.

When discussing solutions, you explain your reasoning, consider alternatives, and make sure to address scalability, maintainability, security, and cost. You are not afraid to say "I don't know" or "this is a bad idea" if warranted, and you always justify your stance with technical arguments.

Your responses are concise, focused, and actionable. You avoid unnecessary jargon and ensure your advice is practical and grounded in real-world experience.
    ]],
}

local current_prompt_key = nil

local function set_prompt_key(key)
    if key == nil or _public_prompts[key] then
        current_prompt_key = key
        vim.notify("Sysprompt set to: " .. (key or "default"))
    else
        vim.notify("Prompt not found: " .. key, vim.log.levels.ERROR)
    end
end

---@param ctx CodeCompanion.SystemPrompt.Context
local function get_current_prompt(ctx)
    if current_prompt_key and _public_prompts[current_prompt_key] then
        return _public_prompts[current_prompt_key]
    end
    return ctx.default_system_prompt
end

-- Try to load private prompts from /opt/ai-configs/sysprompts.lua
-- format: `return { _key=[[prompt]],  } `
local private_path = "/opt/ai-configs/sysprompts.lua"
local stat = vim.loop.fs_stat(private_path)
if stat then
    local ok, private_prompts = pcall(dofile, private_path)
    if ok and type(private_prompts) == "table" then
        for key, val in pairs(private_prompts) do
            _public_prompts[key] = val
        end
    end
end

-- Return module interface
-- returns functions for setting, getting and the list of possible keys for autocomplete
return {
    set_prompt_key = set_prompt_key,
    get_current_prompt = get_current_prompt,
    prompt_keys = function() return vim.tbl_keys(_public_prompts) end,
}
