function dir(p)
   return "assets/samples/OB/"..p
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
      transpose = -12,
      usePitchForADSR = false,
   },
   sounds = {
       {sample = {path=dir("OB 5 C3.wav"),  root=36, loopStart=226,loopEnd=395}},
       {sample = {path=dir("OB 5 C4.wav"),  root=48, loopStart=113,loopEnd=198}},
       {sample = {path=dir("OB 5 C5.wav"),  root=60, loopStart=84,loopEnd=126}},
       {sample = {path=dir("OB 5 C6.wav"),  root=72, loopStart=38,loopEnd=59}},
       {sample = {path=dir("OB 5 G1.wav"),  root=19, loopStart=147,loopEnd=597}},
       {sample = {path=dir("OB 5 G4.wav"),  root=55, loopStart=56,loopEnd=112}},

   }
}

