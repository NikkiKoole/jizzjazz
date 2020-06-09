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

function get808BD()
   function dir(p)
      return "assets/samples/808/BD/"..p
   end

   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
         customDials = {}
      },
   }

end   


function getUprightBass()
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      sounds = {
          {sample = {path="assets/samples//Upright Bass F#2.wav", root=60, loopStart=6376,loopEnd=6676}},
      }
   }
end

function getYoshiVibraphone()
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      adsr = {
         attack = 0.005,
         max   = .50,
         decay = 2.5,
         sustain= .30,
         release = .5,
      },
      sounds = {
         {sample = {path="assets/samples/yoshi/Sample 15-2.wav",loopStart=5470, loopEnd=5738, root=52}},
         {sample = {path="assets/samples/yoshi/Sample 14-2.wav",loopStart=4282, loopEnd=4430, root=62}},
         {sample = {path="assets/samples/yoshi/Sample 13-1.wav",loopStart=7080, loopEnd=7585, root=72}},
      }
   }
   end

function getVibraphone()
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      sounds = {
          {sample = {path="assets/samples/tjappievibe.wav",loopStart=160512, loopEnd=172657, root=60}},
      }
   }
end

function getRecorder()

    return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .15,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      sounds = {
          {sample = {path="assets/samples/Recorder 078.wav",  loopStart=13119+0, loopEnd=20046+0,  root=78}},
      }
    }
end


function getMother3EPiano()
  
      return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      sounds = {
          {sample = {path="assets/samples/Sample @0x14e1f8.wav", loopStart=26553, loopEnd=27820, root=60}},
      }
   }
end


function getSho()
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      sounds = {
          {sample = {path="assets/samples/Sho 060-L.wav",loopStart=169600, loopEnd=213929, root=60}},
      }
   }
end


function getRhodes()
   function dir(p)
      return "assets/samples/rhodes small/"..p
   end
   
   return {
      settings = {
         useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
         glide = false,        -- glide is always monophonic
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10,  -- this should be in semitones
         transpose = 0,
         usePitchForADSR = false,
      },
      
      sounds = {
         {sample = {path= dir("A_029__F1_3.wav"),loopStart=165661, loopEnd=169724, root=29, rootVelocity=50}},
         {sample = {path= dir("A_035__B1_3.wav"),loopStart=119965, loopEnd=122111, root=35, rootVelocity=50}},
         {sample = {path= dir("A_040__E2_3.wav"),loopStart=131975, loopEnd=134638, root=40, rootVelocity=50}},
         {sample = {path= dir("A_045__A2_3.wav"),loopStart=117892, loopEnd=123090, root=45, rootVelocity=50}},
         {sample = {path= dir("A_050__D3_3.wav"),loopStart=136430, loopEnd=140318, root=50, rootVelocity=50}},
         {sample = {path= dir("A_055__G3_3.wav"),loopStart=112434,loopEnd=117151, root=55, rootVelocity=50}},
         {sample = {path= dir("A_059__B3_3.wav"),loopStart=72198, loopEnd=74161, root=59, rootVelocity=50}},
         {sample = {path= dir("A_062__D4_3.wav"),loopStart=83233, loopEnd=84882, root=62, rootVelocity=50}},
         {sample = {path= dir("A_065__F4_3.wav"),loopStart=86984, loopEnd=88120, root=65, rootVelocity=50}},
         {sample = {path= dir("A_071__B4_4.wav"),loopStart=81475, loopEnd=86821, root=71, rootVelocity=50}},
         {sample = {path= dir("A_076__E5_4.wav"),loopStart=52301, loopEnd=53235, root=76, rootVelocity=50}},
         {sample = {path= dir("A_081__A5_3.wav"),loopStart=70847, loopEnd=73746, root=81, rootVelocity=50}},
         {sample = {path= dir("A_086__D6_3.wav"),loopStart=82297, loopEnd=85256, root=86, rootVelocity=50}},
         {sample = {path= dir("A_091__G6_3.wav"),loopStart=45932, loopEnd=46885, root=91, rootVelocity=50}},
         {sample = {path= dir("A_096__C7_3.wav"),loopStart=46750, loopEnd=47338, root=96, rootVelocity=50}},
      }
   }
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
