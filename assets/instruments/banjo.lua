function dir(p)
   return "assets/samples/nice instruments/"..p
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
      {sample = {path=dir("banjo 048.wav"),  root=48}},
      {sample = {path=dir("banjo 052.wav"),  root=52}},
      {sample = {path=dir("banjo 056.wav"),  root=56}},
      {sample = {path=dir("banjo 060.wav"),  root=60}},
      {sample = {path=dir("banjo 064.wav"),  root=64}},
      {sample = {path=dir("banjo 068.wav"),  root=68}},
      {sample = {path=dir("banjo 072.wav"),  root=72}},
      {sample = {path=dir("banjo 075.wav"),  root=75}},
      {sample = {path=dir("banjo 077.wav"),  root=77}},
      {sample = {path=dir("banjo 079.wav"),  root=79}},
      {sample = {path=dir("banjo 081.wav"),  root=81}},
      {sample = {path=dir("banjo 084.wav"),  root=84}},
      {sample = {path=dir("banjo 088.wav"),  root=88}},


   }
}

