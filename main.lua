inspect = require "inspect"
require 'ui'
require 'editor_ui'
require 'musicBar'
require 'instrument'
require 'fileBrowser'
local thread -- Our thread object.

function findLast(haystack, needle)
   local i=haystack:match(".*"..needle.."()")
   if i==nil then return nil else return i-1 end
end
 function isInTable(value, tab)
      for i,v in pairs(tab) do
         if value == v then return true end
      end
      return false
   end

function love.keypressed(key)
   if key == 'escape' then
      channel.main2audio:push ( "quit" );
   end
   if key == 'space' then
      isPlaying = not isPlaying
      channel.main2audio:push ( {isPlaying=isPlaying} )
   end
   if key == 'p' then
      --pasteNoteNowUsingLastPressed()
   end
   
   
   if  lpUI.enabed and instrument then
      local down = love.keyboard.isDown( 'lshift' )
      local multiplier = 1
      local changedLoopPoints = false
      if down then multiplier = 10 end

      local ls = instrument.sounds[1].sample.loopStart
      local le = instrument.sounds[1].sample.loopEnd

      if ls and le then
      if key =='z' then
         instrument.sounds[1].sample.loopStart = ls - multiplier
         changedLoopPoints = true
      end
      if key =='x' then
         instrument.sounds[1].sample.loopStart = ls + multiplier
         changedLoopPoints = true
      end

      if key =='n' then
         instrument.sounds[1].sample.loopEnd = le - multiplier
         changedLoopPoints = true
      end
      if key =='m' then
         instrument.sounds[1].sample.loopEnd = le + multiplier
         changedLoopPoints = true
      end
     
      if instrument.sounds[1].sample.loopStart > instrument.sounds[1].sample.loopEnd then
          instrument.sounds[1].sample.loopStart = instrument.sounds[1].sample.loopEnd
      end
      if instrument.sounds[1].sample.loopEnd <= instrument.sounds[1].sample.loopStart then
           instrument.sounds[1].sample.loopEnd = instrument.sounds[1].sample.loopStart+1
      end
      if instrument.sounds[1].sample.loopStart < 1 then
           instrument.sounds[1].sample.loopStart = 1
      end
     
      if instrument.sounds[1].sample.loopEnd > instrument.sounds[1].sample.soundData:getSampleCount()-1 then
           instrument.sounds[1].sample.loopEnd = instrument.sounds[1].sample.soundData:getSampleCount()-1
      end
       
      if changedLoopPoints then
         channel.main2audio:push( {instrumentStartEnd=instrument} );
      end

      end
      
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
   --handleMusicBarWheelMoved(musicBar, a,b)
   handleFileBrowserWheelMoved(browser, a,b)
   handleWavLoopZoom(a,b, instrument.sounds[1].sample)


   local mx, my = love.mouse:getPosition()
   if mx > canvasX and mx < canvasX+canvasWidth then
      if my > canvasY and my < canvasY+canvasHeight then
         if b > 0 then
            canvasScale = canvasScale * 2.0
         else
            canvasScale = canvasScale * 0.5
         end
         if canvasScale < 0.03125 then
            canvasScale = 0.03125
         end
      end
      
   end
end


