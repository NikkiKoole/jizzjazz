require('love.timer')
require('love.sound')
require('love.audio')
require('love.math')
require 'soundStuff'
sone = require 'sone'
require 'instrument'
--https://github.com/danigb/timestretch/blob/master/lib/index.js
--ffi = require 'ffi'
--print(ffi)
--ffi.load()
--ffi.load(love.filesystem.getSource().."/".."luamidi.so") 
--local inspect = require "inspect"

--luamidi = require (love.filesystem.getSaveDirectory() .. '/' .. 'luamidi')
--print(love.filesystem.getSource().."/"..'luamidi')
--luamidi = require(love.filesystem.getSource().."/"..'luamidi')

luamidi = require "luamidi"

local now = love.timer.getTime()
local time = 0
local lastTick = -1
local run = false
local isPlaying = false
local timeData = nil
local beatAndBar = nil
local timeSinceStartPlay = 0
local activeChannelIndex = 1
local recordingNotes = {}
local triggeredPlayNotes = {}
local triggeredPianoRollPlayNotes = {} -- they come from clicking
-- the note in the piano roll
local metronomeBeat = love.audio.newSource("assets/samples/cr78/Rim Shot.wav", 'static')
local metronomeOn = false
local preroll = false
local isLooping = false
local loopCounter = 1

-- I WANT A LITTLE BIT OF THIS
-- https://www.onemotion.com/chord-player/
-- https://chordchord.com/

metronomeBeat:setVolume(0.5)
channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main

