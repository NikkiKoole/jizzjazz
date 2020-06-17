function dir(p)
   return "assets/samples/florestan wood/"..p
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
      {sample = {path=dir("Oboe A#4m.wav"),  root=82,  loopStart=30219, loopEnd=38912}},
      {sample = {path=dir("Oboe A#5m.wav"),  root=93,  loopStart=19744, loopEnd=28928}},
      {sample = {path=dir("Oboe D#4m.wav"),  root=75,  loopStart=29362, loopEnd=38401}},
      {sample = {path=dir("Oboe D5m.wav"),  root=86,  loopStart=18961, loopEnd=26880}},
      {sample = {path=dir("Oboe E4m.wav"),  root=76,  loopStart=20857, loopEnd=29697}},
      {sample = {path=dir("Oboe G4m.wav"),  root=79,  loopStart=20252, loopEnd=28673}},
      {sample = {path=dir("Oboe G5m.wav"),  root=91,  loopStart=19434, loopEnd=28161}},

   }
}