function love.update(dt)
   local error = thread:getError()
   assert( not error, error )
   local v = channel.audio2main:pop ()
   if v then
      if v == 'quit' then
         love.event.quit()
      end
      if v.activeSources then
         activeSources = v.activeSources
         --print('active sources:', #v.activeSources)
      end
      if v.notes then
         notes = v.notes
      end
      
      if v.timeData then
         timeData = v.timeData
      end
      if v.tick then
         lastTick = v.tick
         if v.tick == 1 then
            --print('tick', v.tick)

         end
         
      end
      
      
      if v.playSemitone then
         local names = {'C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-'}
         local number = math.floor(v.playSemitone / 12)
         lastHitNote =  names[(v.playSemitone % 12)+1]..number
         lastHitSemitone = v.playSemitone
         --pasteNoteNowUsingLastPressed()
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
   --handleMusicBarClicked(musicBar,x,y)
end

function stringEndsWith(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end




function round(num, numDecimalPlaces)
   local mult = 10^(numDecimalPlaces or 0)
   return math.floor(num * mult + 0.5) / mult
end

function love.mousereleased(x,y)
   --handleMusicBarMouseReleased(musicBar,x,y)
   
   dragging = false
   love.mouse.setCursor(cursors.arrow)

   if handleBrowserClick(browser, x,y) then
      browser = fileBrowser(browser.root, browser.subdirs,
                                browser.allowedExtensions,
                                browser.kind)
   end

   --if handleBrowserClick(instrumentBrowser, x,y) then
      -- instrumentBrowser = fileBrowser(browser.root, browser.subdirs,
      --                           browser.allowedExtensions,
      --                           browser.kind)
   --end
   
   --print(inspect(instrumentBrowser), 'poep!')
   --instrumentBrowser = handleBrowserClick(instrumentBrowser, x,y)
   if lastDraggedElement then
      if lastDraggedElement.id == 'startPos' or lastDraggedElement.id == 'endPos' then
         channel.main2audio:push( {instrumentStartEnd=instrument} );
      end
      
   end
   

   
   lastDraggedElement = nil
end


function love.mousemoved(x,y,dx,dy)
   --print(inspect(musicBar.dict))
   
   --handleMusicBarMouseMoved(musicBar, x,y,dx,dy)
end


function love.load()
   
   
   
   --love.window.setMode(1024, 768)
   cursors = {hand=love.mouse.getSystemCursor("hand"),
              arrow=love.mouse.getSystemCursor("arrow"),
              sizewe = love.mouse.getSystemCursor("sizewe")}
   dragging = false
   fontLarge = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 48)
   fontMiddle = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 32)
   font = love.graphics.newFont( "resources/fonts/WindsorBT-Roman.otf", 16)
   --font = love.graphics.newFont( "resources/fonts/Impact Label.ttf", 15)
   love.graphics.setFont(font)

    ui = {
      back = love.graphics.newImage("resources/icons/back.png"),
      play = love.graphics.newImage("resources/icons/play.png"),
      pause = love.graphics.newImage("resources/icons/pause.png"),
      loop = love.graphics.newImage("resources/icons/loop.png"),
      record = love.graphics.newImage("resources/icons/record.png"),
      rewind = love.graphics.newImage("resources/icons/rewind.png"),
      stop = love.graphics.newImage("resources/icons/stop.png"),
      metronome = love.graphics.newImage("resources/icons/metronome.png"),
      waveform = love.graphics.newImage("resources/icons/waveform.png")
    }
   
   --musicBar = createMusicBar()

   
   browser = fileBrowser("assets", {}, {"wav", "WAV", "lua"})

   --instrumentBrowser = fileBrowser("assets/instruments", {}, {"lua"}, 'instrument')

   
   lastClickedFile = nil
   lastHitNote = nil
   lastHitSemitone = nil

   --activeSoundData = nil

   red = {0.52, 0, 0.03}

   mouseState = {
      hoveredSomething = false,
      down = false,
      lastDown = false,
      click = false,
      offset = {x=0, y=0}
   }

   
   renderSoundData = nil
   playingSound = nil

   thread = love.thread.newThread( 'thread.lua' )
   thread:start(instrument )
   channel		= {};
   channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
   channel.main2audio	= love.thread.getChannel ( "main2audio" ); -- from main



   notes = {
      -- i want an index which is the lastTick can you have multiple notes starting at exact same index ?
      

   }


   lpUI = {
      enabed = true,
      x = 400,
      y = 700,
      width = 500,
      height = 300
   }
   
 

   
   timeData = {bar=1, beat=1, tempo=100,
               signatureBeatPerBar=4,
               signatureUnit=4,}
   isPlaying = false
   isRecording = false
   --print(inspect(instrument))
   

   channel.main2audio:push( {timeData=timeData} );
   --pus
   --print(inspect(browser))

   topBarHeight = 96
   margin = 32
   instrWidth = 240
   canvasScale = .25
   canvasX = instrWidth + margin
   canvasY = topBarHeight + margin
   canvasWidth = 144 -- will be overrtiiten inloop
   canvasHeight = 144
   lastTick = 0

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

