-- NyxLoader web installer - ASCII only
-- wget run https://raw.githubusercontent.com/yo-le-zz/NyxLoader/main/webinstall.lua

local VERSION = "1.1.0"
local REPO = "https://raw.githubusercontent.com/yo-le-zz/NyxLoader/main/NyxLoader/nyxloader/"

if not http then
    printError("HTTP is disabled on this computer.")
    return
end

local files = {
    "nyxloader.lua",
    "ui.lua",
    "config.lua",
    "lib/basalt.lua",
    "lib/hash.lua",
    "lib/scanner.lua",
    "lib/loader.lua",
    "lib/uninstall.lua",
    "lib/isolation.lua",
    "lib/setup.lua",
}

local function fetch(rel)
    local r = http.get(REPO .. rel, nil, true)
    if not r then return nil end
    local data = r.readAll()
    r.close()
    return data
end

-- setup.lua d'abord : c'est lui qui affiche l'interface
local src = fetch("lib/setup.lua")
if not src then
    printError("Download failed: lib/setup.lua")
    return
end
local fn, err = load(src, "=setup")
if not fn then printError(err) return end
local Setup = fn()

local args = { ... }
Setup.run({ version = VERSION, files = files, fetch = fetch, quiet = (args[1] == "--quiet") })
