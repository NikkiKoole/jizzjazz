function dir(p)
   return "assets/samples/pizzicato/"..p
end

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
      {sample = {path=dir("Pizz Violins C2.wav"),  loopStart=18981, loopEnd=19317+0,  root=24}},
      {sample = {path=dir("Pizz Violins C3.wav"),  loopStart=16216, loopEnd=16300+0,  root=36}},
      {sample = {path=dir("Pizz Violins C4.wav"),  loopStart=14848, loopEnd=14890+0,  root=48}},
      {sample = {path=dir("Pizz Violins C7.wav"),  loopStart=4192, loopEnd=4203+0,  root=84}},
      {sample = {path=dir("Pizz Violins E2.wav"),  loopStart=24803, loopEnd=24937+0,  root=28}},
     
   }
}