function  pasteNoteNowUsingLastPressed()
   if lastTick and lastHitSemitone then
      local current = notes[lastTick]
      if current then
         table.insert(notes[lastTick], {key=lastHitSemitone, length=96, startTick=lastTick})
         --print('foundsomethign already', inspect(current))
      else
         current = {{key=lastHitSemitone, length=96, startTick=lastTick}}
         notes[lastTick] = current
      end

   else
--      print(lastTick, lastHitSemitone)
   end
end


 function renderPianoRollNotes()
      love.graphics.setColor(0.5,0.5,0.5)
      local startKey = 36 -- this is a C4
      local octaves = 5
      local amount = (12 * octaves)-1
      --print(amount)
      --print(inspect(notes))
      for k,v in pairs(notes) do
         for t,vv in pairs(v) do
            if not vv.stop then
               local x = canvasX + (k*canvasScale)
               
               local y = canvasY + amount*10   - (vv.key-startKey)*10
               local w = vv.length * canvasScale
               local h = 10
               love.graphics.rectangle("fill", x,y,w,h)
            end
         end
      end
 end

  function renderVerticalPianoRoll(startX, startY, width)
      local startKey = 36 -- this is a C4
      local octaves = 5
      local whites = {0,2,4,5,7,9,11}
      local amount = (12 * octaves)
      
      --print((12 * octaves)-1)

      love.graphics.setColor(0.2,0.2,0.2,0.2)
      love.graphics.rectangle("fill", startX+width, startY, canvasWidth, (amount+1)*10)

      
      for i=0, amount do
         local color = {0,0,0}

         if isInTable((i%12), whites) then
            color = {1,1,1}
         end

         love.graphics.setColor(0,0,0)

         local y = startY+ (amount)*10 - (i*10)
         love.graphics.rectangle("line", startX, y, width, 10)

         love.graphics.setColor(color[1], color[2], color[3])

         if activeSources then
            for j=1, #activeSources do
               if activeSources[j].key ==  i + startKey then
                  love.graphics.setColor(red[1], red[2], red[3])
                  if activeSources[j].released==true then
                     love.graphics.setColor(0.5,0.5,0.5)
                  end
               end
            end
         end
         
         love.graphics.rectangle("fill", startX, y, width, 10)
      end
      
   end
   


