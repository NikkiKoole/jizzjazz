
function dir(p)
   return "assets/samples/clarinet/"..p
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
   },
   sounds = {
      {sample = {path=dir("claria3.wav"),  root=57, loopStart=4832,loopEnd=5032}},
      {sample = {path=dir("clarias4.wav"), root=70, loopStart=2722,loopEnd=2909-1}},
      {sample = {path=dir("claric4.wav"),  root=60, loopStart=3730,loopEnd=3898}},
      {sample = {path=dir("claric5.wav"),  root=72, loopStart=3019,loopEnd=3102}},
      {sample = {path=dir("clarid3.wav"),  root=50, loopStart=3926,loopEnd=4224}},
      {sample = {path=dir("clarid6.wav"),  root=86, loopStart=2508,loopEnd=2545}},
      {sample = {path=dir("clarids5.wav"), root=75, loopStart=2951,loopEnd=3021}},
      {sample = {path=dir("clarie4.wav"),  root=64, loopStart=4229,loopEnd=4363}},
      {sample = {path=dir("clarig5.wav"),  root=79, loopStart=2540,loopEnd=2596}},
      {sample = {path=dir("clarigs6.wav"), root=92, loopStart=4714,loopEnd=4952}},
   }
}

