print("")
print("=== NyxLoader Web Uninstaller ===")
print("")


if not fs.exists("/boot/nyxloader") and not fs.exists("/startup.lua") then

    print("NyxLoader ne semble pas installe.")
    return

end


print("Cette action va supprimer :")
print("  /boot/nyxloader")
print("  /boot/config.lua")
print("  /boot/secureboot.hash")
print("  /startup.lua")
print("")

write("Confirmer la desinstallation ? (o/n) ")

local choice = read()

if choice ~= "o" and choice ~= "O" then
    print("")
    print("Desinstallation annulee.")
    return
end


local function remove(path)

    if fs.exists(path) then
        fs.delete(path)
        print("  [OK] " .. path)
    end

end


print("")
print("[1/2] Suppression des fichiers NyxLoader")

remove("/boot/nyxloader")
remove("/boot/config.lua")
remove("/boot/secureboot.hash")


print("[2/2] Suppression du demarrage automatique")

if fs.exists("/startup.lua") then

    local file = fs.open("/startup.lua", "r")
    local content = file.readAll()
    file.close()

    if content:find("nyxloader", 1, true) then

        fs.delete("/startup.lua")
        print("  [OK] /startup.lua")

    else

        print("  [SKIP] /startup.lua (ne semble pas lie a NyxLoader)")

    end

end


if fs.exists("/boot") and #fs.list("/boot") == 0 then
    fs.delete("/boot")
end


print("")
print("NyxLoader a ete desinstalle.")
print("Redemarrage conseille dans 3 secondes...")

sleep(3)

os.reboot()
