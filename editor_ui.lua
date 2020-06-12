 function getInstrumentName(path)
      local str = path
      local index = findLast(str, "/")+1
      local name = string.sub(str, index)
      name = string.gsub(name, ".wav", "")
      name = string.gsub(name, ".WAV", "")
      name = string.gsub(name, ".lua", "")
      return name
   end
   function tapedeckButtons()
      local back = imgbutton('back', ui.back, 200, 10, 48, 48)
      if back.clicked then
         lastTick = 0
         timeData.bar = 1
         timeData.beat = 1
         channel.main2audio:push ( {stepBackTime=timeData} )
         channel.main2audio:push ( {timeData=timeData} )
      end
      
      local play = imgbutton('play',not isPlaying and ui.play or ui.stop, 200+54, 10, 48, 48)
      if play.clicked then
         isPlaying = not isPlaying
         channel.main2audio:push ( {isPlaying=isPlaying} )
      end
      
      imgbutton('record', ui.record, 200+108, 10, 48, 48, red)
   end

   function drawTempoUI(x,y, timeData)
      --love.graphics.print('bpm: '..math.floor(timeData.tempo), x, y)
      local bpm = v_slider('bpm', x, y+50, 310, timeData.tempo , 10, 300)
      if bpm.value ~= nil then
         timeData.tempo =  bpm.value
         channel.main2audio:push ( {tempo=math.floor(timeData.tempo)} )
      end

   end


 function drawBeatSignatureUI(x,y,w,h, timeData)
    --love.graphics.print(timeData.signatureBeatPerBar, x, y)
    local dirty = false
      local bpbmin = charButton('beatPerBarMin', "<", x-25, y, 16, 20)
      if bpbmin.clicked then
         timeData.signatureBeatPerBar = timeData.signatureBeatPerBar-1
         if (timeData.signatureBeatPerBar < 1) then
            timeData.signatureBeatPerBar = 1
         end
         dirty = true
      end
      
      local bpbmax = charButton('beatPerBarMax', ">", x+w, y, 16, 20)
      if bpbmax.clicked then
         timeData.signatureBeatPerBar = timeData.signatureBeatPerBar+1
         if (timeData.signatureBeatPerBar > 32) then
            timeData.signatureBeatPerBar = 32
         end
         dirty = true
      end
      
      --love.graphics.print(timeData.signatureUnit, x, y+30)
      local unitmin = charButton('unitMin', "<", x-25, y+30, 16, 20)
      if unitmin.clicked then
         timeData.signatureUnit = timeData.signatureUnit/2
         if timeData.signatureUnit < 1 then
            timeData.signatureUnit = 1
         end
         dirty = true
      end
      
      local unitmax = charButton('unitMax', ">", x+w, y+30, 16, 20)
      if unitmax.clicked then
         --{1,2,4,8,16,32}
         timeData.signatureUnit = timeData.signatureUnit*2
         if timeData.signatureUnit > 32 then
            timeData.signatureUnit = 32
         end
         dirty = true
      end

      return dirty
   end
 

function renderMeasureBarsInSomeRect(x,y,w,h, scale)
   --local scale = canvasScale

   local beatStep = (96/(timeData.signatureUnit/4))
   local barStep = (96/(timeData.signatureUnit/4))*timeData.signatureBeatPerBar
   
   for i = 0, ((w/scale) / beatStep)-1 do
      love.graphics.setColor(0,0,0,0.15)
      if i % 2 == 0 then
         love.graphics.setColor(0,0,0,0.07)
      end
      love.graphics.rectangle('fill', x+i*beatStep*scale,y, beatStep*scale,h)
   end
   
   love.graphics.setColor(0,0,0)
   
   for i=0, w/scale, beatStep  do
      love.graphics.line(x+(i*scale), y, x+(i*scale), y+10)
      
   end
   for i=0, w/scale, barStep do
      love.graphics.line(x+(i*scale), y, x+(i*scale), y+40)
   end

end



function renderPlayHead(x,y,w,h,tick, scale)
     -- print(lastTick)
      --mapInto(lastTick, 0, w)
      if lastTick then
         local xOff = mapInto(tick, 0, w, 0, w*scale)
         love.graphics.line(x+xOff, y, x+xOff, y+h)
      end
   end


function drawRectangle(x,y,w,h, alpha, fill, out)
   love.graphics.setColor(fill[1], fill[2], fill[3], alpha)
   love.graphics.rectangle("fill", x , y, w, h)
   love.graphics.setColor(out[1], out[2], out[3], alpha)
   love.graphics.rectangle("line", x , y, w, h)
