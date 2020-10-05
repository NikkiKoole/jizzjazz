function dir(p)
   return "assets/samples/cr8000/"..p
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
      {sample = {path=dir("CR8KBASS.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KCHAT.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KCLAP.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KCLAV.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KCOWB.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KCYMB.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KHITM.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KLCNG.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KLOTM.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KMCNG.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KOHAT.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KRIM.WAV"),  root=60, kind=""}},
      {sample = {path=dir("CR8KSNAR.WAV"),  root=60, kind=""}},



   }
}
