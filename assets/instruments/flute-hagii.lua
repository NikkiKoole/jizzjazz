
function dir(p)
   return "assets/samples/hagiflute/"..p
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
      {sample = {path= dir("FLUTE A#4.wav"),loopStart=18999, loopEnd=29939, root=70}},
      {sample = {path= dir("FLUTE A#5.wav"),loopStart=21937, loopEnd=32520, root=82}},
      {sample = {path= dir("FLUTE A#6.wav"),loopStart=27291, loopEnd=32665, root=94}},
      {sample = {path= dir("FLUTE C#4.wav"),loopStart=18182, loopEnd=29941, root=61}},
      {sample = {path= dir("FLUTE C#5.wav"),loopStart=34467, loopEnd=45015, root=73}},
      {sample = {path= dir("FLUTE C#6.wav"),loopStart=26887, loopEnd=32501, root=85}},
      {sample = {path= dir("FLUTE D#4.wav"),loopStart=12682, loopEnd=23573, root=63}},
      {sample = {path= dir("FLUTE E5.wav"),loopStart=25232, loopEnd=36186, root=76}},
      {sample = {path= dir("FLUTE E6.wav"),loopStart=21372, loopEnd=27023, root=88}},
      {sample = {path= dir("FLUTE G4.wav"),loopStart=29023, loopEnd=40764, root=67}},
      {sample = {path= dir("FLUTE G5.wav"),loopStart=27313, loopEnd=38675, root=79}},
      {sample = {path= dir("FLUTE G6.wav"),loopStart=46226, loopEnd=52302, root=91}},
      
      
   }
}
