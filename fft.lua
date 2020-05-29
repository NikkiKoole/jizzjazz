--[[
Copyright (c) 2017 raidho36/rcoaxil

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

-- output is a complex number (vector) that represents sine wave magnitude (vector length) and phase shift (vector angle)
-- if 'keep original data' flag is not set, original data will be replaced with respective harmonic magnitude

local msqrt, msin, mcos, m2pi = math.sqrt, math.sin, math.cos, math.pi * 2.0

local function cpol ( r, a )
	return mcos ( a ) * r, msin ( a ) * r
end

local function cadd ( a, b, c, d )
	return a + c, b + d
end

local function csub ( a, b, c, d )
	return a - c, b - d
end

local function cmul ( a, b, c, d )
	return a * c - b * d, b * c + a * d
end

local function _fft ( x, y )
	local l = #x
	if l <= 1 then return end

	local ox, oy, ex, ey = { }, { }, { }, { }
	for i = 1, l / 2 do
		ox[ i ], oy[ i ] = x[ i * 2 - 1 ], y[ i * 2 - 1 ]
		ex[ i ], ey[ i ] = x[ i * 2     ], y[ i * 2     ]
	end

	_fft ( ex, ey )
	_fft ( ox, oy )

	for i = 1, l / 2 do
		local xx, yy = cpol ( 1.0, -m2pi * i / l )
		xx, yy = cmul ( xx, yy, ox[ i ], oy[ i ] )
		x[ i         ], y[ i         ] = cadd ( ex[ i ], ey[ i ], xx, yy )
		x[ i + l / 2 ], y[ i + l / 2 ] = csub ( ex[ i ], ey[ i ], xx, yy )
	end
end

local function fft ( data, keeporiginaldata )
	local x, y = { }, { }
	for i = 1, #data do
		x[ i ], y[ i ] = data[ i ], 0
	end

	_fft ( x, y )

	if not keeporiginaldata then
		for i = 1, #data do
			data[ i ] = msqrt ( x[ i ] * x[ i ] + y[ i ] * y[ i ] )
		end
	end
	return x, y
end

return fft
