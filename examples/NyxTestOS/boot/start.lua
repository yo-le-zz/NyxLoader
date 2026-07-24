-- ======================================
-- NyxTestOS
-- ======================================
--
-- OS minimal fourni en exemple pour tester NyxLoader :
-- detection, splash screen (icon.nfp), demarrage, et retour
-- au menu. Il ne fait volontairement pas grand chose.


term.setBackgroundColor(colors.black)
term.setTextColor(colors.cyan)
term.clear()
term.setCursorPos(1,1)

print("========================================")
print(" NyxTestOS - OS d'exemple pour NyxLoader")
print("========================================")
print("")

term.setTextColor(colors.white)

print("Demarre avec succes depuis NyxLoader.")
print("")

print("Ordinateur : #" .. os.getComputerID())

local label = os.getComputerLabel()

if label then
    print("Label      : " .. label)
end

print("CC:Tweaked : " .. (_HOST or "inconnu"))
print("")

print("Commandes disponibles :")
print("  info   - infos systeme")
print("  clear  - efface l'ecran")
print("  exit   - retour au menu NyxLoader")
print("")


while true do

    term.setTextColor(colors.cyan)
    write("NyxTestOS> ")
    term.setTextColor(colors.white)

    local input = read()

    if input == "exit" then

        print("Retour au menu NyxLoader...")
        sleep(1)
        break

    elseif input == "clear" then

        term.clear()
        term.setCursorPos(1,1)

    elseif input == "info" then

        print("Ordinateur : #" .. os.getComputerID())
        print("Espace disque libre : " .. fs.getFreeSpace("/") .. " octets")

    elseif input ~= "" then

        print("Commande inconnue : " .. input)

    end

end
