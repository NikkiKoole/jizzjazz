
function dir(p)
   return "assets/samples/acoustic guitars/70s chorus/"..p
end

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
   
   sounds = {
      {sample = {path= dir("70s Chorus Ab5m.wav"),loopStart=95838, loopEnd=113521-1, root=80}},
       {sample = {path= dir("70s Chorus B4m.wav"),loopStart=47783, loopEnd=56652-1, root=71}},
       {sample = {path= dir("70s Chorus B5m.wav"),loopStart=61938, loopEnd=80864-1, root=83}},
       {sample = {path= dir("70s Chorus Bb2m.wav"),loopStart=107025, loopEnd=167464-1, root=46}},
       {sample = {path= dir("70s Chorus Bb3m.wav"),loopStart=91317, loopEnd=111040-1, root=58}},
       {sample = {path= dir("70s Chorus D5m.wav"),loopStart=51936, loopEnd=66438-1, root=74}},
       {sample = {path= dir("70s Chorus Db3m.wav"),loopStart=114840, loopEnd=132469-1, root=49}},
       {sample = {path= dir("70s Chorus Db4m.wav"),loopStart=85509, loopEnd=105230-1, root=61}},
       {sample = {path= dir("70s Chorus E2m.wav"),loopStart=213276, loopEnd=246754-1, root=40}},
       {sample = {path= dir("70s Chorus E3m.wav"),loopStart=102197, loopEnd=115576-1, root=52}},
       {sample = {path= dir("70s Chorus E4m.wav"),loopStart=90439, loopEnd=114855-1, root=64}},
       {sample = {path= dir("70s Chorus F5m.wav"),loopStart=86262, loopEnd=100352-1, root=77}},
       {sample = {path= dir("70s Chorus G2m.wav"),loopStart=169261, loopEnd=230709-1, root=43}},
       {sample = {path= dir("70s Chorus G3m.wav"),loopStart=134049, loopEnd=149193-1, root=55}},
       {sample = {path= dir("70s Chorus G4m.wav"),loopStart=73955, loopEnd=97634-1, root=67}},

      
   }
}
