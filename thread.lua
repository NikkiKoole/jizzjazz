require('love.timer')
require('love.sound')
require('love.audio')
require('love.math')
sone = require 'sone'

--https://github.com/danigb/timestretch/blob/master/lib/index.js

luamidi = require "luamidi"
local inspect = require "inspect"
local now = love.timer.getTime()
local time = 0
local lastTick = 0
local run = false

channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main
--oscUrl = 'assets/oscillators/AKWF_fmsynth/AKWF_fmsynth_0101.wav'
oscUrl = 'assets/samples/rhodes/A_055__G3_3.wav'
--oscUrl = 'assets/samples/Cymbal.wav'
--oscUrl = 'assets/samples/Bongo High.wav'
useLooping = false
soundData = love.sound.newSoundData( oscUrl )
sound = love.audio.newSource(soundData, 'static')
--sound:play()
love.thread.getChannel( 'audio2main' ):push({soundData=soundData})

activeSources = {}
pitches = {}

adsr = {
   attack = 0.01,
   max   = .90,
   decay = 0.0,
   sustain= .70,
   release = .02,
}

glide = false        -- glide is always monophonic
glideDuration = .5
monophonic = false
useSustain = true
useEcho = false

vibrato = true
vibratoSpeed = 96/96
vibratoStrength = 10  -- this should be in semitones

transpose = 0
filterfreq = 1

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

function findIndexFirstNonEchoNote()
   local result = 1
   for i =1 , #activeSources do
      if not activeSources[1].isEcho then
         result = i
      end
   end
   return result
end


function playNote(semitone, velocity)

   love.thread.getChannel( 'audio2main' ):push({playSemitone=semitone+transpose})

   local usedSource = nil
   if (glide or monophonic) and #activeSources > 0 then
      local index = findIndexFirstNonEchoNote()
      assert(#activeSources == 1 or index > 1)
       activeSources[index].key = semitone
       activeSources[index].released = nil
       activeSources[index].noteOnTime=now
       
      if glide then
         activeSources[index].glideFromPitch = activeSources[index].sound:getPitch()
         activeSources[index].glideStart = now
         activeSources[index].noteOffTime=-1
      end
       if monophonic then
         activeSources[index].noteOffTime=-1
      end
      if useSustain == false then
         activeSources[index].noteOffTime = now  + adsr.attack + adsr.decay + adsr.release 
         activeSources[index].noteOffVolume = adsr.sustain
      end

      usedSource = activeSources[index]
   else
      
      local s = {sound=sound:clone(), key=semitone, noteOnTime=now, noteOffTime=-1  }

      ----- trigger noteoff immeadially shoudl b

      if useSustain == false then
         s.noteOffTime = now  + adsr.attack + adsr.decay + adsr.release
         s.noteOffVolume = adsr.sustain
      end
      -----

      if useLooping then
         s.sound:setLooping(true)
      end
      s.sound:setPitch(getPitch(s))
      s.sound:setVolume(0)
      s.sound:play()
      table.insert(activeSources, s)
      
      usedSource = s
   end

   if useEcho then
--      local echoTicks = { 0.3, 0.45, 0.55, 0.60, 0.62}
      for i = 1, 5 do
         local echoTimeOffset = 0.5*i
         local echoSound = {sound=usedSource.sound:clone(),
                            key=usedSource.key,
                            released = true,
                            isEcho=true,
                            echoVolumeMultiplier = 1.0 - (i/10),
                            echoTimeOffset = echoTimeOffset,
                            noteOnTime=usedSource.noteOnTime + echoTimeOffset,
                            noteOffVolume = usedSource.noteOffVolume or 0,
                            noteOffTime=usedSource.noteOffTime + echoTimeOffset}
         if useSustain then
            echoSound.noteOffTime = -1
         end
         echoSound.sound:setLooping(true)
         echoSound.sound:setPitch(getPitch(echoSound))
         echoSound.sound:setVolume(0)
         echoSound.sound:play()
         table.insert(activeSources, echoSound)
      end
    end
    --print('inserting echo')
    --
        
   --print(inspect(usedSource))
   
end

function stopNote(semitone)
   for i=1, #activeSources do
      if semitone == activeSources[i].key then
         
         if useSustain == true then
            activeSources[i].noteOffTime = now
         end
         
         if activeSources[i].isEcho then
            activeSources[i].noteOffTime = now + activeSources[i].echoTimeOffset
         end
         
         activeSources[i].noteOffVolume = activeSources[i].sound:getVolume()
         activeSources[i].released = true
      end
   end
end

function getPitch(activeSource, offset)
   local index = activeSource.key + (offset or 0) + transpose
   --print(activeSource.key, index,pitches[index])
   return pitches[index]
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

function getVolumeASDR(now, noteOnTime, noteOffTime, noteOffVolume,asdr, isEcho)
   local volume = 0
   local attackTime = (now - noteOnTime)
   
   if noteOffTime == -1 or noteOffTime > now  then 
      
      if attackTime < 0 then
         volume = 0
      elseif attackTime >=0 and attackTime <= adsr.attack then
         volume = mapInto(attackTime, 0, adsr.attack, 0, adsr.max)
         --print('attack phase', volume)
      elseif attackTime <= adsr.attack + adsr.decay then
         volume = mapInto(attackTime - adsr.attack, 0, adsr.decay, adsr.max, adsr.sustain)
          --print('decay phase', volume)
      elseif attackTime > adsr.attack + adsr.decay then
         volume = adsr.sustain
        -- print('sustain phase', volume)

      end
      
   else
      local releaseTime = now - noteOffTime
      volume = mapInto(releaseTime, adsr.release, 0, 0, noteOffVolume)
       --print('release phase', volume)

   end
    if attackTime < 0 then
       volume = 0
    end
    
    if volume < 0 then volume = 0 end
   return volume  
end


local mySound = {
   -- can be of a few kinds
   -- 1) osc/ always looping heavily using asdr etc   -- static
   -- 2) one shot samples
   -- 3) looping samples, with start and end looppoints  -- queue
   source='somewav',
   asdr = {},
   usesLoopPoints = {12,23230} or nil
   
}


