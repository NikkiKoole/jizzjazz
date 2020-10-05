function dir(p)
   return "assets/samples/808/"..p
end

return {
   isDrumKit = true,
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
      {sample = {path=dir("BD/BD5050.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CB/CB.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CH/CH.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CL/CL.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CP/CP.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CY/CY5050.WAV"),  root=60, kind=""}},
      {sample = {path=dir("HC/HC25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("HT/HT25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("LC/LC25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("LT/LT25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("MA/MA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("MC/MC25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("MT/MT25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("OH/OH25.WAV"),  root=60, kind=""}},
      {sample = {path=dir("RS/RS.WAV"),  root=60, kind=""}},
      {sample = {path=dir("SD/SD5050.WAV"),  root=60, kind=""}},
      


   }
}
