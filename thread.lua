require('love.timer')
require('love.sound')
require('love.audio')
require('love.math')
sone = require 'sone'

luamidi = require "luamidi"
local inspect = require "inspect"


local now = love.timer.getTime()
local time = 0
local lastTick = 0
local run = false

channel 	= {};
channel.audio2main	= love.thread.getChannel ( "audio2main" ); -- from thread
channel.main2audio	= love.thread.getChannel ( "main2audio" ); --from main


soundData = love.sound.newSoundData( 'assets/oscillators/AKWF_fmsynth_0101.wav' )
sound = love.audio.newSource(soundData, 'static')


activeSources = {}

pitches = {}

adsr = {
   attack = .1,
   max   = 0.8,
   decay = 0.1,
   sustain= 0.8,
   release = .1,
}

--glide = true
--glideDuration = .05

vibratoSpeed = 96/96
vibratoStrength = 10  -- this should be in semitones


function mapInto(x, in_min, in_max, out_min, out_max)
   return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

for i = 0, 144 do
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
   end

   pitches[i] = pitch
end


if luamidi then
   print("Midi Input Ports: ", luamidi.getinportcount())
   print( 'Receiving on device: ', luamidi.getInPortName(0))
   run = true
end

function findIndexFirstNonReleasedNote()
   local result = 1
   for i =1 , #activeSources do
      if not activeSources[1].released then
         result = i
      end
   end
   return result
end


function playNote(semitone, velocity)
   if glide and #activeSources > 0 then
      local index = 1 --findIndexFirstNonReleasedNote()
      assert(#activeSources == 1)
      activeSources[index].key = semitone
      activeSources[index].glideFromPitch = activeSources[index].sound:getPitch()
      activeSources[index].glideStart = now
      activeSources[index].released = nil 
      activeSources[index].noteOffTime=-1
      activeSources[index].noteOnTime=now
   else
      
      local s = {sound=sound:clone(), key=semitone, noteOnTime=now, noteOffTime=-1  }
      s.sound:setLooping(true)
      s.sound:setPitch(pitches[semitone])
      s.sound:setVolume(0)
      s.sound:play()
      table.insert(activeSources, s)

      -- chorus!!! 
      -- local echo = {sound=sound:clone(), key=semitone, noteOnTime=now+0.005}
      -- echo.sound:setLooping(true)
      -- echo.sound:setPitch(pitches[semitone]*0.999)
      -- echo.sound:setVolume(0)
      -- echo.sound:play()
      -- table.insert(activeSources, echo)

      -- echo2 = {sound=sound:clone(), key=semitone, noteOnTime=now+0.05 }
      -- echo2.sound:setLooping(true)
      -- echo2.sound:setPitch(pitches[semitone]*1.002)
      -- echo2.sound:setVolume(0)
      -- echo2.sound:play()
      -- table.insert(activeSources, echo2)
   end
   
end

function pitchNote(value)
   for i=1, #activeSources do
      local newPitch = mapInto(value, 0, 127,
                               pitches[activeSources[i].key - 1],
                               pitches[activeSources[i].key + 1])
      if value == 64 then
         newPitch =  pitches[activeSources[i].key]
      end
      activeSources[i].pitchDelta =  newPitch - pitches[activeSources[i].key]
   end
   
end

function stopNote(semitone)
   for i=1, #activeSources do
      if semitone == activeSources[i].key then
         activeSources[i].noteOffTime = now
         activeSources[i].noteOffVolume = activeSources[i].sound:getVolume()
         activeSources[i].released = true
      end
   end
end

function getVolumeAndPhaseASDR(now, noteOnTime, noteOffTime, noteOffVolume,asdr)
   local volume = 0
   local phase = ''

   if noteOffTime == -1 then 
      local attackTime = (now - noteOnTime)
      if attackTime < 0 then
         phase = 'before'
         volume = 0
      elseif attackTime >=0 and attackTime <= adsr.attack then
         volume = mapInto(attackTime, 0, adsr.attack, 0, adsr.max)
         phase = 'attack'
      elseif attackTime <= adsr.attack + adsr.decay then
         phase = 'decay'
         volume = mapInto(attackTime - adsr.attack, 0, adsr.decay, adsr.max, adsr.sustain)
      elseif attackTime > adsr.attack + adsr.decay then
         phase = 'sustain'
         volume = adsr.sustain
      end
      
   else 
      phase  = 'released'
      local releaseTime = now - noteOffTime
      volume = mapInto(releaseTime, adsr.release, 0, 0, noteOffVolume)
      
   end
   if volume < 0 then volume = 0 end
   return volume, phase   
end


while(run) do
   
   for i =1, #activeSources do
      -- attack, decay, sustain
      local v,p = getVolumeAndPhaseASDR(now, activeSources[i].noteOnTime, activeSources[i].noteOffTime, activeSources[i].noteOffVolume, asdr)
      --print(v,p)
      activeSources[i].sound:setVolume(v)
 




      
      -- glide / portamento
      local pitch =  activeSources[i].sound:getPitch()
      local newPitch = pitch
      if activeSources[i].glideFromPitch then
         local glideTime =  (now - activeSources[i].glideStart)
         newPitch = mapInto(glideTime, 0, glideDuration,
                                  activeSources[i].glideFromPitch,
                                  pitches[activeSources[i].key])
         if glideTime > glideDuration then
            activeSources[i].glideFromPitch = nil
         end
      end

      -- vibrato
      local vibratoSmallPitchDiff =  ((pitches[activeSources[i].key] -  pitches[activeSources[i].key+1])) 
      local vibratoPitchOffset = math.sin(time * vibratoSpeed) *  vibratoSmallPitchDiff/(vibratoStrength) -- [-1, 1]
      if activeSources[i].glideFromPitch then
         newPitch = newPitch + (vibratoPitchOffset)/2
      else
         newPitch =  pitches[activeSources[i].key]  + (vibratoPitchOffset)--(math.sin(time*vibratoSpeed)/vibratoStrength)
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
         if activeSources[i].sound:getVolume() < 0.0001 then
            activeSources[i].sound:stop()
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
         luamidi.gc()
         run = false
         love.thread.getChannel( 'audio2main' ):push('quit')
      end
      if v.osc  then
         soundData = love.sound.newSoundData( v.osc )
         sound = love.audio.newSource(soundData, 'static')
        
      end
      
            --channel.a:push ( "bar" )
   end
   
   
   local n = love.timer.getTime()
   local delta = n - now
   local result = ((delta * 1000))
   
   now = n
   time = time + delta
   local beat = time * (120 / 60)
   local tick = ((beat % 1) * (96))
   if math.floor(tick) - math.floor(lastTick) > 1 then
      print('thread: missed ticks:', math.floor(beat), math.floor(tick), math.floor(lastTick))

   end

   if math.floor(tick) ~= math.floor(lastTick) then
      if math.floor(tick)  % 32 == 0  then
	 --print(beat, tick)
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

