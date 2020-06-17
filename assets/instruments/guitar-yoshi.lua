function dir(p)
   return "assets/samples/yoshi guitar/"..p
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
      {sample = {path=dir("Guitar.wav"),  loopStart=23878, loopEnd=23974-1,  root=64}},
      {sample = {path=dir("Guitar High.wav"),  loopStart=27040, loopEnd=27184-1,  root=69}},
      {sample = {path=dir("Guitar Low.wav"),  loopStart=19777, loopEnd=19994-1,  root=50}},
   }
}
