inspect = require "inspect"
require 'ui'
require 'editor_ui'
require 'musicBar'
require 'instrument'
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
   handleFileBrowserWheelMoved(browser, a,b)
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
       --if v.soundData then
       --   activeSoundData = v.soundData
       --end
       if v.instrument then
          instrument = v.instrument
       end
       if v.eq then
          instrument.sounds[1].eq = v.eq
       end
       if v.soundData then
          renderSoundData = v.soundData
       end
       if v.soundStartPlaying then
          playingSound = v.soundStartPlaying
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

  
   browser = fileBrowser("assets", {"oscillators"}, {"wav", "WAV"})
   
   lastClickedFile = nil
   lastHitNote = nil
   --activeSoundData = nil

   red = {0.52, 0, 0.03}

   mouseState = {
      hoveredSomething = false,
      down = false,
      lastDown = false,
      click = false,
      offset = {x=0, y=0}
   }

   --instrument = getDefaultInstrument()
   renderSoundData = nil
   playingSound = nil

   thread = love.thread.newThread( 'thread.lua' )
   thread:start(instrument )
   channel		= {};
   channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
   channel.main2audio	= love.thread.getChannel ( "main2audio" ); -- from main
   
   --print(inspect(instrument))
   

   --channel.main2audio:push( {instrument=instrument} );
   --pus
   --print(inspect(browser))

end



function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function getStringWidth(str)
   return font:getWidth( str )
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
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
   
   if instrument then
      renderADSREnvelope(instrument.sounds[1].adsr,1024 -  400, 50, 250, 100)
   end
   
   if renderSoundData then
      renderWave( renderSoundData, 1024-400, 400-30, 300, 100)
   end
   love.graphics.setColor(1,1,1)
   if playingSound then
      if playingSound.sound:isPlaying() then
         local t = 0

         if (playingSound.loopParts) then
         local dur = round(playingSound.sound:getDuration(),3)
         local beginDur =  round(playingSound.loopParts.begin:getDuration(),3)
         local middleDur = round(playingSound.loopParts.middle:getDuration(),3)
         local afterDur = round(playingSound.loopParts.after:getDuration(),3)
         local tell = playingSound.sound:tell()

         if beginDur == dur then
            t = tell/ playingSound.fullSound:getDuration()
         elseif middleDur == dur then
            t = (tell + beginDur)/ playingSound.fullSound:getDuration()
         elseif afterDur == dur then
            t = (tell + beginDur + middleDur)/ playingSound.fullSound:getDuration()

         else
            -- here a few things could be happening
            -- multiple middel parts are queued
            -- middle and after is queed
            t = 0
         end
         
         else
         if playingSound.fullSound then  
            t = playingSound.sound:tell()/ playingSound.fullSound:getDuration()
         else
             t = playingSound.sound:tell()/ playingSound.sound:getDuration()
         end
            
         
         end
         local x = 1024-400 + t*(300)
         love.graphics.line(x, 400-30-50, x, 400-30+100-50 )
      end
   end

   if (instrument) then
      renderEQ(instrument.sounds[1].eq, 1024 - 400, 768- 250)
   end
   
   love.graphics.setColor(red[1],red[2],red[3])
   love.graphics.setLineWidth(3)

   

   if (instrument) then
      renderInstrumentSettings(instrument)
   end
end
