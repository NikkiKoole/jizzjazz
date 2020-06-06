
function drawRectangle(x,y,w,h, alpha, fill, out)
   love.graphics.setColor(fill[1], fill[2], fill[3], alpha)
   love.graphics.rectangle("fill", x , y, w, h)
   love.graphics.setColor(out[1], out[2], out[3], alpha)
   love.graphics.rectangle("line", x , y, w, h)
end

function renderLabel(str, x,y)
   love.graphics.setColor(0,0,0)
   love.graphics.rectangle('fill', x-5, y-2, getStringWidth(str)+10, 20+4 )
   love.graphics.setColor(1,1,1)
   love.graphics.print(str, x, y)
end

function renderInstrumentSettings(instrument)
local knob = drawToggle('vanilla looping', 100,100, instrument.settings.useVanillaLooping)

   if knob.value ~= nil then
      instrument.settings.useVanillaLooping = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('glide', 100,100+ 40, instrument.settings.glide)
   if knob.value ~= nil then
      instrument.settings.glide = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end
     knob = draw_knob('glideDuration', 250,100+ 50, instrument.settings.glideDuration, 0, 2)
   if knob.value ~= nil then
      instrument.settings.glideDuration = knob.value
      --print(k.value)

      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('useSustain', 100,100+ 80, instrument.settings.useSustain)
   if knob.value ~= nil then
      instrument.settings.useSustain = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end


    knob = drawToggle('mono', 100,100+ 120, instrument.settings.monophonic)
   if knob.value ~= nil then
      instrument.settings.monophonic = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = drawToggle('vibrato', 100,100+ 160, instrument.settings.vibrato)
   if knob.value ~= nil then
      instrument.settings.vibrato = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end
   knob = drawToggle('adsr pitch', 100,100+ 200, instrument.settings.usePitchForADSR)
   if knob.value ~= nil then
      instrument.settings.usePitchForADSR = knob.value
      --print(k.value)
      channel.main2audio:push( {instrument=instrument} );
   end

   knob = draw_knob('vibratoSpeed', 250,100+ 170, instrument.settings.vibratoSpeed, 0.001, 16)
   if knob.value ~= nil then
      instrument.settings.vibratoSpeed = knob.value
      --print(k.value)
      print(instrument.settings.vibratoSpeed)
      channel.main2audio:push( {instrument=instrument} );
   end
   knob = draw_knob('vibratoStrength', 300,100+ 170, instrument.settings.vibratoStrength, 0.1, 5)
   if knob.value ~= nil then
      instrument.settings.vibratoStrength = knob.value
      --print(k.value)
--      print(instrument.settings.vibratoStrength)
      channel.main2audio:push( {instrument=instrument} );
   end
  


   
   love.graphics.setColor(0,0,0)
   renderLabel("vanilla loop", 100+50,100)
   renderLabel("glide", 100+50,100+40)
   renderLabel("sustain", 100+50,100+80)
   renderLabel("monophonic", 100+50,100+120)
   renderLabel("vibrato", 100+50,100+160)
   renderLabel("adsr pitch", 100+50,100+200)

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
              max = 48000/64
           end
            if labels[i] == 'notch' then
              max = 48000/64
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

     -- renderLabel('fade out', x, runningY-10)
     -- knob = h_slider('fade out', x + 100, runningY-10, 200, eq.fadeout or 0, 0.0, activeSoundData:getDuration()-0.001 )
     -- if knob.value ~= nil then
     --    eq.fadeout = knob.value
     --    channel.main2audio:push ( {eq = eq} );
     -- end
     -- runningY = runningY + 50
     -- renderLabel('fade in', x, runningY-10)
     -- knob = h_slider('fade in', x + 100, runningY-10, 200, eq.fadein or 0 , 0.0, activeSoundData:getDuration()-0.001 )
     -- if knob.value ~= nil then
     --    eq.fadein = knob.value
     --    channel.main2audio:push ( {eq = eq} );
     -- end
     end
     love.graphics.setLineWidth(1)

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
  
  

function renderWave(data,  xOff, yOff, width, height)
   local count = data:getSampleCount( )
   local endPos = count-1 
   local startPos = 0

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
