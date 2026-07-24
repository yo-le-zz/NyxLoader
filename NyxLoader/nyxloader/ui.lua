local basalt = dofile("/boot/nyxloader/lib/basalt.lua")


local ui = {}


-- ======================================
-- Initialisation
-- ======================================

local function clear()

    term.clear()
    term.setCursorPos(1,1)

end


local function center(text, y)

    local w = term.getSize()

    local x = math.floor(
        (w - #text) / 2
    )

    term.setCursorPos(
        math.max(x,1),
        y
    )

    write(text)

end



-- ======================================
-- Message simple
-- ======================================

function ui.message(text)

    clear()

    center(
        "NyxLoader",
        2
    )


    term.setCursorPos(
        2,
        5
    )

    print(text)


    print("")
    print("Appuyez sur une touche...")


    os.pullEvent("key")

end



-- ======================================
-- Warning / choix
-- ======================================

function ui.warning(text, choices)

    clear()


    center(
        "NyxLoader",
        2
    )


    term.setCursorPos(
        2,
        5
    )


    print(text)


    print("")


    for i, choice in ipairs(choices) do

        print(
            "[" ..
            i ..
            "] " ..
            choice
        )

    end



    while true do

        local _, key = os.pullEvent("key")


        local num =
            tonumber(
                keys.getName(key)
            )


        if num and choices[num] then

            return num

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


    while true do


        clear()


        center(
            config.title,
            2
        )


        local width, height =
            term.getSize()



        local startY =
            math.floor(height / 2)
            - (#systems / 2)



        for i, system in ipairs(systems) do


            term.setCursorPos(
                5,
                startY + i
            )


            if i == selected then

                term.setBackgroundColor(
                    colors.blue
                )

                term.setTextColor(
                    colors.white
                )

            else

                term.setBackgroundColor(
                    colors.black
                )

                term.setTextColor(
                    colors.white
                )

            end



            write(
                " "
                .. system.name
                .. " "
            )


            term.setBackgroundColor(
                colors.black
            )

        end



        term.setCursorPos(
            2,
            height - 2
        )


        write(
            "Auto boot dans "
            .. config.timeout
            .. "s"
        )



        local event, key =
            os.pullEvent("key")



        if key == keys.up then

            selected =
                selected - 1


            if selected < 1 then
                selected = #systems
            end


        elseif key == keys.down then


            selected =
                selected + 1


            if selected > #systems then
                selected = 1
            end


        elseif key == keys.enter then


            return systems[selected]

        end


    end

end



return ui
