local BASE = "/boot/nyxloader"
_G.NYXLOADER_PATH = "/boot/nyxloader"

package.path = BASE .. "/?.lua;" .. BASE .. "/?/init.lua;" .. package.path


-- ======================================
-- Affichage écran / terminal
-- ======================================

local monitor = peripheral.find("monitor")

if monitor then
    term.redirect(monitor)
    monitor.setTextScale(1)
end


-- ======================================
-- Chargement modules
-- ======================================

local function load(path)
    return dofile(BASE .. "/" .. path)
end

load("lib/loader.lua")

local ui = load("ui.lua")
local hash = load("lib/hash.lua")
local scanner = load("lib/scanner.lua")
local configManager = load("config.lua")


-- ======================================
-- Configuration
-- ======================================

local config = {}

if fs.exists("/boot/config.lua") then
    config = configManager.load()
else
    config = configManager.default()
end


config.title = config.title or "NyxLoader"
config.timeout = config.timeout or 10
config.secureBoot = config.secureBoot or false
config.bootColor = config.bootColor or colors.blue


-- ======================================
-- Secure Boot
-- ======================================

local function saveConfig()

    local file = fs.open("/boot/config.lua", "w")

    file.write(
[[return {
    title = "]] .. config.title .. [[",
    timeout = ]] .. config.timeout .. [[,
    secureBoot = ]] .. tostring(config.secureBoot) .. [[
}]]
    )

    file.close()

end



local function disableSecureBoot()

    config.secureBoot = false
    saveConfig()

end



local function secureBootCheck()


    if not config.secureBoot then

        return true

    end



    -- Crypto absent

    if not hash.available() then


        local choice = ui.warning(
            "SECURE BOOT WARNING\n\n" ..
            "Cryptographic Accelerator absent.\n" ..
            "Impossible de verifier NyxLoader.",
            {
                "Continuer",
                "Desactiver Secure Boot",
                "Arreter"
            }
        )


        if choice == 2 then

            disableSecureBoot()
            return true

        elseif choice == 3 then

            return false

        end


        return true

    end



    -- Hash absent

    if not fs.exists("/boot/secureboot.hash") then


        local choice = ui.warning(
            "Hash Secure Boot introuvable.\n\n" ..
            "Voulez-vous le regenerer ?",
            {
                "Regenerer",
                "Desactiver Secure Boot",
                "Arreter"
            }
        )


        if choice == 1 then

            local newHash = hash.directory(
                "/boot/nyxloader"
            )


            local file = fs.open(
                "/boot/secureboot.hash",
                "w"
            )

            file.write(newHash)
            file.close()


            return true


        elseif choice == 2 then

            disableSecureBoot()
            return true

        end


        return false

    end



    -- Vérification hash

    local file = fs.open(
        "/boot/secureboot.hash",
        "r"
    )

    local savedHash = file.readAll()

    file.close()



    local currentHash = hash.directory(
        "/boot/nyxloader"
    )

    if savedHash == currentHash then

        return true

    end



    -- Hash différent

    local choice = ui.warning(
        "SECURE BOOT FAILURE\n\n" ..
        "NyxLoader a ete modifie.",
        {
            "Regenerer le hash",
            "Continuer",
            "Desactiver Secure Boot",
            "Arreter"
        }
    )



    if choice == 1 then


        local file = fs.open(
            "/boot/secureboot.hash",
            "w"
        )

        file.write(currentHash)
        file.close()


        return true


    elseif choice == 2 then

        return true


    elseif choice == 3 then

        disableSecureBoot()
        return true

    end


    return false

end



-- ======================================
-- Boot
-- ======================================


local function bootSystem(system)


    -- Vérification fichier

    if not fs.exists(system.file) then


        ui.warning(
            "Erreur de boot\n\n" ..
            "Fichier introuvable :\n" ..
            system.file,
            {
                "Retour NyxLoader"
            }
        )


        return false

    end




    -- CraftOS Shell

    if system.id == "craftos" then

        term.clear()
        term.setCursorPos(1,1)

        os.run(
            {},
            "/rom/programs/shell.lua"
        )

        return true

    end





    -- OS normal


    term.clear()
    term.setCursorPos(1,1)



    local ok, err =
        pcall(
            function()


                shell.run(
                    system.file
                )


            end
        )



    if not ok then


        ui.warning(
            "Crash de l'OS\n\n" ..
            tostring(err),
            {
                "Retour NyxLoader"
            }
        )


        return false

    end



    -- l'OS est terminé

    return false


end





-- Secure boot

if not secureBootCheck() then

    ui.message(
        "Demarrage bloque."
    )

    return

end





-- Boucle NyxLoader

while true do


    local systems =
        scanner.scan()



    if #systems == 0 then

        ui.message(
            "Aucun systeme trouve."
        )

        return

    end



    local selected =
        ui.menu(
            systems,
            config
        )



    if selected then

        bootSystem(selected)

    end


end