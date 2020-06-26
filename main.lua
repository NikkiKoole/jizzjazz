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
   handleWavLoopZoom(a,b, instruments[1].sounds[1].sample)


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

   local v = channel.audio2main:pop()
   while (v)
   do 
      if v == 'quit' then
         love.event.quit()
      end
      if v.activeSources then
         activeSources = v.activeSources
      end
      if v.notes then
         notes = v.notes
      end
      if v.beatAndBar then
         beatAndBar = v.beatAndBar
      end
      
      if v.timeData then
         timeData = v.timeData
      end
      if v.tick then
         lastTick = v.tick
         if v.tick == 1 then
         end
      end
      
      if v.playSemitone then
         local names = {'C-', 'C#', 'D-', 'D#', 'E-', 'F-', 'F#', 'G-', 'G#', 'A-', 'A#', 'B-'}
         local number = math.floor(v.playSemitone / 12)
         lastHitNote =  names[(v.playSemitone % 12)+1]..number
         lastHitSemitone = v.playSemitone
      end
      if v.instruments then
         instruments = v.instruments
      end
      
      if v.instrument then
         if not instruments then
            instruments = {}
         end
         
         instruments[1] = v.instrument
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

      v = channel.audio2main:pop()
      
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

   if showSettingsForInstrumentIndex > 0 then
      if handleBrowserClick(browser, x,y) then
         browser = fileBrowser(browser.root, browser.subdirs,
                               browser.allowedExtensions,
                               browser.kind)
      end
   end
   
   if lastDraggedElement then
      if lastDraggedElement.id == 'startPos' or lastDraggedElement.id == 'endPos' then
         channel.main2audio:push( {instrumentStartEnd=instrument} );
      end
      
   end
   

   
   lastDraggedElement = nil
end


function love.mousemoved(x,y,dx,dy)
  
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
      loop2 = love.graphics.newImage("resources/icons/loop2.png"),
      record = love.graphics.newImage("resources/icons/record.png"),
      rewind = love.graphics.newImage("resources/icons/rewind.png"),
      stop = love.graphics.newImage("resources/icons/stop.png"),
      metronome = love.graphics.newImage("resources/icons/metronome.png"),
      waveform = love.graphics.newImage("resources/icons/waveform.png"),
      volumeMute = love.graphics.newImage("resources/icons/volume_mute.png"),
      volumeUp = love.graphics.newImage("resources/icons/volume_up.png"),
      equalizer = love.graphics.newImage("resources/icons/equalizer.png"),
      settings = love.graphics.newImage("resources/icons/settings.png"),
      eraser = love.graphics.newImage("resources/icons/eraser.png"),
      save = love.graphics.newImage("resources/icons/save.png"),
      preroll = love.graphics.newImage("resources/icons/preroll.png"),
      grid = love.graphics.newImage("resources/icons/grid.png")
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

   thread:start()
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
   
 
   beatAndBar = {bar=1, beat=1}
   
   timeData = {tempo=100,
               signatureBeatPerBar=4,
               signatureUnit=4,}
   isPlaying = false
   isRecording = false

   channel.main2audio:push( {timeData=timeData} );
   channel.main2audio:push( {beatAndBar=beatAndBar} );

   preroll = false
   metronomeOn = false   
   topBarHeight = 96
   margin = 32
   instrWidth = 240
   canvasScale = .25
   canvasX = instrWidth + margin
   canvasY = topBarHeight + margin
   canvasWidth = 144 -- will be overrtiiten inloop
   canvasHeight = 80
   drumPartCanvasHeight = 32
   lastTick = 0
   instruments = {}

   activeChannelIndex = 1

   showSettingsForInstrumentIndex = 0
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



 function renderPianoRollNotes()
      love.graphics.setColor(0.5,0.5,0.5)
      local startKey = 36 -- this is a C4
      local octaves = 5
      local amount = (12 * octaves)-1

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
   


