local basalt = dofile(NYXLOADER_PATH .. "/lib/basalt.lua")

local ui = {}


-- ======================================
-- Utilitaires
-- ======================================

local function clear()

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)

    term.clear()
    term.setCursorPos(1,1)

end



local function center(text, y)

    local w = term.getSize()

    local x = math.floor(
        (w - #text) / 2
    )


    term.setCursorPos(
        math.max(1,x),
        y
    )

    write(text)

end



-- Dessine uniquement le contour de la boîte (haut, bas, gauche,
-- droite) dans la couleur donnée. L'intérieur n'est jamais rempli :
-- il reste "transparent", c'est à dire tel qu'il était déjà affiché
-- à l'écran avant l'appel (fond déjà nettoyé par clear()).

local function drawFrame(x,y,w,h,color)

    term.setBackgroundColor(color or colors.blue)
    term.setTextColor(colors.white)


    -- Bord haut

    term.setCursorPos(x,y)
    write(string.rep(" ",w))


    -- Bord bas

    term.setCursorPos(x,y+h-1)
    write(string.rep(" ",w))


    -- Bords gauche / droite

    for i = 1,h-2 do

        term.setCursorPos(x,y+i)
        write(" ")

        term.setCursorPos(x+w-1,y+i)
        write(" ")

    end


    term.setBackgroundColor(colors.black)


end



local function drawTextBox(
    x,
    y,
    w,
    text,
    selected,
    accentColor
)


    if selected then

        term.setBackgroundColor(
            accentColor or colors.blue
        )

    else

        term.setBackgroundColor(
            colors.gray
        )

    end


    term.setTextColor(
        colors.white
    )


    term.setCursorPos(
        x,
        y
    )


    local value =
        " " .. text


    write(
        string.sub(
            value ..
            string.rep(
                " ",
                w
            ),
            1,
            w
        )
    )


    term.setBackgroundColor(
        colors.black
    )


end



-- ======================================
-- Splash screen (icone d'OS)
-- ======================================

-- Affiché juste avant de démarrer un OS qui déclare un champ
-- "icon" dans son boot.json (image .nfp, format paintutils).
-- L'image est centrée sur l'écran, quelle que soit sa taille.
-- Si l'image est absente/invalide, la fonction ne fait rien :
-- le boot continue normalement sans splash.

function ui.splash(system, config)


    if not system.icon then
        return
    end

    if not fs.exists(system.icon) then
        return
    end


    local ok, image = pcall(
        paintutils.loadImage,
        system.icon
    )


    if not ok or not image then
        return
    end


    clear()


    local screenW, screenH =
        term.getSize()


    local imageH = #image

    local imageW = 0

    for _,row in ipairs(image) do
        imageW = math.max(imageW, #row)
    end


    if imageH == 0 or imageW == 0 then
        return
    end


    local x = math.max(
        1,
        math.floor((screenW - imageW) / 2) + 1
    )

    local y = math.max(
        1,
        math.floor((screenH - imageH) / 2) + 1
    )


    paintutils.drawImage(
        image,
        x,
        y
    )


    term.setTextColor(colors.white)

    center(
        system.name,
        math.min(
            screenH,
            y + imageH + 1
        )
    )


    sleep(1)


end



-- ======================================
-- Message
-- ======================================

function ui.message(text)

    clear()


    local w,h =
        term.getSize()


    center(
        "NyxLoader",
        2
    )


    local lines = {}

    for line in text:gmatch("[^\n]+") do
        table.insert(lines,line)
    end


    local start =
        math.floor(h/2)
        - (#lines/2)


    for i,line in ipairs(lines) do

        term.setCursorPos(
            2,
            start+i
        )

        print(line)

    end



    term.setCursorPos(
        2,
        h-2
    )


    print(
        "[ENTER] Retour au menu"
    )



    while true do

        basalt.update()


        local event,key =
            os.pullEvent("key")


        if key == keys.enter then
            return
        end

    end

end



-- ======================================
-- Erreur de boot
-- ======================================

-- Écran affiché quand un système ne démarre pas (fichier
-- manquant, crash de l'OS...). Contrairement à ui.warning, il
-- ne propose qu'un seul choix : appuyer sur ENTREE pour revenir
-- au menu NyxLoader.

function ui.error(text)


    clear()


    local w,h =
        term.getSize()


    term.setTextColor(
        colors.red
    )

    center(
        "Echec du demarrage",
        2
    )

    term.setTextColor(
        colors.white
    )


    local lines = {}

    for line in text:gmatch("[^\n]+") do
        table.insert(lines,line)
    end


    local start =
        math.floor(h/2)
        - (#lines/2)


    for i,line in ipairs(lines) do

        term.setCursorPos(
            2,
            start+i
        )

        print(line)

    end


    term.setTextColor(
        colors.yellow
    )

    term.setCursorPos(
        2,
        h-2
    )

    print(
        "[ENTER] Retour au menu"
    )

    term.setTextColor(
        colors.white
    )


    while true do

        basalt.update()


        local event,key =
            os.pullEvent("key")


        if key == keys.enter then
            return
        end

    end


end



-- ======================================
-- Warning
-- ======================================

function ui.warning(text, choices)


    clear()


    local w,h =
        term.getSize()


    center(
        "NyxLoader",
        2
    )


    local y =
        math.floor(h/2)
        - (#choices/2)


    term.setCursorPos(
        2,
        y-2
    )


    print(text)



    for i,choice in ipairs(choices) do


        term.setCursorPos(
            4,
            y+i
        )


        print(
            "["..
            i..
            "] "..
            choice
        )

    end



    while true do


        basalt.update()


        local event,key =
            os.pullEvent()


        if event == "key" then


            local number =
                tonumber(
                    keys.getName(key)
                )


            if number
            and choices[number] then

                return number

            end

        end


    end


end



-- ======================================
-- Menu boot
-- ======================================

function ui.menu(
    systems,
    config
)


    local selected = 1

    local timeout =
        config.timeout


    local timer =
        os.startTimer(1)



    while true do


        clear()


        local width,height =
            term.getSize()



        center(
            config.title or "NyxLoader",
            2
        )



        local boxWidth =
            math.min(
                40,
                width-4
            )


        local boxHeight =
            #systems + 4



        local boxX =
            math.floor(
                (width-boxWidth)/2
            )


        local boxY =
            math.floor(
                (height-boxHeight)/2
            )



        -- cadre

        drawFrame(
            boxX,
            boxY,
            boxWidth,
            boxHeight,
            config.bootColor or colors.blue
        )



        for i,system in ipairs(systems) do


            drawTextBox(
                boxX,
                boxY+i+1,
                boxWidth,
                system.name,
                i == selected,
                system.color
            )


        end



        term.setBackgroundColor(
            colors.black
        )


        term.setTextColor(
            colors.white
        )


        term.setCursorPos(
            2,
            height-1
        )


        write(
            "Auto boot : "
            ..
            timeout
            ..
            "s"
        )



        basalt.update()



        local event,a,b =
            os.pullEvent()



        -- Timer

        if event == "timer"
        and a == timer then


            timeout =
                timeout - 1



            if timeout <= 0 then

                return systems[selected]

            end



            timer =
                os.startTimer(1)

        end



        -- clavier

        if event == "key" then


            if a == keys.up then


                selected =
                    selected - 1


                if selected < 1 then
                    selected = #systems
                end


                timeout =
                    config.timeout



            elseif a == keys.down then


                selected =
                    selected + 1


                if selected > #systems then
                    selected = 1
                end


                timeout =
                    config.timeout



            elseif a == keys.enter then


                return systems[selected]


            end


        end




        -- souris

        if event == "mouse_click" then


            local x =
                a

            local y =
                b



            for i,_ in ipairs(systems) do


                local line =
                    boxY+i



                if y == line
                and x >= boxX
                and x <= boxX+boxWidth then


                    selected = i


                    timeout =
                        config.timeout


                    return systems[selected]


                end


            end


        end


    end


end



return ui