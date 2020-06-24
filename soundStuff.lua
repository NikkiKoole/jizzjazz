


function getSoundForSemitoneAndVelocity(semitone, velocity, instrument)
   --print('getting the sound!', instrument.isDrumKit)
   if #instrument.sounds == 1 then
      return instrument.sounds[1]
   else
      local bestScored = instrument.sounds[1]
      local highestScore = 0
      for i = 1, #instrument.sounds do
         local score = 144000
         score = score - (math.abs(instrument.sounds[i].sample.root * 1000 - semitone*1000))
         
         if (instrument.sounds[i].sample.rootVelocity) then
            score = score - (math.abs(instrument.sounds[i].sample.rootVelocity  - velocity))
         end

         if score > highestScore then
            highestScore = score
            bestScored = instrument.sounds[i]
         end
      end
      --print('picked', bestScored.sample.path)
      return bestScored
   end
end

function writeSoundData(toClone, startPos, endPos)
   local rate = toClone:getSampleRate( )
   local bitDepth = toClone:getBitDepth()
   local channels = toClone:getChannelCount()
   local sound_data = love.sound.newSoundData((endPos - startPos) + 0, rate, bitDepth, channels)
   
   for i = startPos, endPos-1 do
      sound_data:setSample(i-startPos, toClone:getSample(i)  )
   end
   
   return sound_data
end

function writeSoundDataMultipleTimes(toClone, startPos, endPos, times)
   -- we need bigger samples for higher notes, queueing 64+ samples breaks so just patch them already.
   local rate = toClone:getSampleRate( )
   local bitDepth = toClone:getBitDepth()
   local channels = toClone:getChannelCount()
   local size = (endPos - startPos)+0
   local sound_data = love.sound.newSoundData((size * times) + 0, rate, bitDepth, channels)

   for t = 1, times do
      for i = startPos, endPos-1 do
         sound_data:setSample(i-startPos + ((t-1) * size), toClone:getSample(i)  )
      end
   end
   
   return sound_data
end

function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end


function fillPitches()
   local result = {}
   for i = 0, 144+24 do
      local freqs = {261.63, 277.18, 293.66, 311.13, 329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88, 523.25}
      local o = math.floor(i / 12)
      local semitone = i % 12
      local n = mapInto(freqs[semitone+1], 261.63, 523.25, 0, 1)
      local pitch = 1

      if     o == 0 then pitch =(0.03125 -(0.015625 -  n/64))
      elseif o == 1 then pitch =(0.0625 -(0.03125 -  n/32))
      elseif o == 2 then pitch =(0.125 -(0.0625 -  n/16))
      elseif o == 3 then pitch =(0.25 -(0.125 -  n/8))
      elseif o == 4 then pitch =(0.5 -(0.25 -  n/4))
      elseif o == 5 then pitch =(1 -(0.5 -  n/2))
      elseif o == 6 then  pitch =(1 + n)
      elseif o == 7 then  pitch =(2 + 2*n)
      elseif o == 8 then  pitch =(4 + 4*n)
      elseif o == 9 then  pitch =(8 + 8*n)
      elseif o == 10 then  pitch =(16 + 16*n)
      elseif o == 11 then  pitch =(32 + 32*n)
      elseif o == 12 then  pitch =(64 + 64*n)
      elseif o == 13 then  pitch =(128 + 128*n)
      elseif o == 14 then  pitch =(256 + 256*n)
      end
      result[i] = pitch
      --pitches[i] = pitch
   end
   return result
end



function vanillaFilter(gain)
   local result = {
      enabled=false,
      wet = 0,   -- [0, 1]
      q = 1,     -- [0, 100]
      frequency = 0 -- [0, samplerate/2]
   }
   if gain then
      result.gain = 0 
   end
   
   return result
end


local vanillaAdsr = {
   attack = 0.01,
   max   = .50,
   decay = 0.0,
   sustain= .50,
   release = .2,
}

local vanillaEq = {
   fadeout = 0,
   fadein = 0,
   lowpass =  vanillaFilter(),
   highpass =  vanillaFilter(),
   bandpass = vanillaFilter(),         
   allpass = vanillaFilter(),
   lowshelf = vanillaFilter(true),
   highshelf = vanillaFilter(true),
}


function createDrumInstrument(path)
   local s = love.sound.newSoundData( path )
   --instrument.sounds[i].sample.soundData =s
   --      instrument.sounds[i].sample.sound = love.audio.newSource(s, 'static')
 
   return {
     
      settings = {
         useVanillaLooping = false,
         glide = false,
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  
         transpose = 0,
         usePitchForADSR = false,
         transpose = 0,
      }, 
      sounds = {{
         eq = vanillaEq,
         adsr = vanillaAdsr,
         sample = {
            path=path,
            root=60,
            fullSoundData = s,
            soundData =s,
            sound = love.audio.newSource(s, 'static')
            
         }
      }}
   }
end


function loadAndFillInstrumentRaw(instrument)

   for i =1 , #instrument.sounds do
      local s = love.sound.newSoundData( instrument.sounds[i].sample.path )

      if instrument.adsr then
         instrument.sounds[i].adsr = instrument.adsr
      end
      
      if not instrument.sounds[i].adsr then
         instrument.sounds[i].adsr = vanillaAdsr
      end
      if not instrument.sounds[i].eq then
         instrument.sounds[i].eq = vanillaEq
      end
      
      
      local loopStart = instrument.sounds[i].sample.loopStart
      local loopEnd = instrument.sounds[i].sample.loopEnd 

      if (loopStart and loopEnd) then
         instrument.sounds[i].sample.fullSoundData = s
         instrument.sounds[i].sample.soundData = s
         
         local begin = writeSoundData(s, 0, loopStart)
         
         -- TODO for some samples you want to write multiple middle parts!!!!!!!!!!!!!!1
         -- not for all
         local middle = writeSoundDataMultipleTimes(s, loopStart, loopEnd, 4)
         local after = writeSoundData(s, loopEnd, s:getSampleCount()-1)

         instrument.sounds[i].sample.loopPointParts = {begin=begin, middle=middle, after=after}

      else
         instrument.sounds[i].sample.fullSoundData = s
         instrument.sounds[i].sample.soundData =s
         instrument.sounds[i].sample.sound = love.audio.newSource(s, 'static')
      end
   end

   return instrument
end
