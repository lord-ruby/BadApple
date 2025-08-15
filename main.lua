local hex_ref = HEX
function HEX(t)
    if type(t) == "table" then return t else return hex_ref(t or "FFFFFF") end
end
raw_pixel_data = SMODS.load_file("output.txt")()
local height = raw_pixel_data.metadata and raw_pixel_data.metadata.height or 15
local width = raw_pixel_data.metadata and raw_pixel_data.metadata.width or 20
local scale = raw_pixel_data.metadata and raw_pixel_data.metadata.scale or 0.25
bad_apple_height = height
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
                {n=G.UIT.C, config={func = 'ba_'..tostring(i).."_"..tostring(y), align = "cl", minw = scale, minh=scale, r = 0.1,colour = G.C.UI.TEXT_LIGHT, id = 'hand_mult_area', max_w = scale, max_h = scale}, nodes={
                  {n=G.UIT.O, config={id = ids_to_not_fucking_crash[i] or 'hand_chips', object = obj}}
                }}
			},
		}
    end
    return { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = contents }
end

pixel_map = {}
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
    --if current_frame > #raw_pixel_data then G.play_bad_apple = nil end
    if G.play_bad_apple then
        bad_apple_dt = bad_apple_dt + dt
    end
    if G.play_bad_apple and raw_pixel_data[current_frame] and bad_apple_dt > raw_pixel_data[current_frame].offset / 1080 then
        bad_apple_dt = 0
        pixel_map = raw_pixel_data[current_frame]
        current_frame = current_frame + 1
    end
    if current_frame > #raw_pixel_data then pixel_map = {}; G.play_bad_apple = nil end
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
            SMODS.set_scoring_calculation("ba_bad_apple")
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


SMODS.Scoring_Calculation {
    key = "bad_apple",
    func = function(self, chips, mult, flames)
        return mult + chips
    end,
    parameters = {'mult'},
    replace_ui = function(self)
        local rows = {}
        for i = 1, bad_apple_height - 1 do
            rows[#rows+1] = generate_row(i)
        end
		return
        {n=G.UIT.R, config={align = "cm", id = 'hand_text_area', colour = darken(G.C.BLACK, 0.1), r = 0.1, emboss = 0.05, padding = 0.03}, nodes={
                {n=G.UIT.C, config={align = "cm"}, nodes={
                {n = G.UIT.R, config = {align = "cm", minh=1}, nodes = {
                    { n = G.UIT.C, config = { align = "tm", padding = 0 }, nodes = rows}
                }}
            }}
        }}
	end
}
