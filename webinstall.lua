local REPO =
"https://raw.githubusercontent.com/yo-le-zz/NyxLoader/main/"


local function download(url, path)

    print("Téléchargement : " .. path)


    local data, err =
        http.get(
            url
        )


    if not data then

        error(
            "Impossible de télécharger "
            .. path
            .. "\n"
            .. tostring(err)
        )

    end


    local file =
        fs.open(
            path,
            "w"
        )


    file.write(
        data.readAll()
    )


    file.close()

    data.close()

end



local function mkdir(path)

    if not fs.exists(path) then

        fs.makeDir(path)

    end

end



-- ======================================
-- Installation
-- ======================================


print("")
print("=== NyxLoader Web Installer ===")
print("")



mkdir(
    "/boot"
)


mkdir(
    "/boot/nyxloader"
)


mkdir(
    "/boot/nyxloader/lib"
)



local files = {

    "NyxLoader/nyxloader/nyxloader.lua",

    "NyxLoader/nyxloader/ui.lua",

    "NyxLoader/nyxloader/config.lua",

    "NyxLoader/nyxloader/lib/basalt.lua",

    "NyxLoader/nyxloader/lib/hash.lua",

    "NyxLoader/nyxloader/lib/scanner.lua",

    "NyxLoader/nyxloader/lib/loader.lua",

    "NyxLoader/nyxloader/lib/uninstall.lua",

}



for _, file in ipairs(files) do


    local name =
        file:match(
            "([^/]+)$"
        )


    local destination


    if file:find("/lib/") then

        destination =
            "/boot/nyxloader/lib/"
            .. name

    else

        destination =
            "/boot/nyxloader/"
            .. name

    end



    download(
        REPO .. file,
        destination
    )


end



-- ======================================
-- Startup
-- ======================================


local startup =
[[
shell.run("/boot/nyxloader/nyxloader.lua")
]]



local file =
fs.open(
    "/startup.lua",
    "w"
)


file.write(startup)

file.close()



-- ======================================
-- Mode Isolation
-- ======================================


print("")
print("=== Mode Isolation (optionnel) ===")
print("")
print("NyxLoader peut devenir le seul element")
print("present sur ce PC : tout ce qui s'y")
print("trouve deja (ou qui y apparait plus")
print("tard) est deplace sur un disque.")
print("")

write("Activer le mode isolation ? (o/n) ")

local isolationChoice = read()

local isolationMode =
    isolationChoice == "o"
    or isolationChoice == "O"



-- ======================================
-- Configuration
-- ======================================


local config =
fs.open(
    "/boot/config.lua",
    "w"
)


config.write(
[[
return {
    title = "NyxLoader",
    timeout = 10,
    bootColor = colors.blue,
    secureBoot = false,
    isolation = ]] .. tostring(isolationMode) .. [[
}
]]
)


config.close()



print("")
print("NyxLoader installé !")
print("")



-- ======================================
-- Secure Boot
-- ======================================


local crypto =
peripheral.find(
    "cryptographic_accelerator"
)


if crypto then

    print(
        "Cryptographic Accelerator trouvé."
    )

    print(
        "Génération du hash..."
    )


    -- sera remplacé par lib/hash.lua
    -- ici on garde juste la détection


else


    print(
        "Aucun Cryptographic Accelerator."
    )

    print(
        "Secure Boot désactivé."
    )

end



-- ======================================
-- Nettoyage initial (mode isolation)
-- ======================================


if isolationMode then

    print("")
    print("=== Mode Isolation ===")

    local isolation = dofile(
        "/boot/nyxloader/lib/isolation.lua"
    )

    local stray = isolation.listStrayEntries()

    if #stray == 0 then

        print("Rien a deplacer.")

    else

        print(
            #stray .. " element(s) a deplacer."
        )
        print("(Q pour annuler si besoin)")

        isolation.enforce(print)

    end

end



print("")
print(
    "Redémarrage dans 3 secondes..."
)


sleep(3)

os.reboot()