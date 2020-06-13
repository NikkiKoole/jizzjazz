require('love.timer')
require('love.sound')
require('love.audio')
require('love.math')
sone = require 'sone'
require 'instrument'
--https://github.com/danigb/timestretch/blob/master/lib/index.js

luamidi = require "luamidi"
local inspect = require "inspect"
local now = love.timer.getTime()
local time = 0
local lastTick = -1
--local lastTick2 = 0
local run = false
local isPlaying = false
local timeData = nil
local timeSinceStartPlay = 0

local recordingNotes = {}
local notes = {}


local metronomeBeat = love.audio.newSource("assets/samples/cr78/Rim Shot.wav", 'static')
metronomeBeat:setVolume(0.5)
channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main

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



function getQueueable(s)
   return love.audio.newQueueableSource( s:getSampleRate( ),
                                         s:getBitDepth(),
                                         s:getChannelCount(), 8 )
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

function loadAndFillInstrument()

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

   
   love.thread.getChannel( 'audio2main' ):push({soundData=instrument.sounds[1].sample.soundData})
   love.thread.getChannel( 'audio2main' ):push({instrument=instrument})

end


instrument = getDefaultInstrument()
loadAndFillInstrument()


activeSources = {}
pitches = {}

function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

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

   pitches[i] = pitch
end


if luamidi then
   print("Midi Input Ports: ", luamidi.getinportcount())
   print( 'Receiving on device: ', luamidi.getInPortName(0))
   run = true
end

function getSoundForSemitoneAndVelocity(semitone, velocity)
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
      print('picked', bestScored.sample.path)
      return bestScored
   end
   
   
end


function playNote(semitone, velocity, instrument)

   local settings = instrument.settings
   
   
   local sound = getSoundForSemitoneAndVelocity(semitone, velocity) 
   local transpose = instrument.settings.transpose
   local adsr = sound.adsr
   
   love.thread.getChannel( 'audio2main' ):push({playSemitone=semitone+transpose})

   if (settings.glide or settings.monophonic) and #activeSources > 0 then
      local index = 1 --findIndexFirstNonEchoNote()
      assert(#activeSources == 1 or index > 1)
      activeSources[index].pickedInstrumentSound = sound
      activeSources[index].key = semitone
      activeSources[index].released = nil
      activeSources[index].noteOnTime=now
      activeSources[index].noteOnVelocity=velocity
      
      if settings.glide then
         activeSources[index].glideFromPitch = activeSources[index].sound:getPitch()
         activeSources[index].glideStart = now
         activeSources[index].noteOffTime=-1
      end

      if settings.monophonic then
         activeSources[index].noteOffTime=-1
      end
      
      if settings.useSustain == false then
         if settings.usePitchForADSR  then
            activeSources[index].noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release) /getPitch(activeSources[index])
         else
            activeSources[index].noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release) 
         end
         activeSources[index].noteOffVolume = adsr.sustain
      end

      if settings.glide or settings.monophonic and not settings.useVanillaLooping then
         -- this is a one-shot just retrigger the sound
         if not (activeSources[index].sound:isPlaying() ) then
            activeSources[index].noteOffVolume = -1
            activeSources[index].sound:play()
            love.thread.getChannel( 'audio2main' ):push({soundStartPlaying=activeSources[index]})
         end
      end
      

   else
      local s2
      local usingLoopPoints = false
      if sound.sample.loopPointParts then
         usingLoopPoints = true
         s2 = getQueueable(sound.sample.soundData)
         s2:queue(sound.sample.loopPointParts.begin)
      else
         s2 = sound.sample.sound:clone()
      end
      
      local s = {sound=s2,
                 pickedInstrumentSound = sound,
                 key=semitone,
                 noteOnTime=now,
                 noteOnVelocity=velocity,
                 noteOffTime=-1 ,
                 usingLoopPoints=usingLoopPoints,
                 loopParts = sound.sample.loopPointParts,
                 fullSound=sound.sample.fullSoundData }

      if settings.useSustain == false then
         if settings.usePitchForADSR then
            s.noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release)/getPitch(s)
         else
            s.noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release)
         end
         
         s.noteOffVolume = adsr.sustain
      end

      if settings.useVanillaLooping then
         if not s.loopParts then
            s.sound:setLooping(true)
         end
      end
      
      s.sound:setPitch(getPitch(s))
      s.sound:setVolume(0)
      s.sound:play()
      love.thread.getChannel( 'audio2main' ):push({soundStartPlaying=s})

      table.insert(activeSources, s)
   end
   if isPlaying and isRecording then
      recordingNotes[semitone] = {semitone=semitone,
                                  velocity=velocity,
                                  tick=math.ceil(lastTick)}
      
      --print('playnote', inspect(recordingNotes[semitone]))
   end
   love.thread.getChannel( 'audio2main' ):push({activeSources=activeSources})

