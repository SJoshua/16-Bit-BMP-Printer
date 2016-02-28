require("lcon")

local ct = {
	["0"] = 0,
	["4"] = 1,
	["2"] = 2,
	["6"] = 3,
	["1"] = 4,
	["5"] = 5,
	["3"] = 6,
	["8"] = 7,
	["7"] = 8,
	["C"] = 9,
	["A"] = 10,
	["E"] = 11,
	["9"] = 12,
	["D"] = 13,
	["B"] = 14,
	["F"] = 15
}

function tonum(...)
	local t = {...}
	local s = "0x"
	for i = #t, 1, -1 do
		s = s .. string.format("%02X", t[i])
	end
	return tonumber(s)
end

function getnum(n)
	local s = string.format("%02X", n)
	return tonumber("0x" .. s:sub(1, 1)), tonumber("0x" .. s:sub(2, 2))
end

function cput(c, r)
	lcon.set_colorx(0, ct[c])
	io.write(r or " ")
end

function pbmp(bn, tc)
	local f = io.open(bn, "rb")
	local t = f:read("*a")
	f:close()
	
	local tc = tc or {}
	if type(tc) == "string" then
		local f = io.open(tc, "r")
		local d = f:read("*a")
		f:close()
		tc = {}
		for s in d:gmatch("(.-)\n") do
			tc[#tc + 1] = {}
			for i = 1, #s do
				tc[#tc][i] = s:sub(i, i)
			end
		end
	end
	
	local bd = {string.byte(t, 1, -1)}
	local chs = ""
	local count = 0
	local width = tonum(bd[0x13], bd[0x14], bd[0x15], bd[0x16])
	local height = tonum(bd[0x17], bd[0x18], bd[0x19], bd[0x1a])
	local bs = tonum(bd[0x0b], bd[0x0c], bd[0x0d], bd[0x0e])
	local wmax = (width % 4 == 0) and width or (math.floor(width / 4) + 1) * 4
	
	for i = bs + 1, #bd do
		chs = chs .. string.format("%02X", bd[i])
	end
	
	for i = #chs, 80, -80 do
		local s = chs:sub(i - 79, i)
		for j = 1, 80 do
			local ch = s:sub(j, j)
			cput(ch, tc[(#chs - i) / 80] and tc[(#chs - i) / 80][j])
		end
	end
end

lcon.hide_cursor()
pbmp("srlogo.bmp", "srlogo.fmd")
lcon.getch()
lcon.show_cursor()
lcon.set_colorx(0,15)