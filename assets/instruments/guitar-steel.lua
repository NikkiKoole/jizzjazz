function dir(p)
   return "assets/samples/guitars/steel/"..p
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
      {sample = {path=dir("ST2_40B.wav"),  root=40}},
      {sample = {path=dir("ST2_45B.wav"),  root=45}},
      {sample = {path=dir("ST2_52B.wav"),  root=52}},
      {sample = {path=dir("ST2_57B.wav"),  root=57}},
      {sample = {path=dir("ST2_65B.wav"),  root=65}},
   }
}

