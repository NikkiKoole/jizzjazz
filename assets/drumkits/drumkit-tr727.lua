function dir(p)
   return "assets/samples/tr727/"..p
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
      {sample = {path=dir("727 CABASA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 HI BONGO.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 HI TIMBA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 HM CONGA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 HO CONGA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 L.WHISTL.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 LO BONGO.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 LO CONGA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 LO TIMBA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 MARACAS.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 QUIJADA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 S.WHISTL.WAV"),  root=60, kind=""}},
      {sample = {path=dir("727 STARCHIM.WAV"),  root=60, kind=""}},


   }
}
