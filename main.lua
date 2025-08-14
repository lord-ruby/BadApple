local hex_ref = HEX
function HEX(t)
    if type(t) == "table" then return t else return hex_ref(t or "FFFFFF") end
end

local height = 15
local width = 20
local obj
local ids_to_not_fucking_crash = {
    "hand_mult",
    "hand_name",
    "hand_level",
    "hand_chip_total",
    "hand_chips"
}
function generate_row(y)
    local contents = {}
    obj = obj or DynaText({string = "", colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, shadow = true, float = true, scale = 0})
    for i = 1, width - 1 do
        contents[#contents+1] = {
			n = G.UIT.C,
			config = { align = "cm" },
			nodes = {
                {n=G.UIT.C, config={func = 'ba_'..tostring(i).."_"..tostring(y), align = "cl", minw = 0.25, minh=0.25, r = 0.1,colour = G.C.UI.TEXT_LIGHT, id = 'hand_mult_area', emboss = 0.05, max_w = 0.25, max_h = 0.25}, nodes={
                  {n=G.UIT.O, config={id = ids_to_not_fucking_crash[i] or 'hand_chips', object = obj}}
                }}
			},
		}
    end
    return { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = contents }
end

pixel_map = {}
raw_pixel_data = SMODS.load_file("output.txt")()
for x = 1, width do
    for y = 1, height do
        G.FUNCS["ba_"..tostring(x).."_"..tostring(y)] = function(e)
            pixel_map["ba_"..tostring(x).."_"..tostring(y)] = HEX(pixel_map["ba_"..tostring(x).."_"..tostring(y) or "FFFFFF"]) or HEX("FFFFFF")
            e.config.colour = pixel_map["ba_"..tostring(x).."_"..tostring(y)]
        end
    end
end


bad_apple_dt = -0.1
current_frame = 1
local upd_ref = Game.update
function Game:update(dt, ...)
    upd_ref(self, dt, ...)
    if G.play_bad_apple then
        bad_apple_dt = bad_apple_dt + dt
    end
    if G.play_bad_apple and raw_pixel_data[current_frame] and bad_apple_dt > raw_pixel_data[current_frame].offset / 1080 then
        bad_apple_dt = 0
        current_frame = current_frame + 1
        pixel_map = raw_pixel_data[current_frame]
    end
    if current_frame > #raw_pixel_data then pixel_map = {} end
end

SMODS.Sound({
	key = "music_bad_apple",
	path = "music_bad_apple.ogg",
	select_music_track = function()
		return G.play_bad_apple and 10^307
	end,
	sync = false
})

SMODS.Joker:take_ownership("j_diet_cola", {
    calculate = function(self, card, context)
        if context.selling_self then
            G.play_bad_apple = true
        end
    end,
    loc_txt = {
        name = "Diet Cola",
        text = {
            "Sell this Card to",
            "...?"
        }
    }
}, true)
