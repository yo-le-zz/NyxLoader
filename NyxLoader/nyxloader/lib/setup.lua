-- ======================================
-- NyxLoader Setup (installateur partage)
-- ======================================
--
-- Utilise par install.lua (disque) et webinstall.lua (GitHub).
-- Tout le texte affiche est en ASCII pur (pas d'accents : ils
-- s'affichent mal dans le terminal de CC:Tweaked).
--
-- Setup.run{
--   version = "1.1.0",
--   files   = { "nyxloader.lua", "lib/hash.lua", ... },  -- relatifs a /boot/nyxloader
--   fetch   = function(rel) return data end,             -- contenu d'un fichier
-- }

local Setup = {}

local T = {
    en = {
        language = "Language", options = "Installation",
        secure_on = "Secure Boot: available (accelerator found)",
        secure_off = "Secure Boot: unavailable (no accelerator)",
        iso_q = "Isolation mode: NyxLoader alone on this PC",
        iso_help = "Everything else is moved to a disk.",
        yes = "Enable", no = "Disable",
        summary = "Ready to install NyxLoader",
        install = "Install", change = "Change options", cancel = "Cancel",
        cancelled = "Installation cancelled.",
        nocrypto = "No Cryptographic Accelerator found.",
        cont = "Continue without Secure Boot", abort = "Cancel",
        step_dl = "Downloading", step_start = "Creating startup",
        step_cfg = "Writing configuration", step_hash = "Secure Boot hash",
        step_iso = "Isolation mode", nothing = "Nothing to move.",
        moving = "element(s) to move. Insert a disk (Q = cancel).",
        done = "Installation complete!", reboot = "Rebooting in %d s... (any key = now)",
        error = "Error: ", on = "ON", off = "OFF",
    },
    fr = {
        language = "Langue", options = "Installation",
        secure_on = "Secure Boot : disponible (accelerateur trouve)",
        secure_off = "Secure Boot : indisponible (pas d'accelerateur)",
        iso_q = "Mode isolation : NyxLoader seul sur ce PC",
        iso_help = "Tout le reste est deplace sur un disque.",
        yes = "Activer", no = "Desactiver",
        summary = "Pret a installer NyxLoader",
        install = "Installer", change = "Modifier les options", cancel = "Annuler",
        cancelled = "Installation annulee.",
        nocrypto = "Aucun Cryptographic Accelerator trouve.",
        cont = "Continuer sans Secure Boot", abort = "Annuler",
        step_dl = "Telechargement", step_start = "Creation de startup",
        step_cfg = "Ecriture de la configuration", step_hash = "Hash Secure Boot",
        step_iso = "Mode isolation", nothing = "Rien a deplacer.",
        moving = "element(s) a deplacer. Inserez un disque (Q = annuler).",
        done = "Installation terminee !", reboot = "Redemarrage dans %d s... (touche = maintenant)",
        error = "Erreur : ", on = "OUI", off = "NON",
    },
    es = {
        language = "Idioma", options = "Instalacion",
        secure_on = "Secure Boot: disponible (acelerador encontrado)",
        secure_off = "Secure Boot: no disponible (sin acelerador)",
        iso_q = "Modo aislamiento: NyxLoader solo en este PC",
        iso_help = "Todo lo demas se mueve a un disco.",
        yes = "Activar", no = "Desactivar",
        summary = "Listo para instalar NyxLoader",
        install = "Instalar", change = "Cambiar opciones", cancel = "Cancelar",
        cancelled = "Instalacion cancelada.",
        nocrypto = "No hay Cryptographic Accelerator.",
        cont = "Continuar sin Secure Boot", abort = "Cancelar",
        step_dl = "Descargando", step_start = "Creando startup",
        step_cfg = "Escribiendo configuracion", step_hash = "Hash Secure Boot",
        step_iso = "Modo aislamiento", nothing = "Nada que mover.",
        moving = "elemento(s) por mover. Inserte un disco (Q = cancelar).",
        done = "Instalacion completada!", reboot = "Reiniciando en %d s... (tecla = ahora)",
        error = "Error: ", on = "SI", off = "NO",
    },
    de = {
        language = "Sprache", options = "Installation",
        secure_on = "Secure Boot: verfuegbar (Beschleuniger gefunden)",
        secure_off = "Secure Boot: nicht verfuegbar (kein Beschleuniger)",
        iso_q = "Isolationsmodus: NyxLoader allein auf diesem PC",
        iso_help = "Alles andere wird auf eine Diskette verschoben.",
        yes = "Aktivieren", no = "Deaktivieren",
        summary = "Bereit, NyxLoader zu installieren",
        install = "Installieren", change = "Optionen aendern", cancel = "Abbrechen",
        cancelled = "Installation abgebrochen.",
        nocrypto = "Kein Cryptographic Accelerator gefunden.",
        cont = "Ohne Secure Boot fortfahren", abort = "Abbrechen",
        step_dl = "Lade herunter", step_start = "Erstelle startup",
        step_cfg = "Schreibe Konfiguration", step_hash = "Secure-Boot-Hash",
        step_iso = "Isolationsmodus", nothing = "Nichts zu verschieben.",
        moving = "Element(e) zu verschieben. Diskette einlegen (Q = abbrechen).",
        done = "Installation abgeschlossen!", reboot = "Neustart in %d s... (Taste = jetzt)",
        error = "Fehler: ", on = "JA", off = "NEIN",
    },
}

local LANGS = {
    { code = "en", name = "English" },
    { code = "fr", name = "Francais" },
    { code = "es", name = "Espanol" },
    { code = "de", name = "Deutsch" },
}

local lang = "en"
local function t(key) return (T[lang] and T[lang][key]) or T.en[key] or key end

-- Ecran : moniteur externe s'il y en a un
local monitor = peripheral.find("monitor")
local restore
if monitor then
    monitor.setTextScale(1)
    restore = term.redirect(monitor)
end

local C = term.isColor and term.isColor()
local function col(color, fallback) return C and color or fallback end
local ACC, FG, BG = col(colors.cyan, colors.white), colors.white, colors.black

local function size() return term.getSize() end

local function clear()
    term.setBackgroundColor(BG) term.setTextColor(FG) term.clear() term.setCursorPos(1, 1)
end

local function center(y, text, fg, bg)
    local w = size()
    local x = math.max(1, math.floor((w - #text) / 2) + 1)
    term.setCursorPos(x, y)
    term.setTextColor(fg or FG) term.setBackgroundColor(bg or BG)
    term.write(text)
    term.setBackgroundColor(BG) term.setTextColor(FG)
end

local function header(sub)
    clear()
    local w = size()
    term.setBackgroundColor(ACC) term.setTextColor(colors.black)
    term.setCursorPos(1, 1) term.write(string.rep(" ", w))
    center(1, " NyxLoader " .. (Setup.version or ""), colors.black, ACC)
    if sub then center(3, sub, ACC) end
end

-- Menu vertical : fleches + Entree (ou clic)
local function menu(title, items, extra)
    local sel = 1
    while true do
        header(title)
        local w, h = size()
        local y = 5
        if extra then
            for _, line in ipairs(extra) do center(y, line) y = y + 1 end
            y = y + 1
        end
        local top = y
        for i, label in ipairs(items) do
            local text = (i == sel and "> " or "  ") .. label .. (i == sel and " <" or "  ")
            if i == sel then center(top + i - 1, text, colors.black, ACC)
            else center(top + i - 1, text) end
        end
        local ev, a, b, c = os.pullEvent()
        if ev == "key" then
            if a == keys.up then sel = (sel - 2) % #items + 1
            elseif a == keys.down then sel = sel % #items + 1
            elseif a == keys.enter then return sel end
        elseif ev == "mouse_click" then
            local idx = c - top + 1
            if idx >= 1 and idx <= #items then
                if idx == sel then return sel end
                sel = idx
            end
        end
    end
end

-- Barre de progression
local function bar(y, ratio)
    local w = size()
    local bw = math.max(10, w - 8)
    local x = math.floor((w - bw) / 2) + 1
    local filled = math.floor(bw * ratio + 0.5)
    term.setCursorPos(x, y)
    term.setBackgroundColor(ACC) term.write(string.rep(" ", filled))
    term.setBackgroundColor(colors.gray) term.write(string.rep(" ", bw - filled))
    term.setBackgroundColor(BG)
    center(y + 1, string.format("%3d%%", math.floor(ratio * 100)))
end

local function status(step, detail, ratio)
    local _, h = size()
    header(nil)
    center(4, step, ACC)
    if detail then center(6, detail) end
    bar(8, ratio)
end

local function writeFile(path, data)
    local dir = fs.getDir(path)
    if dir ~= "" and not fs.exists(dir) then fs.makeDir(dir) end
    local f = fs.open(path, "wb")
    if not f then error("cannot write " .. path) end
    f.write(data) f.close()
end

local function dirHash(crypto, path)
    local files = {}
    local function scan(dir)
        for _, name in ipairs(fs.list(dir)) do
            local full = fs.combine(dir, name)
            if fs.isDir(full) then scan(full) else files[#files + 1] = full end
        end
    end
    scan(path)
    table.sort(files)
    local buffer = {}
    for _, p in ipairs(files) do
        local f = fs.open(p, "r") local content = f.readAll() f.close()
        buffer[#buffer + 1] = p:sub(#path + 2) .. "\n" .. content .. "\n"
    end
    return crypto.sha256(table.concat(buffer))
end

local function splash()
    clear()
    local w, h = size()
    local logo = {
        " _   _             _                    _           ",
        "| \\ | |_   ___  __| |    ___  __ _  __| | ___ _ __ ",
        "|  \\| | | | \\ \\/ /| |   / _ \\/ _` |/ _` |/ _ \\ '__|",
        "| |\\  | |_| |>  < | |__| (_) | (_| | (_| |  __/ |   ",
        "|_| \\_|\\__, /_/\\_\\|_____\\___/ \\__,_|\\__,_|\\___|_|   ",
        "       |___/                                        ",
    }
    local y = math.max(2, math.floor(h / 2) - 4)
    if w >= 56 then
        for i, line in ipairs(logo) do center(y + i - 1, line, ACC) end
        y = y + #logo
    else
        center(y, "N Y X L O A D E R", ACC) y = y + 1
    end
    center(y + 1, "Setup " .. (Setup.version or ""), colors.lightGray)
    sleep(0.8)
end

function Setup.run(opts)
    Setup.version = opts.version
    local ok, err = pcall(function()
        local crypto = peripheral.find("cryptographic_accelerator")
        local secure = crypto ~= nil
        local isolation = false
        lang = opts.lang or "en"

        if not opts.quiet then
        splash()

        -- Langue
        local names = {}
        for i, l in ipairs(LANGS) do names[i] = l.name end
        lang = LANGS[menu("Language / Langue", names)].code

        while true do
            if not crypto then
                local c = menu(t("options"), { t("cont"), t("abort") }, { t("nocrypto") })
                if c == 2 then clear() print(t("cancelled")) return end
            end
            local c = menu(t("options"), { t("no"), t("yes") }, { crypto and t("secure_on") or t("secure_off"), "", t("iso_q"), t("iso_help") })
            isolation = (c == 2)
            local s = menu(t("summary"), { t("install"), t("change"), t("cancel") }, {
                "Secure Boot : " .. (secure and t("on") or t("off")),
                "Isolation   : " .. (isolation and t("on") or t("off")),
            })
            if s == 1 then break
            elseif s == 3 then clear() print(t("cancelled")) return end
            crypto = peripheral.find("cryptographic_accelerator")
        end
        end

        -- Installation
        if not fs.exists("/boot") then fs.makeDir("/boot") end
        if fs.exists("/boot/nyxloader") then fs.delete("/boot/nyxloader") end

        local total = #opts.files + 4
        local done = 0
        for _, rel in ipairs(opts.files) do
            status(t("step_dl"), rel, done / total)
            local data = opts.fetch(rel)
            if not data then error("missing " .. rel) end
            writeFile("/boot/nyxloader/" .. rel, data)
            done = done + 1
        end

        status(t("step_start"), "/startup.lua", done / total)
        writeFile("/startup.lua", 'shell.run("/boot/nyxloader/nyxloader.lua")')
        done = done + 1

        status(t("step_cfg"), "/boot/config.lua", done / total)
        writeFile("/boot/config.lua", "return {\n    title = \"NyxLoader\",\n    timeout = 10,\n    bootColor = colors.blue,\n    secureBoot = "
            .. tostring(secure) .. ",\n    isolation = " .. tostring(isolation) .. ",\n    lang = \"" .. lang .. "\"\n}\n")
        done = done + 1

        status(t("step_hash"), nil, done / total)
        if secure and crypto then
            writeFile("/boot/secureboot.hash", dirHash(crypto, "/boot/nyxloader"))
        end
        done = done + 1

        status(t("step_iso"), nil, done / total)
        if isolation then
            local iso = dofile("/boot/nyxloader/lib/isolation.lua")
            local stray = iso.listStrayEntries()
            if #stray == 0 then
                center(10, t("nothing"))
                sleep(0.8)
            else
                clear()
                print(#stray .. " " .. t("moving"))
                print("")
                iso.enforce(print)
            end
        end
        done = done + 1

        status(t("done"), nil, 1)
        if opts.quiet then
            if restore then term.redirect(restore) end
            return
        end

        -- Redemarrage automatique
        for n = 5, 1, -1 do
            center(11, string.format(t("reboot"), n) .. "   ", colors.lightGray)
            local timer = os.startTimer(1)
            while true do
                local ev, a = os.pullEvent()
                if ev == "timer" and a == timer then break end
                if ev == "key" or ev == "mouse_click" or ev == "char" then n = 0 break end
            end
            if n == 0 then break end
        end
        if restore then term.redirect(restore) end
        os.reboot()
    end)
    if not ok then
        if restore then pcall(term.redirect, restore) end
        term.setBackgroundColor(colors.black) term.setTextColor(colors.red)
        print("")
        print(t("error") .. tostring(err))
        term.setTextColor(colors.white)
    end
end

return Setup
