local Scanner = {}


-- ======================================
-- Lecture boot.json
-- ======================================

local function readBootFile(path)

    local file = fs.open(path, "r")

    if not file then
        return nil
    end


    local data = file.readAll()

    file.close()


    local ok, json = pcall(
        textutils.unserializeJSON,
        data
    )


    if not ok or not json then
        return nil
    end


    if not json.name or not json.file then
        return nil
    end


    return json

end



-- ======================================
-- Scan récursif
-- ======================================

local function scanDirectory(
    path,
    result
)

    result = result or {}


    for _, name in ipairs(fs.list(path)) do

        local full = fs.combine(
            path,
            name
        )


        if fs.isDir(full) then

            -- éviter les dossiers inutiles
            if name ~= "rom" then

                scanDirectory(
                    full,
                    result
                )

            end


        else

            if name == "boot.json" then


                local boot =
                    readBootFile(full)


                if boot then


                    table.insert(
                        result,
                        {
                            name = boot.name,
                            file = fs.combine(
                                fs.getDir(full),
                                boot.file
                            ),
                            location = path
                        }
                    )


                end

            end

        end

    end


    return result

end



-- ======================================
-- Recherche des disques
-- ======================================

local function getRoots()

    local roots = {
        "/"
    }


    for _, side in ipairs(peripheral.getNames()) do

        if peripheral.getType(side)
            == "drive" then


            local mount =
                peripheral.call(
                    side,
                    "getMountPath"
                )


            if mount then

                table.insert(
                    roots,
                    mount
                )

            end

        end

    end


    return roots

end



-- ======================================
-- Scan complet
-- ======================================

function Scanner.scan()


    local systems = {}

    local scanned = {}



    for _, root in ipairs(getRoots()) do


        if not scanned[root] then


            scanned[root] = true


            scanDirectory(
                root,
                systems
            )


        end

    end



    -- Ajout du shell secours

    table.insert(
        systems,
        {
            name = "CraftOS Shell",
            file = "/rom/startup.lua",
            location = "internal"
        }
    )



    return systems

end



return Scanner