end

function renderLabel(str, x,y, alpha)
   love.graphics.setColor(0,0,0, alpha or 1)
   love.graphics.rectangle('fill', x-5, y-2, getStringWidth(str)+10, 20+4 )
   love.graphics.setColor(1,1,1, alpha or 1)
   love.graphics.print(str, x, y)
end

function renderInstrumentSettings(instrument, x, y)
   local knob = drawToggle('vanilla looping', x,y, instrument.settings.useVanillaLooping)

   if knob.value ~= nil then
      instrument.settings.useVanillaLooping = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('glide', x,y+ 40, instrument.settings.glide)
   if knob.value ~= nil then
      instrument.settings.glide = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end
   knob = draw_knob('glideDuration', x+150,y+ 50, instrument.settings.glideDuration, 0, 2)
   if knob.value ~= nil then
      instrument.settings.glideDuration = knob.value
      --print(k.value)

      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('useSustain', x,y+ 80, instrument.settings.useSustain)
   if knob.value ~= nil then
      instrument.settings.useSustain = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end


   knob = drawToggle('mono', x,y+ 120, instrument.settings.monophonic)
   if knob.value ~= nil then
      instrument.settings.monophonic = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('vibrato', x,y+ 160, instrument.settings.vibrato)
   if knob.value ~= nil then
      instrument.settings.vibrato = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end
   knob = drawToggle('adsr pitch', x,y+ 200, instrument.settings.usePitchForADSR)
   if knob.value ~= nil then
      instrument.settings.usePitchForADSR = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = draw_knob('vibratoSpeed', x+150,y+ 170, instrument.settings.vibratoSpeed, 0.001, 16* 6)
   if knob.value ~= nil then
      instrument.settings.vibratoSpeed = knob.value
      --print(k.value)
      print(instrument.settings.vibratoSpeed)
      channel.main2audio:push( {instrument=instrument} );
   end
   knob = draw_knob('vibratoStrength', x+200,y+ 170, instrument.settings.vibratoStrength, 0.1, 5)
   if knob.value ~= nil then
      instrument.settings.vibratoStrength = knob.value
      --print(k.value)
      --      print(instrument.settings.vibratoStrength)
      channel.main2audio:push( {instrument=instrument} );
   end
   


   
   love.graphics.setColor(0,0,0)
   renderLabel("vanilla loop", x+50,y)
   renderLabel("glide", x+50,y+40)
   renderLabel("sustain", x+50,y+80)
   renderLabel("monophonic", x+50,y+120)
   renderLabel("vibrato", x+50,y+160)
   renderLabel("adsr pitch", x+50,y+200)

end


function renderEQ(eq, x, y)
  
     local runningY = y
     local knob
     renderLabel('Hz', x+110 - getStringWidth('Hz')/2 , y-50)
     renderLabel('Q', x+175  - getStringWidth('Q')/2, y-50)
     renderLabel('gain', x+240 -  getStringWidth('gain')/2 , y-50)
     renderLabel('wet', x+305 -  getStringWidth('wet')/2 , y-50)

     local labels = {'lowpass', 'highpass', 'bandpass','lowshelf', 'highshelf' }
     love.graphics.setLineWidth(3)
     for i =1, #labels do
        runningY = y+ (i-1)*50
        renderLabel(labels[i], x, runningY-10)
        
        local e = eq[labels[i]]
         love.graphics.setColor(red[1],red[2],red[3])
        knob = drawToggle('enabled_'..labels[i], x- 30,runningY-10, e.enabled)
        if knob.value ~= nil then
           eq[labels[i]].enabled = knob.value
           channel.main2audio:push ( {eq = eq} );
        end
        
        if e then
           if e.frequency then
           local max = 48000/2
           local min = 10

           if labels[i] == 'highpass' then
              max = 48000/4
           end
           if labels[i] == 'lowpass' then
              max = 48000/64
           end
           if labels[i] == 'bandpass' then
              max = 48000/16
           end
            if labels[i] == 'notch' then
              max = 48000/64
            end
            if labels[i] == 'lowshelf' then
                max = 48000/128
           end

           
           knob = draw_knob(labels[i]..'Hz', x+110, runningY,  eq[labels[i]].frequency, min, max)
           if knob.value ~= nil then
              eq[labels[i]].frequency = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.q then
           knob = draw_knob(labels[i]..'q', x+175, runningY,  eq[labels[i]].q, 1, 100)
           if knob.value ~= nil then
              eq[labels[i]].q = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.gain then
           knob = draw_knob(labels[i]..'gain', x+240, runningY,  eq[labels[i]].gain, -60, 60)
           if knob.value ~= nil then
              eq[labels[i]].gain = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        if e.wet then
           knob = draw_knob(labels[i]..'wet', x+305, runningY,  eq[labels[i]].wet, 0, 1)
           if knob.value ~= nil then
              eq[labels[i]].wet = knob.value
              channel.main2audio:push ( {eq = eq} );
           end
        end
        end
     
     runningY = runningY + 50

    
     end
