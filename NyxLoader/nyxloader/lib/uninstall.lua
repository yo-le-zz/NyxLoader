local Uninstall = {}



-- ======================================
-- Suppression d'un chemin
-- ======================================

local function remove(path, log)

    if fs.exists(path) then
        fs.delete(path)

        if log then
            log("  [OK] " .. path)
        end

    end

end



-- ======================================
-- Desinstallation complete
-- ======================================

-- log : fonction optionnelle appelee avec une ligne de texte
-- pour chaque etape (utilisee par nyxloader.lua pour afficher
-- la progression avant le redemarrage).

function Uninstall.run(log)

    remove("/boot/config.lua", log)
    remove("/boot/secureboot.hash", log)


    -- On ne supprime /startup.lua que s'il appartient bien a
    -- NyxLoader, pour ne pas ecraser un demarrage personnalise.

    if fs.exists("/startup.lua") then

        local file = fs.open("/startup.lua", "r")
        local content = file.readAll()
        file.close()

        if content:find("nyxloader", 1, true) then
            remove("/startup.lua", log)
        end

    end


    -- /boot/nyxloader est supprime en dernier : c'est le dossier
    -- depuis lequel ce module tourne actuellement, donc on
    -- planifie la suppression apres le prochain redemarrage n'est
    -- pas necessaire ici (les chunks Lua deja charges en memoire
    -- continuent de s'executer normalement).

    remove("/boot/nyxloader", log)


    if fs.exists("/boot")
    and #fs.list("/boot") == 0 then

        fs.delete("/boot")

    end

end



return Uninstall
