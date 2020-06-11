
return {
   settings = {
      useVanillaLooping = true,   -- whne creating the sound this decides static or queue 
      glide = false,        -- glide is always monophonic
      glideDuration = .5,
      monophonic = false,
      useSustain = true,
      vibrato = false,
      vibratoSpeed = 96/16,
      vibratoStrength = 10,  -- this should be in semitones
      transpose = 12,
      usePitchForADSR = false,
   },
   sounds = {
      {sample = {path="assets/oscillators/akwf/AKWF_stringbox/AKWF_cheeze_0003.wav", root=72}},
   }
}
