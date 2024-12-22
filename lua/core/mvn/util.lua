local find_src_paths = (function()
    local function scan_dir_for_src(parent_dir, paths, is_mvn_prj, cur_level)
        -- To avoid searching above the max-dept. It will help when
        -- when current directory has huge directory depth. Any way we didnt expect sub-projects at
        -- depth gretor than 5.
        if cur_level > 6 then return end
        local file_names = vim.fn.readdir(parent_dir)
        if file_names == nil then return end
        for _, file in ipairs(file_names) do
            -- if list has any hidden directory, skip it.
            if string.len(file) > 0 and string.sub(file, 1, 1) ~= "." then
                local cur_file_path = parent_dir .. "/" .. file
                if 1 == vim.fn.isdirectory(cur_file_path) then
                    -- directory name is src/SRC/Src and it to the
                    -- output list
                    if file == "src" then
                        local add_src = true
                        -- If this is maven project, we need to check if project has following structure.
                        -- If yes, add these following directories as src directory
                        -- ----------------------------------------------------------
                        -- src-+
                        --     |
                        --     +- main
                        --     |    |
                        --     +    +- java
                        --     |
                        --     +- test
                        --          |
                        --          +- java
                        -- In other cases, add src only
                        -- ----------------------------------------------------------
                        if is_mvn_prj == true then
                            if 1 == vim.fn.isdirectory(cur_file_path .. "/main/java") then
                                table.insert(paths, cur_file_path .. "/main/java")
                                add_src = false
                            end
                            if 1 == vim.fn.isdirectory(cur_file_path .. "/test/java") then
                                table.insert(paths, cur_file_path .. "/test/java")
                                add_src = false
                            end
                        end
                        if add_src == true then
                            table.insert(paths, cur_file_path)
                        end
                        -- Else cotinue search for src directory
                    else
                        scan_dir_for_src(cur_file_path, paths, is_mvn_prj, cur_level + 1)
                    end
                end
            end
        end
    end

    local paths = {}
    return function(input_dir, return_existing, reset)
        local tbl_len = require("core.util.table").len;
        if return_existing ~= nil and return_existing == true and tbl_len(paths) > 0 then
            return paths
        end
        if reset ~= nil and reset == true then
            paths = {}
        end
        if input_dir ~= nil then
            local sys = require("core.util.sys")
            local is_mvn_prj = sys.is_file(input_dir .. "/" .. "pom.xml")
            scan_dir_for_src(input_dir, paths, is_mvn_prj, 1)
        end
        return paths
    end
end)()

return {
    find_src_paths = find_src_paths,
}
