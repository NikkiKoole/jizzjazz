require('love.timer')
require('love.sound')
require('love.audio')
require('love.math')
require 'soundStuff'
sone = require 'sone'
require 'instrument'
--https://github.com/danigb/timestretch/blob/master/lib/index.js

luamidi = require "luamidi"
local inspect = require "inspect"
local now = love.timer.getTime()
local time = 0
local lastTick = -1
local run = false
local isPlaying = false
local timeData = nil
local beatAndBar = nil
local timeSinceStartPlay = 0
local activeInstrumentIndex = 1
local recordingNotes = {}
local notes = {}
local triggeredPlayNotes = {}

local metronomeBeat = love.audio.newSource("assets/samples/cr78/Rim Shot.wav", 'static')
local metronomeOn = false 

metronomeBeat:setVolume(0.5)
channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main



function getQueueable(s)
   return love.audio.newQueueableSource(
      s:getSampleRate( ), s:getBitDepth(), s:getChannelCount(), 8
   )
end



function loadAndFillInstrument(instrument)
   loadAndFillInstrumentRaw(instrument)
   --love.thread.getChannel( 'audio2main' ):push({soundData=instrument.sounds[1].sample.soundData})
   --love.thread.getChannel( 'audio2main' ):push({instrument=instrument})
end


local instruments = {}
instruments[1] =  loadAndFillInstrumentRaw(getDefaultInstrument())
instruments[2] =  loadAndFillInstrumentRaw(getDefaultInstrument())
instruments[3] =  loadAndFillInstrumentRaw(getDefaultInstrument())
instruments[4] =  loadAndFillInstrumentRaw(getDefaultInstrument())
instruments[5] =  loadAndFillInstrumentRaw(getDefaultInstrument())
--instruments[6] =  loadAndFillInstrumentRaw(getDefaultInstrument())

--love.thread.getChannel( 'audio2main' ):push({soundData=instrument.sounds[1].sample.soundData})
love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
--loadAndFillInstrument(instruments[1])
--instruments[2] = getDefaultInstrument()
--loadAndFillInstrument(instruments[2])

activeSources = {}
pitches = fillPitches()

if luamidi then
   print("Midi Input Ports: ", luamidi.getinportcount())
   print( 'Receiving on device: ', luamidi.getInPortName(0))
   run = true
end



