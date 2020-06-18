
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
      {sample = {path= dir("Jazz Gt. 045.wav"),loopStart=20478, loopEnd=30924-1, root=45}},
      {sample = {path= dir("Jazz Gt. 059.wav"),loopStart=24558, loopEnd=24946-1, root=59}},
      {sample = {path= dir("Jazz Gt. 066.wav"),loopStart=24552, loopEnd=24725-1, root=66}},
      {sample = {path= dir("Jazz Gt. 073.wav"),loopStart=42020, loopEnd=44915-1, root=73}},

      
   }
}