function love.draw()
   love.graphics.setFont(font)
   local screenW, screenH = love.graphics.getDimensions()
   canvasWidth = screenW - instrWidth - margin*2
   handleMouseClickStart()
   love.graphics.clear(0.93, 0.89, 0.74)

   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
   love.graphics.setColor(1,1,1)
   love.graphics.print(tostring(love.timer.getFPS( )), 11, 11)
   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 12, 12)


   --renderMusicBar(musicBar)

   if lastHitNote then
      love.graphics.print(lastHitNote, 50, 10)
   end
   if lastHitSemitone then
      love.graphics.print(lastHitSemitone, 100, 10)
   end
   
    renderBrowser(browser, margin, topBarHeight + margin + canvasHeight, instrWidth, screenH - (topBarHeight + 20))

    love.graphics.setLineWidth(4)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("line", margin , topBarHeight + margin, instrWidth, 144)
 
   
   renderMeasureBarsInSomeRect(canvasX, canvasY, canvasWidth, canvasHeight, canvasScale)
   -- renderPlayHead(canvasX, canvasY, canvasWidth, canvasHeight, lastTick or 0, canvasScale)
   -- renderVerticalPianoRoll(canvasX-30, canvasY, 30)
   -- renderPianoRollNotes()
   
   love.graphics.setColor(0,0,0)
   
   
   if instrument then
      --print(instrument.sounds[1].sample.path)
      local name = getInstrumentName(instrument.sounds[1].sample.path)
      renderLabel(name, margin,  topBarHeight + margin)

      
      imgbutton('waveform', ui.waveform, margin, topBarHeight + margin+ 30, 48, 48)
      
   end
   
   tapedeckButtons()
   

   love.graphics.setFont(fontLarge)

   local beatString = string.format("%02d", timeData.bar).."."..string.format("%02d", timeData.beat)
   --()
   local ww = fontLarge:getWidth(beatString)
   love.graphics.setColor(0,0,0, .75)
   love.graphics.rectangle('fill', 460 - 10, 10, ww + 20, 48)
   love.graphics.setColor(1,1,1)
   love.graphics.print(beatString, 460, 10-5)

   imgbutton('metronome', ui.metronome, 800, 10, 24, 24)
   
  
   love.graphics.setLineWidth(3)
   love.graphics.setFont(fontMiddle)
   love.graphics.setColor(0,0,0)
   love.graphics.print(timeData.signatureBeatPerBar, 740 - fontMiddle:getWidth(timeData.signatureBeatPerBar), 5)
   love.graphics.print(timeData.signatureUnit, 740, 30)
   --love.graphics.rectangle('line', 710, 10, 64, 54)
   love.graphics.line(740+20, 15, 740-20, 64)

   
   love.graphics.print(math.floor(timeData.tempo), 900, 20)
   local bpm =  getUIRect( 'bpm_flip',900, 20, 64, 32)
   if bpm.clicked then
      showBPM = not showBPM
   end
   if showBPM then
      drawTempoUI(900,10, timeData)
   end
   
   
   --love.graphics.rectangle('line', 900, 20, 64, 32)
   local signature =  getUIRect( 'signature', 710, 10, 64, 54)
   if signature.clicked then
      showSignatureUI = not showSignatureUI
      
   end

   
   

   love.graphics.setFont(font)
   if showSignatureUI then
      local changed = drawBeatSignatureUI(710,10, 64, 54, timeData)
      
      if changed then
         -- the signature has changed
         -- bar and beat need recalculating
         --print(lastTick)
         local ticksPerUnit = 96 / (timeData.signatureUnit/4)
         local newBeat = lastTick / ticksPerUnit
         newBeat = math.ceil(newBeat)
         local newBar = math.ceil(lastTick / (ticksPerUnit * timeData.signatureBeatPerBar))
         
         timeData.beat = newBeat %  timeData.signatureBeatPerBar
         timeData.bar = newBar
         channel.main2audio:push ( {timeData=timeData} )
      end
      
   end
   love.graphics.setColor(0,0,0)
   
  
   
   --draw_label_button(200,15, 'play')
   
   --renderBrowser(instrumentBrowser, 40, 200)
   
   if renderSoundData then
       renderWave( renderSoundData, 660, screenH - (20 * 20) - 20 + 50, 300, 100)
    end
   
   if playingSound then
       renderPlayingSoundBar( 660, screenH - (20 * 20) - 20 +50, 300, 100)
    end
   
   if instrument then
      renderADSREnvelope(instrument.sounds[1].adsr, screenW - 250 - 20, screenH - (20 * 20), 250, 100)
   end

   love.graphics.setColor(red[1],red[2],red[3])
   love.graphics.setLineWidth(3)
   if (instrument) then
       renderEQ(instrument.sounds[1].eq, 240 +  40, screenH - (20 * 20))
    end

   -- if (instrument) then
   --    renderLabel('fade out', 280, 750)
   --    knob = h_slider('fade out', 280 + 100, 750, 200, instrument.sounds[1].eq.fadeout or 0, 0.0, renderSoundData:getDuration()-0.001 )
   --    if knob.value ~= nil then
   --       instrument.sounds[1].eq.fadeout = knob.value
   --       channel.main2audio:push ( {eq = instrument.sounds[1].eq} )
   --    end

   --    renderLabel('fade in', 280, 800)
   --    knob = h_slider('fade in', 280 + 100, 800, 200, instrument.sounds[1].eq.fadein or 0, 0.0, renderSoundData:getDuration()-0.001 )
   --    if knob.value ~= nil then
   --       instrument.sounds[1].eq.fadein = knob.value
   --       channel.main2audio:push ( {eq = instrument.sounds[1].eq} )
   --    end
   -- end
   
   -- love.graphics.setColor(red[1],red[2],red[3])
   -- love.graphics.setLineWidth(3)

   if (instrument) then
       renderInstrumentSettings(instrument, 660, 630)
    end


   -- now trya n make the simple sequencer
   
  
   -- renderLabel('bass drum', xOffset - getStringWidth('bass drum') + 20, 80+24)
   -- renderLabel('mid conga', xOffset - getStringWidth('mid conga') + 20, 80+24+32)
   -- --    getStringWidth(str)+10

   -- love.graphics.setColor(0.2, 0.2, 0.2)
   -- for i = 1, 16 do
   --    local str = i 
   --    local strW = getStringWidth(str)
   --    love.graphics.print(str, xOffset + i*32  + (32-strW)/2, 80)
   --    love.graphics.rectangle('line', xOffset + i*32, 100, 32,32)
   -- end
   -- for i = 17, 32 do
   --    local str = i - 16
   --    local strW = getStringWidth(str)
   --    love.graphics.print(str,xOffset + margin+ i*32  + (32-strW)/2, 80)
   --    love.graphics.rectangle('line',xOffset + margin + i*32, 100, 32,32)
   -- end

   -- local xOffset = 300
   -- local margin = 16
   -- local names = {'Rhodes', 'Flute', 'Synth', 'Guitar', 'CR78'}
   -- for i = 1, 5 do
   --    love.graphics.setColor(1.0, 147/255, 95/255)
   --    love.graphics.rectangle('fill',xOffset, margin+(i-1)*150, 144,144)
   --    renderLabel(names[i], xOffset+ 20 , margin+(i-1)*150 + 20)
      
   --    love.graphics.setColor(222/255, 147/255, 95/255)
   --    love.graphics.rectangle('fill',xOffset+144, margin+(i-1)*150, screenW-xOffset-margin-144,144)
   -- end
   -- love.graphics.setColor(1,1,1)
   -- for i = 1,#testNotes do
   --    local n = testNotes[i]
   --    love.graphics.rectangle('fill',xOffset + n.x, 300 + (144*2) - (n.key*2), n.length, 2)

   -- end
   
   
   --love.graphics.setColor(0.2, 0.2, 0.2)
   --love.graphics.rectangle('line',xOffset, 300, screenW-xOffset-margin,144)
   --if instrument then
   --   print(inspect( instrument.sounds[1]))
   --end


   if instrument then
      
      local s = instrument.sounds[1].sample
      if s.loopStart and s.loopEnd then
         love.graphics.setLineWidth(1)

         renderWave(s.soundData,  lpUI.x, lpUI.y, 500, 300, s.loopStart, s.loopEnd)
         renderWaveLoopConnection(s.soundData, lpUI.x, lpUI.y, 500, 300*2, s.loopStart, s.loopEnd )
         renderLabel("start", lpUI.x-50 , lpUI.y - lpUI.height/2 - 70)
         renderLabel(math.floor(instrument.sounds[1].sample.loopStart), lpUI.x+lpUI.width , lpUI.y - lpUI.height/2 - 70)
         local sp = h_slider('startPos', lpUI.x , lpUI.y - lpUI.height/2 - 60, 500, s.loopStart, 1, s.soundData:getSampleCount( ))
         if sp.value then
            instrument.sounds[1].sample.loopStart = sp.value
            if instrument.sounds[1].sample.loopStart >= instrument.sounds[1].sample.loopEnd then
               instrument.sounds[1].sample.loopStart = instrument.sounds[1].sample.loopEnd-1
            end
         end
         renderLabel("end", lpUI.x-50 , lpUI.y - lpUI.height/2 - 40)
          renderLabel(math.floor(instrument.sounds[1].sample.loopEnd), lpUI.x+lpUI.width , lpUI.y - lpUI.height/2 - 40)
         local ep = h_slider('endPos', lpUI.x , lpUI.y - lpUI.height/2 - 40, 500, s.loopEnd, 0, s.soundData:getSampleCount( )-1)
         
         if ep.value then
            instrument.sounds[1].sample.loopEnd = ep.value
            if instrument.sounds[1].sample.loopEnd <= instrument.sounds[1].sample.loopStart then
               instrument.sounds[1].sample.loopEnd = instrument.sounds[1].sample.loopStart+1
            end
         end
         
      end
   end
