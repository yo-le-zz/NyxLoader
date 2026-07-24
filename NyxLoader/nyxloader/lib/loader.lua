local loaded = {}

package = {
    loaded = loaded,
    path = ""
}

local BASE = "/boot/nyxloader/lib/basalt"

function require(name)
    if loaded[name] then
        return loaded[name]
    end

    local path = fs.combine(BASE, name .. ".lua")

    if not fs.exists(path) then
        error("Module introuvable : " .. name, 2)
    end

    local module = dofile(path)

    if module == nil then
        module = true
    end

    loaded[name] = module
    return module
end

if not shell then
    shell = {}
end

if not shells then
    shells = {}
end

if not shell.getRunningProgram then
    function shell.getRunningProgram()
        return "/boot/nyxloader/nyxloader.lua"
    end
end