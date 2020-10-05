function dir(p)
   return "assets/samples/harmonica/"..p
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
       {sample = {path=dir("HarmncaVbA2.wav"),  root=33, loopStart=11233,loopEnd=18451}},
       {sample = {path=dir("HarmncaVbA3.wav"),  root=45, loopStart=2890,loopEnd=10431}},
       {sample = {path=dir("HarmncaVbA4.wav"),  root=57, loopStart=1644,loopEnd=9483}},


   }
}

