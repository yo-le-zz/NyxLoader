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
-- Désinstallation complète
-- ======================================

-- log : fonction optionnelle appelée avec une ligne de texte
-- pour chaque étape (utilisée par nyxloader.lua pour afficher
-- la progression avant le redémarrage).

function Uninstall.run(log)

    remove("/boot/config.lua", log)
    remove("/boot/secureboot.hash", log)


    -- On ne supprime /startup.lua que s'il appartient bien à
    -- NyxLoader, pour ne pas écraser un démarrage personnalisé.

    if fs.exists("/startup.lua") then

        local file = fs.open("/startup.lua", "r")
        local content = file.readAll()
        file.close()

        if content:find("nyxloader", 1, true) then
            remove("/startup.lua", log)
        end

    end


    -- /boot/nyxloader est supprimé en dernier : c'est le dossier
    -- depuis lequel ce module tourne actuellement, donc on
    -- planifie la suppression après le prochain redémarrage n'est
    -- pas nécessaire ici (les chunks Lua déjà chargés en mémoire
    -- continuent de s'exécuter normalement).

    remove("/boot/nyxloader", log)


    if fs.exists("/boot")
    and #fs.list("/boot") == 0 then

        fs.delete("/boot")

    end

end



return Uninstall
