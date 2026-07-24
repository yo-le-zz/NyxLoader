local crypto = peripheral.find("cryptographic_accelerator")
local monitor = peripheral.find("monitor")


-- Gestion affichage
local screen = term

if monitor then
    screen = monitor
    screen.setTextScale(1)
    screen.clear()
    screen.setCursorPos(1, 1)
end


local function println(text)
    screen.write(text)
    local x, y = screen.getCursorPos()
    screen.setCursorPos(1, y + 1)
end


local function ask(text)
    println(text)
    return read()
end


-- Copie fichier
local function copyFile(source, destination)

    local input = fs.open(source, "rb")

    if not input then
        error("Impossible de lire : " .. source)
    end

    local data = input.readAll()
    input.close()


    local output = fs.open(destination, "wb")
    output.write(data)
    output.close()

end


-- Copie dossier récursive
local function copyDirectory(source, destination)

    if not fs.exists(destination) then
        fs.makeDir(destination)
    end


    for _, file in ipairs(fs.list(source)) do

        local src = fs.combine(source, file)
        local dst = fs.combine(destination, file)


        if fs.isDir(src) then
            copyDirectory(src, dst)
        else
            copyFile(src, dst)
        end

    end

end


-- Génération hash dossier
local function generateHash(path)

    if not crypto then
        return nil
    end


    local files = {}


    local function scan(dir)

        for _, file in ipairs(fs.list(dir)) do

            local full = fs.combine(dir, file)

            if fs.isDir(full) then
                scan(full)
            else
                table.insert(files, full)
            end

        end

    end


    scan(path)

    table.sort(files)


    local data = ""

    for _, file in ipairs(files) do

        local f = fs.open(file, "rb")
        local content = f.readAll()
        f.close()


        data = data .. file .. ":" .. content .. "\n"

    end


    return crypto.sha256(data)

end



println("=== NyxLoader Installer ===")
println("")


-- Secure boot

local secureBoot = false


if crypto then

    println("[OK] Cryptographic Accelerator detecte")
    secureBoot = true

else

    println("[WARN] Aucun Cryptographic Accelerator")
    println("")
    println("Secure Boot indisponible.")
    println("")
    println("1 - Annuler")
    println("2 - Installer sans Secure Boot")


    local choice = read()


    if choice == "1" then
        println("Installation annulee.")
        return
    end

end



-- Installation

println("")
println("[1/5] Creation de /boot")


if fs.exists("/boot/nyxloader") then
    fs.delete("/boot/nyxloader")
end


if not fs.exists("/boot") then
    fs.makeDir("/boot")
end



println("[2/5] Copie de NyxLoader")

local installerPath = shell.getRunningProgram()
local installerDir = fs.getDir(installerPath)
local source = installerDir .. "/nyxloader"

if not fs.exists(source) then
    error("Dossier nyxloader introuvable sur le disque")
end

copyDirectory(
    source,
    "/boot/nyxloader"
)



println("[3/5] Creation startup.lua")


local startup = fs.open("/startup.lua", "w")

startup.write(
'shell.run("/boot/nyxloader/nyxloader.lua")'
)

startup.close()



println("[4/5] Creation configuration")


local config = fs.open("/boot/config.lua", "w")

config.write(
[[
return {
    title = "NyxLoader",
    timeout = 10,
    bootColor = colors.blue,
    secureBoot = ]] .. tostring(secureBoot) .. [[
}
]]
)

config.close()



println("[5/5] Secure Boot")


if secureBoot then

    println("Calcul du hash...")


    local hash = generateHash("/boot/nyxloader")


    local file = fs.open("/boot/secureboot.hash", "w")
    file.write(hash)
    file.close()


    println("Hash genere.")

else

    println("Secure Boot desactive.")

end



println("")
println("Installation terminee !")
println("Redemarrage conseille.")