while(run) do
   --print(#activeSources)
   for i =1, #activeSources do
      
      local v = getVolumeASDR(now, activeSources[i].noteOnTime, activeSources[i].noteOffTime, activeSources[i].noteOffVolume, asdr, activeSources[i].isEcho)
      --print(v)
      if activeSources[i].echoVolumeMultiplier then
         v = v * activeSources[i].echoVolumeMultiplier 
      end
      

      activeSources[i].sound:setVolume(v)
      
      -- glide / portamento
      local pitch =  getPitch(activeSources[i])
      local newPitch = pitch

      if glide then
         if activeSources[i].glideFromPitch then
            local glideTime =  (now - activeSources[i].glideStart)
            newPitch = mapInto(glideTime, 0, glideDuration,
                               activeSources[i].glideFromPitch,
                               getPitch(activeSources[i]))
            if glideTime > glideDuration then
               newPitch = getPitch(activeSources[i])
               activeSources[i].glideFromPitch = nil
            end
         end
      end
      
      if vibrato then
         local vibratoSmallPitchDiff =  (getPitch(activeSources[i]) - getPitch(activeSources[i], 1) ) 
         local vibratoPitchOffset = math.sin(time * vibratoSpeed) *  vibratoSmallPitchDiff/(vibratoStrength) -- [-1, 1]
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

   
   for i = #activeSources, 1, -1 do
      if activeSources[i].released == true then
         local remove = false
         if activeSources[i].sound:getVolume() < 0.0001 and now > activeSources[i].noteOnTime then
            activeSources[i].sound:stop()
            remove = true
         end
         
         if remove then
            table.remove(activeSources, i)
         end

      end
   end

  
   
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
            playNote(b, c)
         elseif a == 128 then
            stopNote(b)
         elseif a == 176 then
            if b == 2 then
               vibratoSpeed = 96/ math.max(c,1)
               print('vibratospeed', vibratoSpeed)
            elseif b == 3 then
               vibratoStrength = math.max(c,1)
               print('vibratoStrength', vibratoStrength)
            else
               print('knob', b,c)
            end
            
            
            --lfoThing = c
         elseif a == 224 then
            pitchNote(c)
         else
            
            print("unknown midi message: ", a, b,c,d)
         end
      end
   end
   

   
   local v = channel.main2audio:pop();
   if v then
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
      
      if v.osc  then
         useLooping = true
          oscUrl = v.osc
          soundData = love.sound.newSoundData( v.osc )
      --    -- sone.filter(soundData, {
      --    --                 type = "highpass",
      --    --                 frequency = 5000,
      --    -- })
      --    sone.filter(soundData, {
      --                    type = "lowpass",
      --                    frequency = filterfreq,
      --    })
      --    --print(sound)
          sound = love.audio.newSource(soundData, 'static')
          love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
      end
      if v.adsr then
         print('adsr!', inspect(v.adsr))
         adsr = v.adsr
      end
      
      if v.eq then
         soundData = love.sound.newSoundData(oscUrl)
         -- sone.filter(soundData, {
         --                  type = "highshelf",
         --                  frequency =  v.eq.lowpass.frequency,
         --                  Q=v.eq.lowpass.q,
         --                  gain = v.eq.lowpass.gain                      
                        
         -- })
         --sone.fadeOut(soundData, 0.15)
         --sone.amplify(soundData, v.eq.lowpass.gain)


         
       
         
         sone.filter(soundData, {
                          type = "lowshelf",
                          frequency = v.eq.lowshelf.frequency,
                          Q=v.eq.lowshelf.q,
                          wet=v.eq.lowshelf.wet,
                          gain = v.eq.lowshelf.gain                      
                        
         })
         sone.filter(soundData, {
                          type = "highshelf",
                          frequency = v.eq.highshelf.frequency,
                          Q=v.eq.highshelf.q,
                          wet=v.eq.highshelf.wet,
                          gain = v.eq.highshelf.gain                      
                        
         })

         sone.filter(soundData, {
                          type = "highpass",
                          frequency = v.eq.highpass.frequency,
                          Q=v.eq.highpass.q,
                          wet=v.eq.highpass.wet,
         })

         sone.filter(soundData, {
                          type = "lowpass",
                          frequency = v.eq.lowpass.frequency,
                          Q=v.eq.lowpass.q,
                          wet=v.eq.lowpass.wet,
         })

        
         sone.filter(soundData, {
                          type = "bandpass",
                          frequency = v.eq.bandpass.frequency,
                          Q=v.eq.bandpass.q,
                          wet=v.eq.bandpass.wet,

         })
         -- print(inspect(v.eq))
         sone.fadeOut(soundData, v.eq.fadeout)
         sone.fadeIn(soundData, v.eq.fadein)
         sound = love.audio.newSource(soundData, 'static')
         love.thread.getChannel( 'audio2main' ):push({soundData=soundData})
      end
      
      --channel.main2audio:push ( {eqcutoff = eqcutoff.value} );
      
            --channel.a:push ( "bar" )
   end
   
   
   local n = love.timer.getTime()
   local delta = n - now
   local result = ((delta * 1000))
   
   now = n
   time = time + delta
   local bpm = 300
   local beat = time * (bpm / 60)
   local tick = ((beat % 1) * (96))
   if math.floor(tick) - math.floor(lastTick) > 1 then
      print('thread: missed ticks:', math.floor(beat), math.floor(tick), math.floor(lastTick))

   end

   if math.floor(tick) ~= math.floor(lastTick) then
      if math.floor(tick)  % 96 == 0  then

	 --local s = sound:clone()
	 --s:setPitch(math.random()*30)
	 --love.thread.getChannel( 'a' ):push("note played")
	 --love.audio.play(s)
      end
      
      --print( math.floor(tick), math.floor(lastTick))
   end
   

   lastTick = tick
   love.timer.sleep(0.001)
   
end

