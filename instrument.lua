pitches = {}


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



function getDefaultInstrument()
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         useEcho = false,

         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      --"assets/samples/rhodes/A_055__G3_3.wav"
      --"assets/samples/SIDSQUAW.wav"
      sounds = {
         {
            sample = {
               path="assets/samples/Upright Bass F#2.wav",
               loopStart=6376,
               loopEnd=6676,
               root=60,
               
            },
         }
      },

      
   }
end
