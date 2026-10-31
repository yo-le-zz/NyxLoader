-- ======================================
-- Mode Isolation
-- ======================================
--
-- Objectif : NyxLoader (et lui seul) reste sur le disque dur
-- principal de l'ordinateur. Tout le reste (un OS qui vient de
-- s'installer, un fichier telecharge a la racine, etc.) est
-- automatiquement deplace sur un disque externe.
--
-- Comme le chemin d'un OS dans son boot.json ("file", "icon") est
-- toujours resolu par rapport a l'endroit ou se trouve son
-- boot.json (fs.combine(osPath, ...)), deplacer tout le dossier
-- d'un OS vers un disque ne casse jamais ses chemins : le scanner
-- les recalcule a chaque scan, ou que soit le dossier.


local Isolation = {}



-- ======================================
-- Elements jamais deplaces
-- ======================================

local protectedNames = {

    ["rom"]         = true,
    ["boot"]        = true,
    ["startup.lua"] = true

}



-- Points de montage des disques actuellement branches : on ne les
-- deplace jamais eux-memes (ce sont des peripheriques, pas des
-- fichiers).

local function mountedDiskPaths()

    local mounts = {}

    for _, name in ipairs(peripheral.getNames()) do

        if peripheral.getType(name) == "drive" then

            local mount = peripheral.call(name, "getMountPath")

            if mount then
                mounts[mount] = true
            end

        end

    end

    return mounts

end



-- ======================================
-- Detection des elements "en trop"
-- ======================================

function Isolation.listStrayEntries()

    local mounts = mountedDiskPaths()
    local stray = {}

    for _, name in ipairs(fs.list("/")) do

        if not protectedNames[name]
        and not mounts[name] then

            table.insert(stray, name)

        end

    end

    return stray

end



-- ======================================
-- Recherche d'un disque disponible
-- ======================================

-- Renvoie le point de montage du premier disque insere trouve
-- (peripheral.call("getMountPath") est nil si le lecteur est vide).

function Isolation.findFreeDisk()

    for _, name in ipairs(peripheral.getNames()) do

        if peripheral.getType(name) == "drive" then

            local mount = peripheral.call(name, "getMountPath")

            if mount then
                return mount
            end

        end

    end

    return nil

end



-- ======================================
-- Attente d'un disque
-- ======================================

-- Bloque jusqu'a ce qu'un disque soit detecte, ou que l'utilisateur
-- annule avec Q. Affiche un message simple en plein ecran (ce
-- module ne depend pas de ui.lua pour rester reutilisable depuis
-- install.lua / webinstall.lua).

function Isolation.waitForDisk()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(2,2)

    print("=== Mode Isolation ===")
    print("")
    print("En attente d'un disque...")
    print("Inserez un disque dans un lecteur.")
    print("")
    print("[Q] Annuler")


    while true do

        local disk = Isolation.findFreeDisk()

        if disk then
            return disk
        end


        local event, key = os.pullEvent()

        if event == "key" and key == keys.q then
            return nil
        end

    end

end



-- ======================================
-- Deplacement
-- ======================================

local function moveOne(name, diskMount, log)

    local source = fs.combine("/", name)
    local destination = fs.combine(diskMount, name)


    -- Evite d'ecraser un element existant du meme nom sur le disque

    if fs.exists(destination) then

        destination = destination
            .. "_"
            .. tostring(os.epoch("utc"))

    end


    local ok, err = pcall(fs.move, source, destination)


    if log then

        if ok then
            log("  [OK] " .. name .. " -> " .. destination)
        else
            log("  [ECHEC] " .. name .. " : " .. tostring(err))
        end

    end

    return ok

end



-- ======================================
-- Nettoyage complet
-- ======================================

-- log : fonction optionnelle (text) appelee pour chaque etape.
-- ask : fonction optionnelle (message, choices) -> index, utilisee
--       pour demander confirmation avant de bloquer sur
--       waitForDisk() quand aucun disque n'est deja disponible. Si
--       elle n'est pas fournie, on attend directement.

function Isolation.enforce(log, ask)

    local stray = Isolation.listStrayEntries()

    if #stray == 0 then
        return
    end


    local disk = Isolation.findFreeDisk()


    if not disk then

        if ask then

            local choice = ask(
                "MODE ISOLATION\n\n" ..
                #stray .. " element(s) detecte(s) sur le\n" ..
                "PC principal. Inserez un disque pour\n" ..
                "les deplacer.",
                {
                    "Inserer un disque",
                    "Ignorer pour cette fois"
                }
            )

            if choice ~= 1 then
                return
            end

        end


        disk = Isolation.waitForDisk()

        if not disk then
            return
        end

    end


    for _, name in ipairs(stray) do
        moveOne(name, disk, log)
    end

end



return Isolation
