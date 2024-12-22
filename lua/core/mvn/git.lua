local function get_ignore_content()
    return [[
trash/**
Servers/**
target/**
**/target/**
*.tar.gz
.metadata/**
.settings/**
.nvim/**
.classpath
.project
]]
end

return {
    get_ignore_content = get_ignore_content,
}
