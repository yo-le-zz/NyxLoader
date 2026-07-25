local Config = {}

local path = "/boot/config.lua"


-- ======================================
-- Valeurs par défaut
-- ======================================

local default = {
    title = "NyxLoader",

    -- Temps avant boot automatique
    timeout = 10,

    -- Couleur du menu
    bootColor = colors.blue,

    -- Secure Boot actif
    secureBoot = false,

    -- Mode isolation : NyxLoader deplace automatiquement tout ce
    -- qui n'est pas lui-meme vers un disque
    isolation = false
}



-- ======================================
-- Valeurs par défaut (copie)
-- ======================================

-- nyxloader.lua appelle configManager.default() quand
-- /boot/config.lua n'existe pas encore : on renvoie une
-- copie de la table par défaut (jamais la table originale,
-- pour éviter de la modifier par accident).

function Config.default()

    local config = {}

    for key, value in pairs(default) do
        config[key] = value
    end

    return config

end



-- ======================================
-- Chargement
-- ======================================

function Config.load()

    local config = {}


    if fs.exists(path) then

        local ok, result = pcall(
            dofile,
            path
        )


        if ok and type(result) == "table" then

            config = result

        end

    end



    -- Complète les valeurs manquantes

    for key, value in pairs(default) do

        if config[key] == nil then

            config[key] = value

        end

    end


    return config

end



-- ======================================
-- Sauvegarde
-- ======================================

function Config.save(config)


    local file = fs.open(
        path,
        "w"
    )


    file.write(
        "return {\n"
    )


    file.write(
        "    title = \""
        .. config.title
        .. "\",\n"
    )


    file.write(
        "    timeout = "
        .. tostring(config.timeout)
        .. ",\n"
    )


    file.write(
        "    bootColor = "
        .. tostring(config.bootColor)
        .. ",\n"
    )


    file.write(
        "    secureBoot = "
        .. tostring(config.secureBoot)
        .. ",\n"
    )


    file.write(
        "    isolation = "
        .. tostring(config.isolation)
        .. "\n"
    )


    file.write(
        "}\n"
    )


    file.close()

end



-- ======================================
-- Reset configuration
-- ======================================

function Config.reset()

    if fs.exists(path) then
        fs.delete(path)
    end

end



return Config