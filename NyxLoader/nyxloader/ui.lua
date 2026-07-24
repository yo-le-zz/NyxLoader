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



local function drawFrame(x,y,w,h,color)

    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)


    for i = 0,h-1 do

        term.setCursorPos(
            x,
            y+i
        )


        write(
            string.rep(" ",w)
        )

    end


end



local function drawTextBox(
    x,
    y,
    w,
    text,
    selected
)


    if selected then

        term.setBackgroundColor(
            colors.blue
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
                i == selected
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