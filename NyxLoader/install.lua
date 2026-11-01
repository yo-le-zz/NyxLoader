-- NyxLoader installer (disque) - ASCII only
-- Copie /boot/nyxloader depuis le dossier "nyxloader" a cote de ce
-- fichier, puis redemarre automatiquement.

local VERSION = "1.1.1"

local dir = fs.getDir(shell.getRunningProgram())
local source = fs.combine(dir, "nyxloader")

if not fs.exists(source) then
    printError("nyxloader folder not found next to install.lua")
    return
end

local files = {}
local function scan(path, rel)
    for _, name in ipairs(fs.list(path)) do
        local full = fs.combine(path, name)
        local r = rel == "" and name or (rel .. "/" .. name)
        if fs.isDir(full) then scan(full, r) else files[#files + 1] = r end
    end
end
scan(source, "")
table.sort(files)

local args = { ... }
local Setup = dofile(fs.combine(source, "lib/setup.lua"))

Setup.run({
    version = VERSION,
    quiet = (args[1] == "--quiet"),
    files = files,
    fetch = function(rel)
        local f = fs.open(fs.combine(source, rel), "rb")
        if not f then return nil end
        local data = f.readAll() f.close()
        return data
    end,
})
