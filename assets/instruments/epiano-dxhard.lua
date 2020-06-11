
function dir(p)
   return "assets/samples/dxhard/"..p
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
      transpose = -12,
   }, 
   
   sounds = {
      {sample = {path= dir("DX Hard A2.wav"),loopStart=3046, loopEnd=3174, root=33}},
       {sample = {path= dir("DX Hard A4.wav"),loopStart=2400, loopEnd=2432, root=57 }},
       {sample = {path= dir("DX Hard C1.wav"),loopStart=3436, loopEnd=3864, root=12}},
       {sample = {path= dir("DX Hard C2.wav"),loopStart=3563, loopEnd=3777, root=24}},
       {sample = {path= dir("DX Hard C4.wav"),loopStart=2631, loopEnd=2685, root=48}},
       {sample = {path= dir("DX Hard Gb3.wav"),loopStart=2834, loopEnd=2910, root=42}},

      
   }
}