end



function stopNote(semitone)
   if isPlaying and isRecording then
      local me = recordingNotes[semitone]
      if me then
         local tick =  math.ceil(lastTick)
         local current = notes[tick]
         if current ~= nil then
           -- print('??', inspect(current))
            table.insert(notes[me.tick],
                         {key=me.semitone,
                          length=tick - me.tick,
                          startTick=me.tick  })

         else
            current = {{key=me.semitone,
                        length=tick - me.tick,
                        startTick=me.tick}}
           -- print('stop', inspect(current), me.tick)

            notes[me.tick] = current
         end
         
         
         --print('duration:', math.ceil(lastTick) -  me.tick)
         recordingNotes[semitone] = nil
         love.thread.getChannel( 'audio2main' ):push({notes=notes})

         --print(semitone, 'recordingNotes', inspect(recordingNotes))
      end
      
   end

   for i=1, #activeSources do
      if semitone == activeSources[i].key then
         
         if instrument.settings.useSustain == true then
            activeSources[i].noteOffTime = now
            activeSources[i].noteOffVolume = activeSources[i].sound:getVolume()
         end

         activeSources[i].released = true
      end
   end
end

function getPitch(activeSource, offset)
   local transpose = instrument.settings.transpose
   local rootTranspose =  0
   if activeSource.pickedInstrumentSound.sample.root then
      rootTranspose = 72 - activeSource.pickedInstrumentSound.sample.root
   end
   local index = activeSource.key + (offset or 0) + transpose + rootTranspose
   
   return pitches[index] or 1
end

function pitchNote(value)
   for i=1, #activeSources do
      local newPitch = mapInto(value, 0, 127,
                               getPitch(activeSources[i], -1),
                               getPitch(activeSources[i], 1))
      if value == 64 then
         newPitch =  getPitch(activeSources[i])
      end
      activeSources[i].pitchDelta =  newPitch -  getPitch(activeSources[i])
   end
end

function getVolumeASDR(now, noteOnTime, noteOffTime, noteOffVolume,adsr, isEcho, pitch)
   local volume = 0
   local attackTime = (now - noteOnTime)
   
   local attack = adsr.attack / pitch
   local decay = adsr.decay / pitch
   local release = adsr.release / pitch

   if noteOffTime == -1 or noteOffTime > now  then 
      
      if attackTime < 0 then
         volume = 0
         --print('before phase', volume§)
      elseif attackTime >=0 and attackTime <= attack then
         volume = mapInto(attackTime, 0, attack, 0, adsr.max)
         --print('attack phase', volume)
      elseif attackTime <= attack + decay then
         volume = mapInto(attackTime - attack, 0, adsr.decay, adsr.max, adsr.sustain)
         --print('decay phase', volume)
      elseif attackTime > attack + decay then
         volume = adsr.sustain
         --print('sustain phase', volume)
      end
      
   else
      local releaseTime = (now - noteOffTime)
      volume = mapInto(releaseTime, release, 0, 0, noteOffVolume)
      if adsr.release == 0 then
         volume = 0
      end
      --print('release phase', volume, noteOffVolume)

   end
   if attackTime < 0 then
      volume = 0
   end
   
   if volume < 0 then volume = 0 end

   return volume
end

