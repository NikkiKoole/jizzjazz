
function dir(p)
   return "assets/samples/guitars/60s/"..p
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
      {sample = {path= dir("60's Guitar B4L.wav"),loopStart=50111, loopEnd=73937-1, root=71}},
      {sample = {path= dir("60's Guitar B5L.wav"),loopStart=32724, loopEnd=63055-1, root=83}},
      {sample = {path= dir("60's Guitar Bb2L.wav"),loopStart=112829, loopEnd=142439-1, root=46}},
      {sample = {path= dir("60's Guitar Bb3L.wav"),loopStart=62988, loopEnd=93609-1, root=58}},
      {sample = {path= dir("60's Guitar E2L.wav"),loopStart=143091, loopEnd=192316-1, root=40}},
      {sample = {path= dir("60's Guitar E3L.wav"),loopStart=92958, loopEnd=123092-1, root=52}},
      {sample = {path= dir("60's Guitar E4L.wav"),loopStart=44550, loopEnd=66649-1, root=64}},
      {sample = {path= dir("60's Guitar F5L.wav"),loopStart=39203, loopEnd=68222-1, root=77}},

      
   }
}
