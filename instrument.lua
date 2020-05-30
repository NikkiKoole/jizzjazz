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
            samples = {{
                  path= "assets/samples/rhodes/A_055__G3_3.wav",
                  --loopStart=112434,
                  --loopEnd=117151,

                 -- path= "assets/samples/begin_nogeenkeer_einde.wav",
                  --loopStart=27522,
                  --loopEnd=68295,

                 -- path="assets/samples/SIDSQUAW.wav",
                  soundData=nil,
                  sound=nil,
                  --transpose = 0, -- this should become the root , that belongs to a sample
            }},
            adsr = {
               attack = 0.01,
               max   = .50,
               decay = 0.0,
               sustain= .50,
               release = .02,
            },
            eq = {
               fadeout = 0,
               fadein = 0,
               lowpass =  vanillaFilter(),
               highpass =  vanillaFilter(),
               bandpass = vanillaFilter(),         
               allpass = vanillaFilter(),
               lowshelf = vanillaFilter(true),
               highshelf = vanillaFilter(true),
            },
         }
      },

      
   }
end
