local Scanner = {}



-- ======================================
-- Couleurs nommées (pour boot.json)
-- ======================================

-- boot.json est du JSON : il ne peut pas contenir directement
-- colors.cyan etc. On accepte donc un nom de couleur en texte
-- ("cyan", "red", ...) et on le convertit ici.

local colorNames = {

    white      = colors.white,
    orange     = colors.orange,
    magenta    = colors.magenta,
    lightBlue  = colors.lightBlue,
    yellow     = colors.yellow,
    lime       = colors.lime,
    pink       = colors.pink,
    gray       = colors.gray,
    grey       = colors.gray,
    lightGray  = colors.lightGray,
    lightGrey  = colors.lightGray,
    cyan       = colors.cyan,
    purple     = colors.purple,
    blue       = colors.blue,
    brown      = colors.brown,
    green      = colors.green,
    red        = colors.red,
    black      = colors.black

}


local function resolveColor(name)

    if type(name) ~= "string" then
        return nil
    end

    return colorNames[name]

end



-- ======================================
-- Lecture boot.json
-- ======================================

local function readBootFile(path)

    local file = fs.open(path,"r")

    if not file then
        return nil
    end


    local data = file.readAll()

    file.close()



    local ok,json =
        pcall(
            textutils.unserializeJSON,
            data
        )


    if not ok or not json then
        return nil
    end



    if not json.name
    or not json.file then

        return nil

    end



    return json

end





-- ======================================
-- Scan récursif
-- ======================================

local ignored = {

    ["rom"] = true,
    [".git"] = true,
    ["node_modules"] = true

}



local function scanDirectory(
    path,
    result,
    found
)


    for _,name in ipairs(fs.list(path)) do


        local full =
            fs.combine(
                path,
                name
            )



        if fs.isDir(full) then


            if not ignored[name] then


                scanDirectory(
                    full,
                    result,
                    found
                )


            end



        elseif name == "boot.json" then



            local boot =
                readBootFile(full)



            if boot then



                local osPath =
                    fs.getDir(full)



                local id =
                    boot.id
                    or (
                        boot.name
                        .. ":"
                        .. boot.file
                    )



                -- Anti doublon

                if not found[id] then


                    found[id] = true



                    table.insert(
                        result,
                        {

                            name = boot.name,


                            file =
                                fs.combine(
                                    osPath,
                                    boot.file
                                ),


                            location =
                                osPath,


                            id =
                                id,


                            icon =
                                boot.icon
                                and fs.combine(
                                    osPath,
                                    boot.icon
                                )
                                or nil,


                            color =
                                resolveColor(
                                    boot.color
                                )

                        }
                    )


                end


            end


        end


    end


end





-- ======================================
-- Racines disponibles
-- ======================================

local function getRoots()


    local roots = {

        "/"

    }



    for _,name in ipairs(
        peripheral.getNames()
    ) do



        if peripheral.getType(name)
            == "drive" then



            local mount =
                peripheral.call(
                    name,
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

    local found = {}



    for _,root in ipairs(
        getRoots()
    ) do



        if not scanned[root] then


            scanned[root] = true



            scanDirectory(
                root,
                systems,
                found
            )


        end


    end





    -- Shell secours

    table.insert(
        systems,
        {

            name =
                "CraftOS Shell",


            file =
                "/rom/programs/shell.lua",


            location =
                "internal",


            id =
                "craftos"

        }
    )



    -- Désinstaller NyxLoader

    table.insert(
        systems,
        {

            name =
                "Desinstaller NyxLoader",


            location =
                "internal",


            id =
                "uninstall"

        }
    )



    return systems

end



return Scanner