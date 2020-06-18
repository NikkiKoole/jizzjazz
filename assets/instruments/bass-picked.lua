
function dir(p)
   return "assets/samples/wii/"..p
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
      {sample = {path= dir("Picked Bass 024.wav"),loopStart=15672, loopEnd=21074-1, root=24+12}},
      {sample = {path= dir("Picked Bass 031.wav"),loopStart=15078, loopEnd=20931-1, root=31+12}},
      {sample = {path= dir("Picked Bass 036.wav"),loopStart=16338, loopEnd=18025-1, root=36+12}},
      {sample = {path= dir("Picked Bass 043.wav"),loopStart=10730, loopEnd=16808-1, root=43+12}},

      
   }
}