end

function handleWavLoopZoom(dx, dy, sample)
   if instrument then
      local s = sample
      if s.loopStart and s.loopEnd then 
         local x, y = love.mouse.getPosition( )
         local count = s.soundData:getSampleCount( )

         if x > lpUI.x  and x < lpUI.x + lpUI.width then
            if y > lpUI.y - lpUI.height/2 and y <  lpUI.y + lpUI.height/2 then

               local rangeNow = (s.loopEnd - s.loopStart)
               local sample1 = mapInto(x, lpUI.x, lpUI.x + lpUI.width,  s.loopStart,  s.loopEnd)
               local rangeAfter = nil
               if (dy > 0) then -- zoom in
                  rangeAfter = math.floor(rangeNow * 0.9)
               end
               if (dy < 0) then -- zoom in
                  rangeAfter = math.floor(rangeNow * 1.1)
               end
               local rangeDiff = rangeNow - rangeAfter
               sample.loopStart = s.loopStart + rangeDiff/2
               sample.loopEnd = s.loopEnd - rangeDiff/2
               local sample2 = mapInto(x, lpUI.x, lpUI.x + lpUI.width,  sample.loopStart, sample.loopEnd)
               local sampleDiff = sample2 - sample1
               sample.loopStart = sample.loopStart - sampleDiff
               sample.loopEnd = sample.loopEnd - sampleDiff

               if sample.loopStart < 0 then
                  sample.loopStart = 0
               end
               if sample.loopEnd > count-1 then
                  sample.loopEnd = count-1
               end
               
            end
         end
      end
   end
   
