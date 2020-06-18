
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
      transpose = 2,
      usePitchForADSR = false,
   },
   sounds = {
      {sample = {path="assets/samples/Upright Bass F#2.wav", root=30 + 24, loopStart=6376,loopEnd=6676}},
   }
}