function handleMIDIInput()
   if luamidi and luamidi.getinportcount() > 0 then
      --print('yo')
      local a, b, c, d = nil
      a,b,c,d = luamidi.getMessage(0)
      --https://en.wikipedia.org/wiki/List_of_chords
      --local integers = {0, 4,7,11}
      local integers = {0}

      --local integers = {0, 4, 7, 11}
      --local integers = {0, 3, 7, 9}
      if a ~= nil then
         -- look for an NoteON command

         if a == 144 then
            --print('midi message play', b)
            playNote(b, c, instrument)
         elseif a == 128 then
            stopNote(b)
         elseif a == 176 then
            if b == 2 then
               instrument.settings.vibratoSpeed = 96/ math.max(c,1)
            elseif b == 3 then
               instrument.settings.vibratoStrength = math.max(c,1)

            else
               print('knob', b,c)
            end

         elseif a == 224 then
            pitchNote(c)
         else
            print("unknown midi message: ", a, b,c,d)
         end
      end
   end
   

end

function handleThreadInput()
   local v = channel.main2audio:pop();
   if v then
      -- if v.signatureBeatPerBar then
      --    timeData.signatureBeatPerBar = v.signatureBeatPerBar
         
      --    local ticksPerUnit = 96 / (timeData.signatureUnit/ 4)
      --    local newBeat = lastTick / ticksPerUnit
      --    timeData.beat  = (newBeat % timeData.signatureBeatPerBar) + 1
      --    timeData.bar = (newBeat / timeData.signatureBeatPerBar)
      --    --love.thread.getChannel( 'audio2main' ):push({timeData=timeData})
      -- end
      -- if v.signatureUnit then
      --    timeData.signatureUnit = v.signatureUnit
      --    -- now we also want to change the current beat and bar i blieve
      --    local ticksPerUnit = 96 / (timeData.signatureUnit/ 4)
      --    local newBeat = lastTick / ticksPerUnit
      --    timeData.beat  = (newBeat % timeData.signatureBeatPerBar) + 1
      --    timeData.bar = (newBeat / timeData.signatureBeatPerBar)
      --    --love.thread.getChannel( 'audio2main' ):push({timeData=timeData})
      -- end
       if v.isRecording ~= nil then
          isRecording = v.isRecording
       end
       
      if v.isPlaying ~= nil then
         isPlaying = v.isPlaying
         now = love.timer.getTime()
      end
      if v.timeData then
         timeData = v.timeData
      end
      if v.stepBackTime then
         timeData = v.stepBackTime
         timeSinceStartPlay = 0
         lastTick = 0
      end
      if v.tempo then
         timeData.tempo = v.tempo
      end
      
      
      if (v == 'quit') then
         for i = 1, #activeSources do
            activeSources[i].sound:stop()
            if activeSources[i].extra then
               for j=1,  #activeSources[i].extra do
                  activeSources[i].extra[j].sound:stop()
               end
            end
         end
         
         luamidi.gc()
         run = false
         love.thread.getChannel( 'audio2main' ):push('quit')
      end

      if v.instrument then
         instrument = v.instrument
      end
      
      if v.loadInstrument then
         instrument = v.loadInstrument
         loadAndFillInstrument()
      end
      
      if v.adsr then
         instrument.sounds[1].adsr = v.adsr
      end

      if v.instrumentStartEnd then
         local d = v.instrumentStartEnd
         local loopStart = d.sounds[1].sample.loopStart
         local loopEnd = d.sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instrument.sounds[1].sample.loopStart = loopStart
            instrument.sounds[1].sample.loopEnd =loopEnd
            local soundData = instrument.sounds[1].sample.soundData
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount())
            instrument.sounds[1].sample.loopPointParts = {begin=begin, middle=middle, after=after}
         end
      end
      
      if v.osc  then
         instrument =  getDefaultInstrument()
         
         instrument.settings.useVanillaLooping = true
         instrument.sounds[1].sample.loopStart= nil
         instrument.sounds[1].sample.loopEnd= nil
         instrument.sounds[1].sample.loopPointParts = nil
         instrument.sounds[1].sample.path = v.osc
         loadAndFillInstrument()
         --soundData = love.sound.newSoundData( v.osc )
         
         --instrument.sounds[1].sample.fullSoundData = soundData
         --instrument.sounds[1].sample.soundData = soundData

         --sound = love.audio.newSource(soundData, 'static')
         --instrument.sounds[1].sample.sound = sound
         --print('after osc', inspect(instrument))
         --love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
         --love.thread.getChannel( 'audio2main' ):push({instrument=instrument})
      end
      
      if v.eq then
         soundData = love.sound.newSoundData(instrument.sounds[1].sample.path  )
         if v.eq.lowshelf.enabled then
            sone.filter(soundData, {
                           type = "lowshelf",
                           frequency = v.eq.lowshelf.frequency,
                           Q=v.eq.lowshelf.q,
                           wet=v.eq.lowshelf.wet,
                           gain = v.eq.lowshelf.gain                      
                           
            })
         end
         if v.eq.highshelf.enabled then
            sone.filter(soundData, {
                           type = "highshelf",
                           frequency = v.eq.highshelf.frequency,
                           Q=v.eq.highshelf.q,
                           wet=v.eq.highshelf.wet,
                           gain = v.eq.highshelf.gain                      
                           
            })
         end
         if v.eq.highpass.enabled then
            sone.filter(soundData, {
                           type = "highpass",
                           frequency = v.eq.highpass.frequency,
                           Q=v.eq.highpass.q,
                           wet=v.eq.highpass.wet,
            })
         end
         if v.eq.lowpass.enabled then
            sone.filter(soundData, {
                           type = "lowpass",
                           frequency = v.eq.lowpass.frequency,
                           Q=v.eq.lowpass.q,
                           wet=v.eq.lowpass.wet,
            })
         end
         if v.eq.bandpass.enabled then
            sone.filter(soundData, {
                           type = "bandpass",
                           frequency = v.eq.bandpass.frequency,
                           Q=v.eq.bandpass.q,
                           wet=v.eq.bandpass.wet,

            })
         end
         if v.eq.fadeout > 0 then 
            sone.fadeOut(soundData, v.eq.fadeout)
         end
         if v.eq.fadein > 0 then 
            sone.fadeIn(soundData, v.eq.fadein)
         end


         sound = love.audio.newSource(soundData, 'static')

         instrument.sounds[1].sample.soundData = soundData
         instrument.sounds[1].sample.sound = sound

         local loopStart = instrument.sounds[1].sample.loopStart
         local loopEnd = instrument.sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instrument.sounds[1].sample.fullSoundData = soundData
            instrument.sounds[1].sample.soundData = soundData
            
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount()-1)

            instrument.sounds[1].sample.loopPointParts = {begin=begin, middle=middle, after=after}
         end
         
         
         love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
      end

   end
   