function ends_with(str, ending)
   return ending == "" or str:sub(-#ending) == ending
end

function getQueueable(s)
   return love.audio.newQueueableSource(
      s:getSampleRate( ), s:getBitDepth(), s:getChannelCount(), 8
   )
end



function loadAndFillInstrument(instrument)
   return loadAndFillInstrumentRaw(instrument)
end

function readAsInstrumentFile(path)
   contents, size = love.filesystem.read( 'assets/instruments/'..path )
   local instr = (loadstring(contents)())
   instr.path = path
   return instr
end
function readAsDrumKitFile(path)
   contents, size = love.filesystem.read( 'assets/drumkits/'..path )
   local instr = (loadstring(contents)())
   instr.path = path
   return instr
end

local instruments = {}
local notesPerChannel = {}

function buildInstrumentsForDrumKit(drumkitIndex)
   for i =1 , #instruments[drumkitIndex].sounds do
       local thing = instruments[drumkitIndex].sounds[i]
       instruments[drumkitIndex+i] = createDrumInstrument(thing.sample.path)
       instruments[drumkitIndex+i].path = string.gsub(thing.sample.path, "assets/samples/", "")
       instruments[drumkitIndex+i].kind = thing.sample.kind or "" 
       instruments[drumkitIndex+i].sounds[1].adsr.attack = 0.00001
       instruments[drumkitIndex+i].isDrumKitPart = true
   end
   
end

function giveInstrumentsNotesIfNeeded()
   for i=1, #instruments do
      if not notesPerChannel[i] then
         notesPerChannel[i] = {}
      end
   end
end


--instruments[1] =  loadAndFillInstrument(readAsInstrumentFile("bass-upright.lua"))

instruments[1] =  loadAndFillInstrument(readAsInstrumentFile("rhodes-all.lua"))
instruments[2] =  loadAndFillInstrument(readAsInstrumentFile("guitar-jazz.lua"))
instruments[3] =  loadAndFillInstrument(readAsInstrumentFile("recorder.lua"))
instruments[4] =  loadAndFillInstrument(readAsInstrumentFile("banjo.lua"))
instruments[5] =  loadAndFillInstrument(readAsDrumKitFile("drumkit-cr78.lua"))
buildInstrumentsForDrumKit(5)

giveInstrumentsNotesIfNeeded()
-- for i =1 , #instruments[5].sounds do
--    local thing = instruments[5].sounds[i]
--    instruments[5+i] = createDrumInstrument(thing.sample.path)
--    instruments[5+i].path = string.gsub(thing.sample.path, "assets/samples/", "")
--    instruments[5+i].kind = thing.sample.kind or "" 
--    instruments[5+1].sounds[1].adsr.attack = 0.00001
--    instruments[5+i].isDrumKitPart = true
-- end




--print(inspect(instruments[2]))

--instruments[7] =  loadAndFillInstrument(getDefaultInstrument())
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

function getFirstIndexOfInstrument(instr)
   for i =1, #instruments do
      if instruments[i] == instr then return i end
   end
   return -1
   
end

function getFirstInActiveSource(instrument)
   for i =1, #activeSources do
      if activeSources[i].instrument == instrument then
         return i
      end
   end
   return 0
end


function playNote(semitone, velocity, channelIndex )
   --print( 'playNote',semitone, velocity, channelIndex )
   local instrument = instruments[channelIndex]
   local settings = instrument.settings
   local sound = getSoundForSemitoneAndVelocity(semitone, velocity, instrument)
   
   local transpose = instrument.settings.transpose
   local adsr = sound.adsr 
   
   love.thread.getChannel( 'audio2main' ):push({playSemitone=semitone+transpose})

   local alreadyInUseIndex = getFirstInActiveSource(instrument) -- this should also be done with a channel index instead
   
   if (settings.glide or settings.monophonic) and #activeSources > 0 and alreadyInUseIndex > 0 then
      local index = alreadyInUseIndex --findIndexFirstNonEchoNote()
      assert(#activeSources > 0)
      activeSources[index].instrument = instrument
      activeSources[index].channelIndex = channelIndex
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

      -- if length then
      --    print('hi yes?')
      --     activeSources[alreadyInUseIndex].noteOffTime = now +length
      --  end
       

   else
      local s2
      local usingLoopPoints = false
      if sound.sample.loopPointParts then
         usingLoopPoints = true
         s2 = getQueueable(sound.sample.soundData)
         s2:queue(sound.sample.loopPointParts.begin)
      else
         s2 = sound.sample.sound:clone()
         --s2:seek(0)
      end
      
      local s = {sound = s2,
                 instrument = instrument,
                 pickedInstrumentSound = sound,
                 key = semitone,
                 channelIndex = channelIndex,
                 noteOnTime = now,
                 noteOnVelocity = velocity,
                 noteOffTime = -1 ,
                 usingLoopPoints = usingLoopPoints,
                 loopParts = sound.sample.loopPointParts,
                 fullSound = sound.sample.fullSoundData }
      
      if settings.useSustain == false then
         if settings.usePitchForADSR then
            s.noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release)/getPitch(s)
         else
            s.noteOffTime = now  + (adsr.attack + adsr.decay + adsr.release)
         end
         
         s.noteOffVolume = adsr.sustain
      end

      -- this is trying to fix the issue but failing
      if instrument.isDrumKitPart then
         s.noteOnTime = now - 0.0001
         s.noteOffTime = now + s.fullSound:getDuration()
         s.noteOffVolume = adsr.sustain
      end

      if settings.useVanillaLooping then
         if not s.loopParts then
            s.sound:setLooping(true)
         end
--         print('looping = true')
      else
--         print('looping = false')
      end
      

      --if length ~= nil then
         
      --    local perS = ( (timeData.tempo / 60) * 96) -- what you would use in 1 second
      --    s.noteOffTime = now  + (length / perS)
      --    s.noteOffVolume = 0.5  -- todo!
     -- end
      
      --print(s.noteOffTime - s.noteOnTime, s.noteOffVolume)
      s.sound:setPitch(getPitch(s))
      s.sound:setVolume(0)
      if instrument.isDrumKitPart then
         s.sound:setVolume(adsr.sustain)
      end
       --s.sound:setVolume(adsr.sustain)
      --print('in playnote', semitone, velocity, channel)
      s.sound:play()
      love.thread.getChannel( 'audio2main' ):push({soundStartPlaying=s})
      love.thread.getChannel( 'audio2main' ):push({soundData=s.fullSound})
      table.insert(activeSources, s)

      -- if length then
      --    print('hi yes 2?')
      --     s.noteOffTime = now +length
      --  end
       
   end


  
   love.thread.getChannel( 'audio2main' ):push({activeSources=activeSources})

end



function stopNote(semitone, channelIndex)
   
   -- -- todo lets just send the appropriate channel indexes from somewhere
   for i=1, #activeSources do

      --print(activeSources[i].released)
      if  not activeSources[i].released and semitone == activeSources[i].key and (channelIndex == activeSources[i].channelIndex) then
         
         if activeSources[i].instrument.settings.useSustain == true then
            activeSources[i].noteOffTime = now
            activeSources[i].noteOffVolume = activeSources[i].sound:getVolume()
         end
         activeSources[i].released = true
         --print('did stop ', semitone)

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
   local result = pitches[index] or 1 
   return result
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
         --print('before phase', volume??)
      elseif attackTime >=0 and attackTime <= attack then
         volume = mapInto(attackTime, 0, attack, 0, adsr.max)
--         print('attack phase', volume, attackTime , attack)
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
   end
   if attackTime < 0 then
      volume = 0
   end
   
   if volume < 0 then
      volume = 0
   end

     return volume
end

function recordPlayedNote(semitone, velocity, channel)
   if recordingNotes[channel] == nil then
      recordingNotes[channel] = {}
   end
   
   recordingNotes[channel][semitone] = {semitone=semitone,
                        velocity=velocity,
                        tick=math.ceil(lastTick)}
end

function recordStoppedNote(b, channel)
   if recordingNotes[channel] == nil then
      recordingNotes[channel] = {}
      print('workaround this sound still nedds to be stopped')
   end
   
   local me = recordingNotes[channel][b]
--   print('stop ', b, channel)

   
   if me then
      local tick =  math.ceil(lastTick)

      --print(channel, me.tick)
      --print(inspect(notesPerChannel))
      
     
      
      local node = {key=me.semitone,
                    velocity=me.velocity,
                    length=tick - me.tick,
                    startTick=me.tick }

      if isLooping then
         print('you might ', loopCounter, 'wanna have an arry of takes ' )
      end

      assert(notesPerChannel[channel])
      local current = notesPerChannel[channel][me.tick]

      if current ~= nil then
         table.insert(notesPerChannel[channel][me.tick], node)
      else
         current = {node}
         notesPerChannel[channel][me.tick] = current
      end
      --print(inspect(notesPerChannel))
      
      --recordingNotes[b] = nil
      love.thread.getChannel( 'audio2main' ):push({notes=notesPerChannel})
   end
end

function stopAllNotes()
         for ti =#triggeredPlayNotes, 1 , -1 do
            local p = triggeredPlayNotes[ti]
            stopNote(p.key, p.channelIndex)
            table.remove(triggeredPlayNotes, ti)
         end
         
      end

function handleMIDIInput()
   if luamidi and luamidi.getinportcount() > 0 then
      local msg, semitone, velocity, d = nil
      msg,semitone,velocity,d = luamidi.getMessage(0)
      --https://en.wikipedia.org/wiki/List_of_chords
      --local integers = {0, 4,7,11}
      local integers = {0}

      --local integers = {0, 4, 7, 11}
      --local integers = {0, 3, 7, 9}
      if msg ~= nil then
         -- look for an NoteON command

         if msg == 144 then
            --local semitone = b
            local channel = activeChannelIndex
            local instrument = instruments[activeChannelIndex]
            
            if (instrument.isDrumKit) then
                local amt = #instrument.sounds
                local index = (semitone % amt)+1
                channel = activeChannelIndex + index
                --semitone = 60
                love.thread.getChannel( 'audio2main' ):push({triggeredDrumPart=channel})
            end
           -- print('playNote: ',semitone, velocity, channel )
            playNote(semitone, velocity, channel)
           
            
            if isPlaying and isRecording then
               recordPlayedNote(semitone, velocity, channel)
            end
            
            lastHitMIDISemitone = semitone
         elseif msg == 128 then
            --local semitone = b
            local channel = activeChannelIndex
            local instrument = instruments[activeChannelIndex]
            if (instrument.isDrumKit) then
                local amt = #instrument.sounds
                local index = (semitone % amt)+1
                channel = activeChannelIndex + index
               -- semitone = 60
            end
            stopNote(semitone, channel)
            if isPlaying and isRecording then
               recordStoppedNote(semitone, channel)
               
            end
         elseif msg == 153 or msg == 137 then
            local channel = activeChannelIndex
            local instrument = instruments[activeChannelIndex]
            if (instrument.isDrumKit) then
               local amt = #instrument.sounds
               local index = (semitone % amt)+1
               channel = activeChannelIndex + index
               semitone = 60
            end
            
            if msg== 153 then 
               playNote(semitone, velocity, channel)
               
               
               if isPlaying and isRecording then
                  recordPlayedNote(semitone, velocity, channel)
               end
               lastHitMIDISemitone = semitone
            end
            if msg== 137 then 
               
               stopNote(semitone, channel)
            if isPlaying and isRecording then
               recordStoppedNote(semitone, channel)
               
            end
            end
            
         
         elseif msg == 176 then
            if semitone == 2 then
               --instruments[1].settings.vibratoSpeed = 96/ math.max(c,1)
            elseif semitone == 3 then
               --instruments[1].settings.vibratoStrength = math.max(c,1)

            else
               print('knob', semitone,velocity)
            end

         elseif msg == 224 then
            pitchNote(velocity)
         else
            print("unknown midi message: ", msg, semitone,velocity,d)
         end
      end
   end
   

end

function handleThreadInput()
   local v = channel.main2audio:pop();
   if v then

      if v.activeChannelIndex ~= nil then
         -- this tries to stop sounds that will get stuck after the switch
         -- this also needs to be doen when changin an instrument on the same channel
         for i = 1, #activeSources do
            if activeSources[i].key == lastHitMIDISemitone then
              -- activeSources[i].channelIndex = v.activeChannelIndex
               if activeSources[i].noteOffTime == -1 then
                  activeSources[i].noteOffTime = now
                  activeSources[i].noteOffVolume = activeSources[i].sound:getVolume()
                  activeSources[i].released = true
               end
            end
         end
         
         activeChannelIndex = v.activeChannelIndex
      end
      if v.playNotePianoRoll ~= nil then
         local thing = v.playNotePianoRoll
         --playNote(thing.key, thing.velocity, activeChannelIndex, thing.length)

         thing.channelIndex = activeChannelIndex
         thing.startTick = now
         --print(inspect(thing))
         playNote(thing.key, thing.velocity, thing.channelIndex)
         table.insert(triggeredPianoRollPlayNotes, thing)
          
         --print('yeeah and now?', inspect(thing))
         
      end
      
      if v.metronomeOn ~= nil then
         metronomeOn = v.metronomeOn
      end
      if v.preroll ~= nil then
         preroll = v.preroll
      end
       if v.isLooping ~= nil then
         isLooping = v.isLooping
      end
      
      if v.isRecording ~= nil then
         isRecording = v.isRecording
      end
      if v.stopAllNotes then
         stopAllNotes()
         
      end

   
      if v.isPlaying ~= nil then
         isPlaying = v.isPlaying
         if isPlaying == false and isLooping == true and isRecording then
            loopCounter = 1
            print('maybe check notes we have recorded?')
         end
         
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

         if (preroll) then
            local unitsPerBar = timeData.signatureBeatPerBar 
            local ticksPerUnit =  96 / (timeData.signatureUnit/4)
            lastTick = -(ticksPerUnit * unitsPerBar)
            beatAndBar.bar = 0
            love.thread.getChannel( 'audio2main' ):push({beatAndBar=beatAndBar})

         else
            lastTick = 0
         end
         
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


      if v.notes then
         notesPerChannel = v.notes
      end
      
      if v.instrument then
         instruments[activeChannelIndex] = v.instrument
      end

      if v.loadInstrumentsForFile then
         local tab = v.loadInstrumentsForFile
         --print(#tab)
         print('should do a whole lotta loading')
         for i=1, #tab do
            if ends_with(tab[i].path, '.lua') then
               print(i, tab[i].path)
               if i < 5 then
                  local instrument = loadAndFillInstrument(readAsInstrumentFile(tab[i].path))
                  instruments[i] = instrument
                  instruments[i].path = tab[i].path
               end
               --print(instrument.isDrumKit)
            end
            
            --print(tab[i].path)
         end
         love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
      end
      
      
      if v.loadInstrument then
         print('load instrument', v.loadInstrument)
         -- maybe clean out my old children if im drumkit
         if instruments[activeChannelIndex].isDrumKit then
            for i = 1, #instruments[activeChannelIndex].sounds do
               instruments[activeChannelIndex+i] = nil
            end
         end
         

         print(v.loadInstrument.instrument)
         instruments[activeChannelIndex] = loadAndFillInstrument(v.loadInstrument.instrument)
         if instruments[activeChannelIndex].isDrumKit then
            print("itsa drumkit")
            buildInstrumentsForDrumKit(activeChannelIndex)

         end
         
         instruments[activeChannelIndex].path = v.loadInstrument.path
         giveInstrumentsNotesIfNeeded()
         love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
      end
      
      if v.adsr then
         -- this cant be good
         instruments[activeChannelIndex].sounds[1].adsr = v.adsr
      end

      if v.instrumentStartEnd then
         local d = v.instrumentStartEnd
         -- this cant be good
         local loopStart = d.sounds[1].sample.loopStart
         local loopEnd = d.sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instruments[activeChannelIndex].sounds[1].sample.loopStart = loopStart
            instruments[activeChannelIndex].sounds[1].sample.loopEnd =loopEnd
            local soundData = instruments[activeChannelIndex].sounds[1].sample.soundData
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount())
            instruments[activeChannelIndex].sounds[1].sample.loopPointParts =
               {begin=begin, middle=middle, after=after}
         end
      end
      
      if v.osc  then
         instruments[activeChannelIndex] =  getDefaultInstrument()
         
         instruments[activeChannelIndex].settings.useVanillaLooping = true
         instruments[activeChannelIndex].sounds[1].sample.loopStart= nil
         instruments[activeChannelIndex].sounds[1].sample.loopEnd= nil
         instruments[activeChannelIndex].sounds[1].sample.loopPointParts = nil
         instruments[activeChannelIndex].sounds[1].sample.path = v.osc.fullPath
         instruments[activeChannelIndex].path = v.osc.path
         loadAndFillInstrument(instruments[activeChannelIndex])
         love.thread.getChannel( 'audio2main' ):push({instruments=instruments})
       
      end
      
      if v.eq then
         soundData = love.sound.newSoundData(instruments[activeChannelIndex].sounds[1].sample.path  )
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

         instruments[activeChannelIndex].sounds[1].sample.soundData = soundData
         instruments[activeChannelIndex].sounds[1].sample.sound = sound

         local loopStart = instruments[activeChannelIndex].sounds[1].sample.loopStart
         local loopEnd = instruments[activeChannelIndex].sounds[1].sample.loopEnd 

         if loopStart and loopEnd then
            instruments[activeChannelIndex].sounds[1].sample.fullSoundData = soundData
            instruments[activeChannelIndex].sounds[1].sample.soundData = soundData
            
            local begin = writeSoundData(soundData, 0, loopStart)
            local middle = writeSoundData(soundData, loopStart, loopEnd)
            local after = writeSoundData(soundData, loopEnd, soundData:getSampleCount()-1)

            instruments[activeChannelIndex].sounds[1].sample.loopPointParts = {begin=begin, middle=middle, after=after}
         end
         
         
         love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
      end

   end
   
end


while(run ) do
   if #activeSources == 0 then
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
      local vel = (activeSources[i].noteOnVelocity/127.0)
      --print(v * vel, activeSources[i].noteOnTime, activeSources[i].noteOffTime)

      local channelVolumeMultiplier = activeSources[i].instrument.channelVolume or 1
      activeSources[i].sound:setVolume(v * vel * channelVolumeMultiplier)
      

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
         if activeSources[i].sound:getVolume() < 0.00001 and now >= activeSources[i].noteOnTime then
            activeSources[i].sound:setVolume(0)
            activeSources[i].remove = true
         end
      end
   end
   
   handleMIDIInput()
   handleThreadInput()

   local n = love.timer.getTime()
   local delta = n - now
   now = n
   time = time + delta
   print(delta <  1/44100)
   local pulses_per_quarter_note = 96
   local unitsPerBar = timeData.signatureBeatPerBar 
   local ticksPerUnit = pulses_per_quarter_note / (timeData.signatureUnit/4)
   local tickPerBar = timeData.signatureBeatPerBar * ticksPerUnit
   local loopWidth = 4 * tickPerBar

   for pp = #triggeredPianoRollPlayNotes, 1,-1 do
      local tickdelta = (delta * (timeData.tempo / 60) * 96)
      local tick = lastTick + tickdelta
      local thing = triggeredPianoRollPlayNotes[pp]
      if now > thing.startTick + thing.length/((timeData.tempo / 60) * 96) then
         stopNote(thing.key, thing.channelIndex)
         table.remove(triggeredPianoRollPlayNotes, pp)
      end
      --lastTick\\\\\
      
      
      --if math.floor(tick) ~= math.floor(lastTick) then
      --   print(inspect(thing), tick)
      --end
   end
   
   if isPlaying==true then

      timeSinceStartPlay = timeSinceStartPlay + delta

     
      local tickdelta = (delta * (timeData.tempo / 60) * 96)
      local tick = lastTick + tickdelta


      
      
      
      if math.floor(tick) - math.floor(lastTick) > 1 then
         print('thread: missed ticks:', math.floor(tick), math.floor(lastTick))
      end

     
      
      if math.floor(tick) ~= math.floor(lastTick) then
         
         local wholeTick = math.ceil(tick)
         
         
         
         for t = #triggeredPlayNotes, 1, -1 do
            local p = triggeredPlayNotes[t]
            --print((p.startTick + p.length) == wholeTick, p.startTick, p.length, wholeTick)
            if ((p.startTick + p.length) == wholeTick) then
               stopNote(p.key, p.channelIndex)
               table.remove(triggeredPlayNotes, t)
            end
         end
         
         for j=1, #notesPerChannel   do
            if notesPerChannel[j][wholeTick] ~= nil then
               for i = 1, #notesPerChannel[j][wholeTick] do
                  if instruments[j] then
                     local n = notesPerChannel[j][wholeTick][i]
                     n.channelIndex = j
                     playNote(n.key, n.velocity, j)
                     table.insert(triggeredPlayNotes, n)
                  else
                     print('skipped a play on a no longer existing channel', j)
                  end
                  
               end
            end
         end
         
         
         

         love.thread.getChannel( 'audio2main' ):push({tick=wholeTick})

         if wholeTick % ticksPerUnit == 0 then
            local pitch = 1

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
            --if lastTick >= 0 then
            love.thread.getChannel( 'audio2main' ):push({beatAndBar=beatAndBar})
            --end
         end
      end

      lastTick = tick

      -- doing the loop
      if isLooping then
         if lastTick > loopWidth then
            loopCounter = loopCounter + 1
            print('loop / take ', loopCounter)
            lastTick = 0
            beatAndBar.beat = 1
            beatAndBar.bar = 1
            love.thread.getChannel( 'audio2main' ):push({beatAndBar=beatAndBar})
         end
      end
      
   end
   
   

   
   --love.timer.sleep(0.001)
   
end

