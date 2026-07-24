local Hash = {}


-- ======================================
-- Recherche du Cryptographic Accelerator
-- ======================================

local crypto = peripheral.find("cryptographic_accelerator")


-- Si peripheral.find ne trouve rien,
-- on cherche manuellement (wired modem inclus)

if not crypto then

    for _, name in ipairs(peripheral.getNames()) do

        if peripheral.getType(name) == "cryptographic_accelerator" then

            crypto = peripheral.wrap(name)
            break

        end

    end

end



-- ======================================
-- Disponibilité
-- ======================================

function Hash.available()

    return crypto ~= nil

end



function Hash.getPeripheral()

    return crypto

end



-- ======================================
-- Hash SHA256
-- ======================================

function Hash.generate(data)

    if not crypto then
        error("Cryptographic Accelerator unavailable")
    end


    if crypto.sha256 then
        return crypto.sha256(data)

    elseif crypto.sha512 then
        return crypto.sha512(data)

    else
        error("No supported hash function found")
    end

end



-- ======================================
-- Hash fichier
-- ======================================

function Hash.file(path)

    if not fs.exists(path) then
        error(
            "File not found: "..path
        )
    end


    local file = fs.open(
        path,
        "r"
    )


    local data = file.readAll()

    file.close()


    return Hash.generate(data)

end



-- ======================================
-- Liste fichiers récursive
-- ======================================

local function listFiles(path, result)

    result = result or {}


    for _, name in ipairs(fs.list(path)) do

        local full = fs.combine(
            path,
            name
        )


        if fs.isDir(full) then

            listFiles(
                full,
                result
            )

        else

            table.insert(
                result,
                full
            )

        end

    end


    return result

end



-- ======================================
-- Hash dossier complet
-- ======================================

function Hash.directory(path)

    if not fs.exists(path) then
        error("Directory not found: "..path)
    end


    local files = listFiles(path)

    table.sort(files)

    local buffer = ""


    for _, filePath in ipairs(files) do

        local file = fs.open(filePath, "r")

        local content = file.readAll()

        file.close()


        -- chemin relatif uniquement
        local relative = filePath:sub(#path + 2)


        buffer = buffer
            .. relative
            .. "\n"
            .. content
            .. "\n"

    end


    return Hash.generate(buffer)

end



-- ======================================
-- Vérification
-- ======================================

function Hash.verify(path, expected)

    local current = Hash.directory(path)

    return current == expected

end



return Hash