end


while(run ) do
   if #activeSources == 0 then
      --      print('no one here')
   end
   
   local settings = instrument.settings

   for i =1, #activeSources do
      -- lets first do the queuepart
      if activeSources[i].usingLoopPoints and  activeSources[i].pickedInstrumentSound.sample.loopPointParts then
         
         local pitch = activeSources[i].sound:getPitch()
         local tell = (activeSources[i].sound:tell())
         local dur = (activeSources[i].sound:getDuration())
         local timeLeftInSample = (dur - tell)/pitch
         local noteHasBeenReleasedInPast = activeSources[i].noteOffTime ~= -1 and now - activeSources[i].noteOffTime > 0
         
         if (noteHasBeenReleasedInPast) then
            local releaseDuration =  activeSources[i].pickedInstrumentSound.adsr.release
            local afterLength =  activeSources[i].pickedInstrumentSound.sample.loopPointParts.after:getDuration() 
            if timeLeftInSample + afterLength >= releaseDuration then
               activeSources[i].sound:queue(activeSources[i].pickedInstrumentSound.sample.loopPointParts.after)
            end
         end

         if (timeLeftInSample < 0.016) then -- only 16 ms left
            --print('queeuein', now)
            activeSources[i].sound:queue(activeSources[i].pickedInstrumentSound.sample.loopPointParts.middle)
            
            
            --print(pitch)
         end
      end
      

      local pitch =  getPitch(activeSources[i])
      
      local v = getVolumeASDR(now, activeSources[i].noteOnTime,
                              activeSources[i].noteOffTime,
                              activeSources[i].noteOffVolume,
                              activeSources[i].pickedInstrumentSound.adsr,
                              activeSources[i].isEcho,
                              settings.usePitchForADSR and  pitch or 1)
      local vel = (activeSources[i].noteOnVelocity/127)
      activeSources[i].sound:setVolume(v * vel)


      -- print('somehting is playing: ', vel)
      -- glide / portamento
      
      local newPitch = pitch
      
      if settings.glide then
         if activeSources[i].glideFromPitch then
            local glideTime =  (now - activeSources[i].glideStart)
            newPitch = mapInto(glideTime, 0, settings.glideDuration,
                               activeSources[i].glideFromPitch,
                               getPitch(activeSources[i]))
            if glideTime > settings.glideDuration then
               newPitch = getPitch(activeSources[i])
               activeSources[i].glideFromPitch = nil
            end
         end
      end

      -- 
      if settings.vibrato then
         local vibratoSmallPitchDiff =  (getPitch(activeSources[i]) - getPitch(activeSources[i], 1) ) 
         local vibratoPitchOffset = math.sin(time * settings.vibratoSpeed) *  vibratoSmallPitchDiff/(settings.vibratoStrength) -- [-1, 1]
         --print(vibratoPitchOffset, newPitch)
         if activeSources[i].glideFromPitch then
            newPitch = newPitch + (vibratoPitchOffset)/2
         else
            newPitch =  getPitch(activeSources[i])  + (vibratoPitchOffset)--(math.sin(time*vibratoSpeed)/vibratoStrength)
         end
      end

      -- pitch knob
      if activeSources[i].pitchDelta then
         newPitch = newPitch + activeSources[i].pitchDelta
      end
      
      
      if newPitch < 0.00001 then newPitch = 0.00001 end
      activeSources[i].sound:setPitch(newPitch)

      
   end

   local hasRemovedOne = false
   for i = #activeSources, 1, -1 do
      if activeSources[i].remove then
         --activeSources[i].remove = activeSources[i].remove -1
         --if activeSources[i].remove <= 0 then
         activeSources[i].sound:stop()
         table.remove(activeSources, i)
         hasRemovedOne = true
         --end
      end
   end
   if hasRemovedOne then
       love.thread.getChannel( 'audio2main' ):push({activeSources=activeSources})
   end
   
   
   for i = #activeSources, 1, -1 do
      if activeSources[i].released == true then
         local remove = false
         if activeSources[i].sound:getVolume() < 0.00001 and now > activeSources[i].noteOnTime then
            activeSources[i].sound:setVolume(0)
            activeSources[i].remove = true
         end
      end
   end
   
   handleMIDIInput()
   handleThreadInput()


   --print(isPlaying)
   local n = love.timer.getTime()
   local delta = n - now
   now = n
   time = time + delta
   
   if isPlaying then
      
      --if lastTick == -1 then
      --   lastTick = 0
      --end
      --print(lastTick)
      timeSinceStartPlay = timeSinceStartPlay + delta
      --print(timeSinceStartPlay)
      local pulses_per_quarter_note = 96
      local tickdelta = (delta * (timeData.tempo / 60) * 96)
      local tick = lastTick + tickdelta
      
     
      local unitsPerBar = timeData.signatureBeatPerBar 
      local ticksPerUnit = pulses_per_quarter_note / (timeData.signatureUnit/4)

      
      if math.floor(tick) - math.floor(lastTick) > 1 then
         print('thread: missed ticks:', math.floor(tick), math.floor(lastTick))
      end

      if math.floor(tick) ~= math.floor(lastTick) then
         local wholeTick = math.ceil(tick)
         -- check our notes
         
         love.thread.getChannel( 'audio2main' ):push({tick=wholeTick})
         if wholeTick % ticksPerUnit == 0 then
            local pitch = 1
            --print(timeSinceStartPlay)
            timeData.beat = timeData.beat + 1
            if timeData.beat > unitsPerBar then
               timeData.beat = 1
               timeData.bar = timeData.bar + 1
               pitch = 1.5
              
            end
            metronomeBeat:setPitch(pitch)
            metronomeBeat:play()
            love.thread.getChannel( 'audio2main' ):push({timeData=timeData})
         end
      end

      lastTick = tick
      
   end
   
   

   
   love.timer.sleep(0.001)
   
end