end




function renderWaveLoopConnection(data, xOff, yOff, width, height, startPos, endPos)
   local count = data:getSampleCount( )
   -- first draw the last 5 samples
   love.graphics.setColor(1,0,0,0.5)
   local lw = 4
   love.graphics.setLineWidth(lw)

   local range = 10
   for i = 0, range do
      local pos = endPos - range + i

      if (pos >= 0 and pos <= count) then
         local s = data:getSample(pos)
         love.graphics.line(xOff+ width+20 +i* lw, yOff+((s * (height))), xOff+ width + 20 + i*lw, yOff)
      end
   end
   love.graphics.setColor(0,1,0,0.5)
   for i = 0, range do
      local pos = startPos + i
      if (pos >= 0 and pos < count) then
         local s = data:getSample(pos)
         love.graphics.line(xOff+ width + 20 + (lw*range) + (i+1)*lw, yOff+((s * (height))), xOff+ width+20 + (lw*range) + (i+1)*lw, yOff)
      end
   end
   data:getSample(0)
   data:getSample(count-1)
   
end



function renderPlayingSoundBar(x,y, width, height)
   love.graphics.setColor(1,1,1)
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
            -- multiple middle parts are queued
            -- middle and after is queued
            t = 0
            tell = tell % middleDur
            t = (tell + beginDur)/ playingSound.fullSound:getDuration()
         end
         
      else
         if playingSound.fullSound then  
            t = playingSound.sound:tell()/ playingSound.fullSound:getDuration()
         else
            t = playingSound.sound:tell()/ playingSound.sound:getDuration()
         end
         
         
      end
      local x2 = x + t*(width)

      love.graphics.line(x2, y-(height/2), x2, y+(height/2) )
   end

end
