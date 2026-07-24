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


-- Suppression récursive sécurisée
local function remove(path)

    if fs.exists(path) then
        fs.delete(path)
        println("  [OK] " .. path)
    end

end



println("=== NyxLoader Uninstaller ===")
println("")


if not fs.exists("/boot/nyxloader") and not fs.exists("/startup.lua") then

    println("NyxLoader ne semble pas installe.")
    return

end


println("Cette action va supprimer :")
println("  /boot/nyxloader")
println("  /boot/config.lua")
println("  /boot/secureboot.hash")
println("  /startup.lua")
println("")

local choice = ask("Confirmer la desinstallation ? (o/n)")

if choice ~= "o" and choice ~= "O" then
    println("")
    println("Desinstallation annulee.")
    return
end


println("")
println("[1/2] Suppression des fichiers NyxLoader")

remove("/boot/nyxloader")
remove("/boot/config.lua")
remove("/boot/secureboot.hash")


println("[2/2] Suppression du demarrage automatique")

-- On ne supprime /startup.lua que s'il appartient bien a
-- NyxLoader, pour ne pas ecraser un startup.lua personnalise
-- par l'utilisateur.

if fs.exists("/startup.lua") then

    local file = fs.open("/startup.lua", "r")
    local content = file.readAll()
    file.close()

    if content:find("nyxloader", 1, true) then

        fs.delete("/startup.lua")
        println("  [OK] /startup.lua")

    else

        println("  [SKIP] /startup.lua (ne semble pas lie a NyxLoader)")

    end

end


-- Si /boot est vide, on le supprime aussi

if fs.exists("/boot") and #fs.list("/boot") == 0 then
    fs.delete("/boot")
end


println("")
println("NyxLoader a ete desinstalle.")
println("Redemarrage conseille.")