function HSL(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h, s, l = h/256*6, s/255, l/255
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m,r,g,b = (l-.5*c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m),(g+m),(b+m),a
end

local function rgbToHsl(r, g, b)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local b = max + min
    local h = b / 2
    if max == min then return 0, 0, h end
    local s, l = h, h
    local d = max - min
    s = l > .5 and d / (2 - b) or d / b
    if max == r then h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    return h * .16667, s, l
end


function love.filedropped(file)
   local filename = file:getFilename()
   if stringEndsWith(filename, '.notes') then

      local str = file:read('string')
      local tab = (loadstring("return ".. str)())

      for i =1, #tab do
         --print(tab[i].path)
         notes[i] = tab[i].notes
         
      end
      channel.main2audio:push ( {notes=notes} )
      --print(inspect(tab))
   end
   
end


function love.draw()
   love.graphics.setFont(font)
   local screenW, screenH = love.graphics.getDimensions()
   canvasWidth = screenW - instrWidth - margin*2
   handleMouseClickStart()
   love.graphics.clear(0.93, 0.89, 0.74)

   if isPlaying and isRecording then
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle("fill",0,0,screenW, 64)
   end
   

   
   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 10, 10)
   love.graphics.setColor(1,1,1)
   love.graphics.print(tostring(love.timer.getFPS( )), 11, 11)
   love.graphics.setColor(0.2, 0.2, 0.2)
   love.graphics.print(tostring(love.timer.getFPS( )), 12, 12)

   if activeSources then
      love.graphics.print(#activeSources, 150, 12)
   end
   --renderMusicBar(musicBar)

   if lastHitNote then
      love.graphics.print(lastHitNote, 50, 10)
   end
   if lastHitSemitone then
      love.graphics.print(lastHitSemitone, 100, 10)
   end
   


   
  

   local save = imgbutton('save', ui.save, screenW-margin - 42 , 10  , 42, 42)
   if save.clicked then
      local channels = {}
      for i = 1, #instruments do
         local thing = {}
         thing.path = instruments[i].path
         thing.notes = notes[i]
         channels[i] = thing
      end
      love.filesystem.write(os.date("%Y%m%d%H%M%S.notes"), inspect(channels, {indent=""}))
      love.system.openURL("file://"..love.filesystem.getSaveDirectory())
      
     
   end


   -- try and make this thing exactly 2 bars wide
   --print(canvasScale)
   -- timeData.signatureBeatPerBar
   -- timeData.signatureUnit

   local ticksPerUnit = 96 / (timeData.signatureUnit/4)
   local tickPerBar = timeData.signatureBeatPerBar * ticksPerUnit
   local loopWidth = 4 * tickPerBar * canvasScale

   if isLooping then
      love.graphics.setColor(207/255,117/255,0/255)
   else
      love.graphics.setColor(0.2, 0.2, 0.2, 0.2)
   end
   
   love.graphics.rectangle("fill", margin+instrWidth, margin+topBarHeight-32, loopWidth, 24)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle("line", margin+instrWidth, margin+topBarHeight-32, loopWidth, 24)

   local loopclick =  getUIRect( 'loopclick', margin+instrWidth, margin+topBarHeight-32, loopWidth, 24)
   if loopclick.clicked then
      isLooping = not isLooping
      channel.main2audio:push ( {isLooping=isLooping} )
   end
   
   -- renderVerticalPianoRoll(canvasX-30, canvasY, 30)
   -- renderPianoRollNotes()

   
   function renderInstruments()
      local hues = {0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330}

--      print(canvasHeight * #instruments, screenH - canvasY)
      local myHeight = canvasHeight
      
      local runningY =  canvasY
      
      for i = 1, #instruments do
         if instruments[i].isDrumKitPart then
            myHeight = drumPartCanvasHeight
         end
         
         
         local index = i % 12 + 1 --math.floor(((lastTick/100) % #hues)+1)
         local hue = hues[index]
         local r,g,b =  HSL(hue, 25, 75, 1)
         local active = activeChannelIndex == i
         if active then
            r,g,b =  HSL(hue, 100, 150, 1)
         end

         
         local label =  getUIRect( 'signat'..i, margin, runningY, instrWidth, myHeight)
         if label.clicked then
            activeChannelIndex = i
            channel.main2audio:push ( {activeChannelIndex=i} )
         end
         
         if active then
            love.graphics.setColor(r,g,b)
            love.graphics.rectangle('fill',canvasX,   runningY, canvasWidth, myHeight)
         end
         
         
         renderMeasureBarsInSomeRect(canvasX, runningY, canvasWidth, myHeight, canvasScale)
         --      print(inspect(notes[i]))
         if notes[i] then
            for k,v in pairs(notes[i]) do
               for t,vv in pairs(v) do
                  --if not vv.stop then
                  local x = canvasX + (k*canvasScale)
                  
                  --local y = canvasY + amount*10   - (vv.key-startKey)*10
                  local y = mapInto(vv.key, 0, 144, 0, myHeight) --runningY
                  y = runningY + myHeight - y
                     --canvasY + (i-1)*myHeight + myHeight - vv.key
                  local w = vv.length * canvasScale
                  local h = canvasScale * 8
                  love.graphics.rectangle("fill", x,y,w,h)
                  --end
               end
            end
         end
         
         
         
         renderPlayHead(canvasX, runningY, canvasWidth, myHeight, lastTick or 0, canvasScale)
         if activeChannelIndex == i then
            local eraser = imgbutton('erase', ui.eraser, screenW-margin-42 ,runningY, 42, 42)
            if eraser.clicked then
               notes[activeChannelIndex] ={}
               channel.main2audio:push ( {notes=notes} )
            end
         end
         
         
         
         love.graphics.setColor(r, g, b)
         love.graphics.rectangle("fill", margin , runningY, instrWidth, myHeight)
         
         
         love.graphics.setLineWidth(4)
         love.graphics.setColor(0,0,0)
         love.graphics.rectangle("line", margin , runningY, instrWidth, myHeight)
         
         
         --local name = getInstrumentName(instruments[i].sounds[1].sample.path)
         local name = instruments[i].path or getInstrumentName(instruments[i].sounds[1].sample.path)
         local nameWidth = getStringWidth(name)
         renderLabel(name, margin + instrWidth/2 - nameWidth/2, runningY + myHeight/2 - 10,
                     margin+ 10, active and 1.0 or 0.25)
         
         if active then
            local settings = imgbutton('settings'..i,
                                       ui.settings, margin + instrWidth/4,
                                       runningY + myHeight/3,
                                       32, 32,active and {1,1,1,1} or {1,1,1,0.25})
            if settings.clicked then

               if (showSettingsForInstrumentIndex == i) then
                  showSettingsForInstrumentIndex = 0
               else
                  activeChannelIndex = i
                  channel.main2audio:push ( {activeChannelIndex=i} )
                  showSettingsForInstrumentIndex = i 
               end
            end
            
            imgbutton('volume'..i,
                      ui.volumeUp,margin + (instrWidth/4)*2.5 ,
                      runningY + myHeight/3,
                      42, 42,active and {1,1,1,1} or {1,1,1,0.25})

            if instruments[i].isDrumKit then
               local drumbuttonY = topBarHeight + margin + (i-1)*myHeight
               imgbutton("drumpattern"..i,ui.grid, margin, drumbuttonY, 42,42 )
            end
         end

         runningY = runningY + myHeight
      end



     
   end

   renderInstruments()
   
   function drawDrumGrid()

   --[[
      
      Bass Drum sounds start with "BD".
      Snare Drum sounds start with "SD".
      Low Tom sounds start with "LT".
      Mid Tom sounds start with "MT".
      Hi Tom sounds start with "HT".
      Low Conga sounds start with "LC".
      Mid Conga sounds start with "MC".
      Hi Conga sounds start with "HC".
      Rim Shot sound starts with "RS".
      Claves sounds starts with "CL".
      Hand Clap sound starts with "CP".
      Maracas sound starts with "MA".
      Cowbell sound starts with "CB".
      Cymbal sounds start with "CY".
      Open Hi Hat sounds start with "OH".
      Closed Hi Hat sound starts with "CH".
   ]]--

   
   
   local fullCanvasScale = (canvasWidth / tickPerBar)

   local drumX = margin + instrWidth
   local drumY = margin + topBarHeight
   local drumWidth = tickPerBar * fullCanvasScale
   
   local drumAmount = 16
   local scaledHeight = math.min((drumWidth/drumAmount), 48)
   local scaledWidth = scaledHeight * (2/3)
   local names = {
      "Bass Drum BD",
      "Snare Drum SD",
      "Low Tom LT",
      "Mid Tom MT",
      "Hi Tom HT",
      "Low Conga LC",
      "Mid Conga MC",
      "Hi Conga HC",
      "Rim Shot RS",
      "Claves CL",
      "Hand Clap CP",
      "Maracas MA",
      "Cowbell CB",
      "Cymbal CY",
      "Open Hihat OH",
      "Closed Hihat CH",
   }


   --love.graphics.setColor(0.93, 0.89, 0.74)
   love.graphics.setColor(0.3,0.3,0.3)

   love.graphics.rectangle("fill",drumX-200 , drumY ,200+ scaledWidth*drumAmount, scaledHeight * #names)

   
   for i=1, #names do
      local nameWidth = getStringWidth(names[i])
      local r,g,b =  HSL(100, 25, 75, 1)
      love.graphics.setColor(r,g,b)
      love.graphics.rectangle("fill", margin + instrWidth - 200,
                              margin + topBarHeight + (i-1)*scaledHeight ,
                              200, scaledHeight)
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("line", margin + instrWidth - 200,
                              margin + topBarHeight + (i-1)*scaledHeight ,
                              200, scaledHeight)
      
      renderLabel(names[i],
                  margin + instrWidth - nameWidth,
                  margin + topBarHeight + (i-1)*scaledHeight + 12) 
   end
   

   
 

   
   --love.graphics.setColor(0,0,0)
   love.graphics.setColor(0.93, 0.89, 0.74)
   for j = 1, #names do
      for i = 1, drumAmount do
         love.graphics.rectangle("fill",
                                 2+ drumX + (i-1) *scaledWidth,
                                 2+ drumY + (j-1)*scaledHeight,
                                 scaledWidth-4, scaledHeight -4)

      end
   end

   
   for i = 1, drumAmount do
      if math.ceil(i / 4) % 2 == 1 then
         love.graphics.setColor(0,0,0,0.2)
      else
         love.graphics.setColor(0,0,0,0.3)

      end
      
      love.graphics.rectangle("fill",
                              drumX + (i-1) *scaledWidth,
                              drumY, scaledWidth, scaledHeight *  #names)
   end
   
   end

  -- drawDrumGrid()
  
   
   --print(tickPerBar, canvasScale)

    
   tapedeckButtons()
   

   love.graphics.setFont(fontLarge)

   local beatString = string.format("%02d", beatAndBar.bar).."."..string.format("%02d", beatAndBar.beat)
   --()
   local ww = fontLarge:getWidth(beatString)
   love.graphics.setColor(0,0,0, .75)
   love.graphics.rectangle('fill', 460 - 10, 10, ww + 20, 48)
   love.graphics.setColor(1,1,1)
   love.graphics.print(beatString, 460, 10-5)

   
   local met = imgbutton('metronome', ui.metronome, 640, 10, 24, 24, metronomeOn and {1,0,0} or {1,1,1} )
   if met.clicked then
      metronomeOn = not metronomeOn
      channel.main2audio:push ( {metronomeOn=metronomeOn} )

   end
   local met = imgbutton('preorll', ui.preroll, 640, 40, 24, 24, preroll and {1,0,0} or {1,1,1})
   if met.clicked then
      preroll = not preroll
      channel.main2audio:push ( {preroll=preroll} )

   end
   
  
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
      drawTempoUI(900+20,10, timeData)
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
         local ticksPerUnit = 96 / (timeData.signatureUnit/4)
         local newBeat = lastTick / ticksPerUnit
         newBeat = math.ceil(newBeat)
         local newBar = math.ceil(lastTick / (ticksPerUnit * timeData.signatureBeatPerBar))
         
         beatAndBar.beat = newBeat %  timeData.signatureBeatPerBar
         beatAndBar.bar = newBar
         channel.main2audio:push ( {timeData=timeData} )
         channel.main2audio:push ( {beatAndBar=beatAndBar} )
         
      end
   end
   love.graphics.setColor(0,0,0)
   

   
   if showSettingsForInstrumentIndex > 0 then

      local hues = {0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330}
      local r,g,b =  HSL(hues[1 + showSettingsForInstrumentIndex], 100, 150, 1)
      love.graphics.setLineWidth(3)
      love.graphics.setColor(r,g,b)

      local tlx = margin + instrWidth
      local tly = screenH/2 - (450-margin)/2
      local w = screenW - instrWidth - margin*2
      local h =  450-margin
      love.graphics.rectangle('fill',tlx,tly,w, h)
      
      
      renderBrowser(browser, tlx, tly, instrWidth, 425)

      
      renderADSREnvelope(instruments[showSettingsForInstrumentIndex].sounds[1].adsr, screenW - 250 - margin, tly+ 50, 250, 100)
      

      love.graphics.setColor(red[1],red[2],red[3])
      

      renderEQ(instruments[showSettingsForInstrumentIndex].sounds[1].eq, tlx + instrWidth + 40, tly + 70)


      if renderSoundData then
         renderWave( renderSoundData, tlx + instrWidth + 50, tly+h-50 -margin, 300, 100)
      end
      if playingSound then
         renderPlayingSoundBar( canvasX + margin, screenH - 100, 300, 100)
      end

      love.graphics.setColor(red[1],red[2],red[3])
      
      renderInstrumentSettings(instruments[showSettingsForInstrumentIndex], tlx + instrWidth  + 400, tly + 60)

      if renderSoundData then
         renderLabel('fade out', canvasX + margin + 300 +200, screenH - 100)
         knob = h_slider('fade out', canvasX + margin + 300, screenH - 100, 200, instruments[showSettingsForInstrumentIndex].sounds[1].eq.fadeout or 0, 0.0, renderSoundData:getDuration()-0.001 )
         if knob.value ~= nil then
            instruments[showSettingsForInstrumentIndex].sounds[1].eq.fadeout = knob.value
            channel.main2audio:push ( {eq = instruments[1].sounds[1].eq} )
         end

         renderLabel('fade in', canvasX + margin + 300 + 200, screenH - 150)
         knob = h_slider('fade in', canvasX + margin + 300, screenH - 150, 200, instruments[showSettingsForInstrumentIndex].sounds[1].eq.fadein or 0, 0.0, renderSoundData:getDuration()-0.001 )
         if knob.value ~= nil then
            instruments[showSettingsForInstrumentIndex].sounds[1].eq.fadein = knob.value
            channel.main2audio:push ( {eq = instruments[1].sounds[1].eq} )
         end
      end
   end
   
   
  
   

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


   -- function renderPianoRollNotes()
      -- love.graphics.setColor(0.5,0.5,0.5)
      -- local startKey = 36 -- this is a C4
      -- local octaves = 5
      -- local amount = (12 * octaves)-1

      -- for k,v in pairs(notes) do
      --    for t,vv in pairs(v) do
      --       if not vv.stop then
      --          local x = canvasX + (k*canvasScale)
               
      --          local y = canvasY + amount*10   - (vv.key-startKey)*10
      --          local w = vv.length * canvasScale
      --          local h = 10
      --          love.graphics.rectangle("fill", x,y,w,h)
      --       end
      --    end
      -- end
      -- end
