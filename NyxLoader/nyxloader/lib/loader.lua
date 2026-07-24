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

-- Au boot, NyxLoader est lancé directement depuis /startup.lua,
-- donc l'API "shell" n'existe pas encore (elle n'est normalement
-- créée que par /rom/programs/shell.lua). Sans elle, tout appel à
-- shell.run(...) plantait avec "attempt to call a nil value".
-- On fournit ici une implémentation minimale mais fonctionnelle.

if not shell then

    shell = {}

    function shell.run(...)
        return os.run({}, ...)
    end

    function shell.getRunningProgram()
        return "/boot/nyxloader/nyxloader.lua"
    end

    function shell.dir()
        return "/"
    end

    function shell.resolve(path)
        return fs.combine(shell.dir(), path)
    end

    function shell.exit()
        -- rien à faire : NyxLoader gère sa propre boucle
    end

end

if not shells then
    shells = {}
end