function playNote(semitone, velocity, instrument, length )

   local settings = instrument.settings
   
   
   local sound = getSoundForSemitoneAndVelocity(semitone, velocity, instruments[activeInstrumentIndex]) 
   local transpose = instrument.settings.transpose
   local adsr = sound.adsr
   
   love.thread.getChannel( 'audio2main' ):push({playSemitone=semitone+transpose})

   if (settings.glide or settings.monophonic) and #activeSources > 0 then
      local index = 1 --findIndexFirstNonEchoNote()
      assert(#activeSources > 0)
      activeSources[index].instrument = instrument
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
                 instrument = instrument,
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

      -- if length ~= nil then
         
      --    local perS = ( (timeData.tempo / 60) * 96) -- what you would use in 1 second
      --    s.noteOffTime = now  + (length / perS)
      --    s.noteOffVolume = 0.5  -- todo!
      -- end
      
      
      s.sound:setPitch(getPitch(s))
      s.sound:setVolume(0)
      s.sound:play()
      love.thread.getChannel( 'audio2main' ):push({soundStartPlaying=s})
      love.thread.getChannel( 'audio2main' ):push({soundData=s.fullSound})
      table.insert(activeSources, s)
   end
   
   love.thread.getChannel( 'audio2main' ):push({activeSources=activeSources})

end



function stopNote(semitone, instrument)
   

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
   offset = offset or 0
   local transpose = activeSource.instrument.settings.transpose
   local rootTranspose =  0
   if activeSource.pickedInstrumentSound.sample.root then
      rootTranspose = 72 - activeSource.pickedInstrumentSound.sample.root
   end
   local index = activeSource.key + offset  + transpose + rootTranspose
   
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

function recordPlayedNote(b, c)
   recordingNotes[b] = {semitone=b,
                        velocity=c,
                        tick=math.ceil(lastTick)}
end

function recordStoppedNote(b)
   local me = recordingNotes[b]

   
   if me then
      local tick =  math.ceil(lastTick)
      local current = notes[me.tick]

      local node = {key=me.semitone,
                    velocity=me.velocity,
                    length=tick - me.tick,
                    startTick=me.tick }
      if current ~= nil then
            table.insert(notes[me.tick], node)
      else
         current = {node}
         notes[me.tick] = current
      end
      
      recordingNotes[b] = nil
      love.thread.getChannel( 'audio2main' ):push({notes=notes})
   end
end


function handleMIDIInput()
   if luamidi and luamidi.getinportcount() > 0 then
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
            playNote(b, c, instruments[activeInstrumentIndex])
            if isPlaying and isRecording then
               recordPlayedNote(b, c)
            end
         elseif a == 128 then
            stopNote(b, instruments[activeInstrumentIndex])
            if isPlaying and isRecording then
               recordStoppedNote(b)
               
            end
         elseif a == 176 then
            if b == 2 then
               instruments[1].settings.vibratoSpeed = 96/ math.max(c,1)
            elseif b == 3 then
               instruments[1].settings.vibratoStrength = math.max(c,1)

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

      if v.activeInstrumentIndex ~= nil then
         activeInstrumentIndex = v.activeInstrumentIndex
      end
      
      if v.metronomeOn ~= nil then
         metronomeOn = v.metronomeOn
      end
      
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
      
      if v.beatAndBar then
         beatAndBar = v.beatAndBar
      end
      
      if v.stepBackTime then
         timeSinceStartPlay = 0
         lastTick = 0
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
         --print('hello')

      --   instruments[1] = v.instrument
      end
      
      if v.loadInstrument then
         --print('hi')
         
         instruments[activeInstrumentIndex] = loadAndFillInstrumentRaw(v.loadInstrument)
         love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
         --loadAndFillInstrument(instruments[1])
      end
      
      if v.adsr then
         instruments[activeInstrumentIndex].sounds[1].adsr = v.adsr
      end

      if v.instrumentStartEnd then
         local d = v.instrumentStartEnd
         local loopStart = d.sounds[1].sample.loopStart
         local loopEnd = d.sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instruments[1].sounds[1].sample.loopStart = loopStart
            instruments[1].sounds[1].sample.loopEnd =loopEnd
            local soundData = instruments[1].sounds[1].sample.soundData
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount())
            instruments[1].sounds[1].sample.loopPointParts = {begin=begin, middle=middle, after=after}
         end
      end
      
      if v.osc  then
         instruments[activeInstrumentIndex] =  getDefaultInstrument()
         
         instruments[activeInstrumentIndex].settings.useVanillaLooping = true
         instruments[activeInstrumentIndex].sounds[1].sample.loopStart= nil
         instruments[activeInstrumentIndex].sounds[1].sample.loopEnd= nil
         instruments[activeInstrumentIndex].sounds[1].sample.loopPointParts = nil
         instruments[activeInstrumentIndex].sounds[1].sample.path = v.osc
         loadAndFillInstrument(instruments[activeInstrumentIndex])
         love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
       
      end
      
      if v.eq then
         soundData = love.sound.newSoundData(instruments[1].sounds[1].sample.path  )
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

         instruments[1].sounds[1].sample.soundData = soundData
         instruments[1].sounds[1].sample.sound = sound

         local loopStart = instruments[1].sounds[1].sample.loopStart
         local loopEnd = instruments[1].sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instruments[1].sounds[1].sample.fullSoundData = soundData
            instruments[1].sounds[1].sample.soundData = soundData
            
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount()-1)

            instruments[1].sounds[1].sample.loopPointParts = {begin=begin, middle=middle, after=after}
         end
         
         
         love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
      end

   end
   
end


while(run ) do
   if #activeSources == 0 then
      --      print('no one here')
   end
   
   

   for i =1, #activeSources do
      local settings = activeSources[i].instrument.settings
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
            activeSources[i].sound:queue(activeSources[i].pickedInstrumentSound.sample.loopPointParts.middle)
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

         if activeSources[i].glideFromPitch then
            newPitch = newPitch + (vibratoPitchOffset)/2
         else
            newPitch =  getPitch(activeSources[i])  + (vibratoPitchOffset)
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
         activeSources[i].sound:stop()
         table.remove(activeSources, i)
         hasRemovedOne = true
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

   if isPlaying==true then

      timeSinceStartPlay = timeSinceStartPlay + delta

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

         for t = #triggeredPlayNotes, 1, -1 do
            local p = triggeredPlayNotes[t]
            if ((p.startTick + p.length) == wholeTick) then
               stopNote(p.key, instruments[activeInstrumentIndex])
               table.remove(triggeredPlayNotes, t)
            end
         end
         

         if notes[wholeTick] ~= nil then
            for i = 1, #notes[wholeTick] do
               local n = notes[wholeTick][i]
               playNote(n.key, n.velocity, instruments[activeInstrumentIndex])
               table.insert(triggeredPlayNotes, n)
            end
         end

         love.thread.getChannel( 'audio2main' ):push({tick=wholeTick})

         if wholeTick % ticksPerUnit == 0 then
            local pitch = 1
            --print(timeSinceStartPlay)
            beatAndBar.beat = beatAndBar.beat + 1
            if beatAndBar.beat > unitsPerBar then
               beatAndBar.beat = 1
               beatAndBar.bar = beatAndBar.bar + 1
               pitch = 1.5
               
            end
            if metronomeOn then
               metronomeBeat:setPitch(pitch)
               metronomeBeat:play()
            end
            love.thread.getChannel( 'audio2main' ):push({beatAndBar=beatAndBar})
         end
      end

      lastTick = tick
      
   end
   
   

   
   love.timer.sleep(0.001)
   
end

