inspect = require "inspect"
require 'ui'
require 'editor_ui'
require 'musicBar'
require 'fileBrowser'
local thread -- Our thread object.
--luamidi = require "luamidi"
-- upright bass in emu hiphop
--local fft = require 'fft'
function love.keypressed(key)
   if key == 'escape' then
      channel.main2audio:push ( "quit" );
   end
end

function mysplit (inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

function love.wheelmoved(a,b)
   handleMusicBarWheelMoved(musicBar, a,b)
end




function love.update(dt)
    local error = thread:getError()
    assert( not error, error )
    local v = channel.audio2main:pop ();
    if v then
       if v == 'quit' then
          love.event.quit()
       end
       if v.playSemitone then
          local names = {'C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-'}
          local number = math.floor(v.playSemitone / 12)
          lastHitNote =  names[(v.playSemitone % 12)+1]..number
       end
       if v.soundData then
          activeSoundData = v.soundData
       end
       
       
    end
end




function love.mousepressed(x,y)
   handleMusicBarClicked(musicBar,x,y)
end

function stringEndsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end




function round(num, numDecimalPlaces)
   local mult = 10^(numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

function love.mousereleased(x,y)
   handleMusicBarMouseReleased(musicBar,x,y)
   
   dragging = false
   love.mouse.setCursor(cursors.arrow)

   browser = handleBrowserClick(browser, x,y)
   lastDraggedElement = nil
end


function love.mousemoved(x,y,dx,dy)
   --print(inspect(musicBar.dict))
   
  handleMusicBarMouseMoved(musicBar, x,y,dx,dy)
end


function love.load()
   thread = love.thread.newThread( 'thread.lua' )
   thread:start( )
   channel		= {};
   channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
   channel.main2audio	= love.thread.getChannel ( "main2audio" ); -- from main
   
   
   --love.window.setMode(1024, 768)
   cursors = {hand=love.mouse.getSystemCursor("hand"),
              arrow=love.mouse.getSystemCursor("arrow"),
              sizewe = love.mouse.getSystemCursor("sizewe")}
   dragging = false
   --font = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 48)
   font = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 16)
   --font = love.graphics.newFont( "resources/fonts/Impact Label.ttf", 15)
   love.graphics.setFont(font)
   
   musicBar = createMusicBar()

  
   browser = fileBrowser("assets", {"oscillators"})
   
   lastClickedFile = nil
   lastHitNote = nil
   activeSoundData = nil

   red = {0.52, 0, 0.03}

   mouseState = {
      hoveredSomething = false,
      down = false,
      lastDown = false,
      click = false,
      offset = {x=0, y=0}
   }

   adsr = {
      attack = 0.01,
      max   = .90,
      decay = 0.0,
      sustain= .70,
      release = .02,
   }
   
   eq = {
      fadeout = 0,
      fadein = 0,
      lowpass = {
         enabled=false,
         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      highpass = {
         enabled=false,
         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      bandpass = {
         enabled=false,


         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      notch = {
         enabled=false,


         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      allpass = {
         enabled=false,


         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      lowshelf = {
         enabled=false,

         gain = 0,  -- [-60,60]
         wet = 1,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      },
      highshelf = {
         enabled=false,

         gain = 0,  -- [-60,60]
         wet = 0,   -- [0, 1]
         q = 1,     -- [0, 100]
         frequency = 0 -- [0, samplerate/2]
      }

   }
   --print(inspect(browser))

end



function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function getStringWidth(str)
   return font:getWidth( str )
end


function love.draw()
   handleMouseClickStart()
   love.graphics.clear(0.93, 0.89, 0.74)

   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
   love.graphics.setColor(1,1,1)
   love.graphics.print(tostring(love.timer.getFPS( )), 11, 11)
   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 12, 12)


   --renderMusicBar(musicBar)
   
   renderBrowser(browser)

   if lastHitNote then
      love.graphics.print(lastHitNote, 12, 120)
   end
   
   if activeSoundData then
      --renderWave(activeSoundData, 50, 100, 300, 100)
   end
  
  --renderEQ(1024 - 400, 768- 400)
  --renderADSREnvelope(400, 50, 250, 100)
end
