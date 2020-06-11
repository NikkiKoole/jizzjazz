function dir(p)
   return "assets/samples/yoshi/"..p
end

return {
   settings = {
      useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
      glide = false,        -- glide is always monophonic
      glideDuration = .5,
      monophonic = false,
      useSustain = true,
      vibrato = false,
      vibratoSpeed = 96/16,
      vibratoStrength = 10,  -- this should be in semitones
      transpose = 0,
      usePitchForADSR = false,
   },
   adsr = {
      attack = 0.005,
      max   = .50,
      decay = 2.5,
      sustain= .30,
      release = .5,
   },
   sounds = {
      {sample = {path=dir("Sample 15-2.wav"),loopStart=5470, loopEnd=5738, root=52}},
      {sample = {path=dir("Sample 14-2.wav"),loopStart=4282, loopEnd=4430, root=62}},
      {sample = {path=dir("Sample 13-1.wav"),loopStart=7080, loopEnd=7585, root=72}},
   }
}
