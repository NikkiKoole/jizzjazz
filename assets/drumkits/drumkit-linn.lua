function dir(p)
   return "assets/samples/linndrum/"..p
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
      {sample = {path=dir("WS-LINN BD W.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CAB.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CB W.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CHH.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CLP.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CNG.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN CRS.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN OHH.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN RDE.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN SD W.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN STK.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN TMB.wav"),  root=60, kind=""}},
      {sample = {path=dir("WS-LINN TOM.wav"),  root=60, kind=""}},
      


   }
}