end

function renderADSREnvelope(adsr, x, y, width, height)
     love.graphics.setLineWidth(3)
     love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
     love.graphics.rectangle("fill", x, y, width, height)


       -- render the envelope

     local sustainDuration = 1 -- this is the toggle for useSustain should be 0 otherwise
     local totalDuration = adsr.attack + adsr.decay + adsr.release + sustainDuration
     local attackWidth = (adsr.attack / totalDuration) * width
     local decayWidth = (adsr.decay / totalDuration) * width
     local releaseWidth = (adsr.release / totalDuration) * width
     local sustainWidth = (sustainDuration / totalDuration) * width
     

     love.graphics.setColor(red[1], red[2], red[3])
     love.graphics.line(x,y+height, x+attackWidth, y+height-((adsr.max)*height))
     love.graphics.line(x+attackWidth, y+height-((adsr.max)*height), x+attackWidth+decayWidth, y+height - ((adsr.sustain)*height))

     love.graphics.line(x+attackWidth+decayWidth, y+height - ((adsr.sustain)*height), x+attackWidth+decayWidth+sustainWidth, y+height - ((adsr.sustain)*height))

     love.graphics.line(x+attackWidth+decayWidth+sustainWidth, y+height - ((adsr.sustain)*height), x+width, y+height )
     
     x = x + 15

     renderLabel('max', x + 10 - getStringWidth('max')/2, y+height+10)
     local knob = v_slider('maxAmplitude', x, y+ height + 40, height, 1.00-adsr.max, 0, 1.00)
     if knob.value ~= nil then
        adsr.max = 1.00 - knob.value
        channel.main2audio:push ( {adsr = adsr} );
     end
     
     renderLabel('sus', x + 50 + 10 - getStringWidth('sus')/2, y+height+10)
     knob = v_slider('sustainAmplitude', x + 50 , y+ height + 40, height, 1.00 - adsr.sustain, 0, 1.00)
     if knob.value ~= nil then
        adsr.sustain = 1.00 - knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('atk', x + 100 + 10 - getStringWidth('atk')/2, y+height+10)
      knob = draw_knob('attackDuration', x+100+10, y+height+40+20,  adsr.attack, 0.00001, 5)
     if knob.value ~= nil then
        adsr.attack = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('dec', x + 150 + 10 - getStringWidth('dec')/2, y+height+10)
     knob = draw_knob('decayDuration', x+150+10, y+height+40+20,  adsr.decay, 0, 5)
     if knob.value ~= nil then
        adsr.decay = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end
     renderLabel('rel', x + 200 + 10 - getStringWidth('rel')/2, y+height+10)
     --knob = v_slider('releaseDuration', x + 200 , y+ height + 40, height*2, adsr.release, 0.0001, 5)
     knob = draw_knob('releaseDuration', x+200+10, y+height+40+20,  adsr.release, 0, 1)
     if knob.value ~= nil then
        adsr.release = knob.value
        channel.main2audio:push ( {adsr = adsr} );

     end


   
     love.graphics.setLineWidth(1)
  end
  
  

function renderWave(data,  xOff, yOff, width, height, startPos_, endPos_)
   local count = data:getSampleCount( )
   local endPos = endPos_ or count-1 
   local startPos = startPos_ or 0

   love.graphics.setColor(1,1,1,0.6)
   love.graphics.rectangle("fill", xOff-2, yOff-height/2, width, height)
   
   local step = ((endPos - startPos)/width)
   love.graphics.setColor(red[1], red[2], red[3])

   for i = 0, width-1 do
      local min = 0
      local max = 0
      local pos = startPos + math.floor(step * (i))
      local s = 0
      for i =  -math.floor(step/2), math.floor(step/2) do
         if (pos + i >= 0 and pos + i <= count) then
            s = data:getSample(pos+i)
            if s < min then min = s end
            if s > max then max = s end
         end
      end
 

      
      love.graphics.line(xOff+i-1, yOff+math.floor((min * (height/2))), xOff+i-1, yOff)
      love.graphics.line(xOff+i-1, yOff+math.floor((max * (height/2))), xOff+i-1,  yOff)
   end


end
