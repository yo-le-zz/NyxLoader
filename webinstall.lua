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
    secureBoot = false
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



print("")
print(
    "Redémarrage dans 3 secondes..."
)


sleep(3)

os.reboot()