function dir(p)
   return "assets/samples/mutebrass/"..p
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
      {sample = {path=dir("Mute A1.wav"),  loopStart=4688, loopEnd=4757+0,  root=21+48}},
      {sample = {path=dir("Mute Ab2.wav"),  loopStart=2255, loopEnd=2294+0,  root=32+48}},
   }
}

