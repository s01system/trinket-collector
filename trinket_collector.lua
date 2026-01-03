--- Trinket collector
-- Collect voltages and drop bursts
-- v0.0.1

-- You are a crow.
-- You love to fly and look for trinkets.
-- You pick up trinkets and carry them with you.
-- Your beak is small, your strength is configurable.
-- You will drop all trinkets if you carry too much weight.

-- Input 1: (CV) Trinkets, weighted in volts
-- Input 2: (Trig) Pick up the current trinket
-- Output 1: (CV) The weight of the dropped trinket, in volts
-- Output 2: (Trig) The thud when the trinket hits the ground

-- Output 3 and 4 are currently just passing through input 1 and 2

-- made with love by
-- ███████▓▓▓▓▓▓▒▒▒▒
-- ███▓▓▓▓▓▓▒▒▒▒▒▒░░
-- ▓▓▓▓▓▒▒▒▒▒▒▒░░░░░
-- s 0 1 s y s t e m
-- cat.no: s0?system


-- CONFIG ----------------------------------------------------------------------------

your_strength = 20
-- Your strength is the weight that you can carry.
-- You will drop all trinkets if their total weight is greater than your strength.

trinket_sorting = "light_first"
-- Sort trinkets by weight before before dropping them.
-- "nope" means the trinkets will be dropped in the order they were collected.
-- "heavy_first" means the trinkets will be dropped from the heaviest to the lightest.
-- "light_first" means the trinkets will be dropped from the lightest to the heaviest.

air_resistance = 10
-- Air resistance is the force that opposes the motion of the trinkets.
-- A higher value means the trinkets will fall slower.

fall_type = "yassified"
-- The algorithm used to to calculate when each trinket hits the ground.
-- "yassified" means the trinkets will fall with a smooth curve.
-- "weight_based" means the trinkets will fall based on their weight.
-- "linear" means the trinkets fall at evenly spaced moments.


-- INTERNAL VARS ---------------------------------------------------------------------

local beak = {}
local can_pick_up = true
local bird_flag = false

-- SCRIPT ----------------------------------------------------------------------------

function init()
    input[1].mode("stream")
    input[2].mode("change")
end

input[1].stream = function()
    output[3].volts = input[1].volts -- Pass through to output 3
end

input[2].change = function()
    output[4](pulse()) -- Pass through to output 4

    if not can_pick_up then
        return
    end

    table.insert(beak, input[1].volts)
    total_weight = measure_weight()

    print(" ")
    print(" ")
    print("Picked up trinket " .. #beak .. "!")
    print("Current weight is " .. total_weight .. " (of " .. your_strength .. ")")
    print(ascii_percentage_bar(total_weight))

    if total_weight > your_strength then
        drop_trinkets()
    end
end

function ascii_percentage_bar(weight)
    local bird_img = bird_flag and "(⌒ °▽°)" or "(◡ °▽°)"
    local bar_length = 30
    local percentage = math.floor((weight / your_strength) * 100)
    local filled_length = math.floor((percentage / 100) * bar_length)
    local bar = string.rep("･", bar_length - filled_length) .. string.rep("★", filled_length)
    bird_flag = not bird_flag
    return bird_img .. " " .. bar .. " " .. percentage .. "%"
end

function measure_weight()
    local weight = 0
    for _, trinket in ipairs(beak) do
        weight = weight + trinket
    end
    return weight
end

function drop_trinkets()
    print(" ")
    print("Dropping all trinkets.")
    can_pick_up = false -- disable pickup while trinkets are falling
    local temp_beak = beak

    if trinket_sorting == "light_first" then
        table.sort(temp_beak, function(a, b) return a > b end)
    elseif trinket_sorting == "heavy_first" then
        table.sort(temp_beak)
    end

    beak = {}

    for i, trinket in ipairs(temp_beak) do
        if fall_type == "yassified" then
            delay_time = (air_resistance / (#temp_beak * #temp_beak)) * (1.25 ^ i)
        elseif fall_type == "weight_based" then
            delay_time = (trinket / 100) * air_resistance
        elseif fall_type == "linear" then
            delay_time = (i / 100) * air_resistance
        end

        delay(function()
            output[1].volts = trinket
            output[2](pulse())
            print("Goodbye " .. trinket)

            -- reset pickup flag on last trinket
            if i == #temp_beak then
                can_pick_up = true
            end
        end, delay_time)
    end
end
