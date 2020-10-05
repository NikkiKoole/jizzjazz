function dir(p)
   return "assets/samples/tr606/"..p
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
      {sample = {path=dir("01bd.wav"),  root=60, kind=""}},
      {sample = {path=dir("02sd.wav"),  root=60, kind=""}},
      {sample = {path=dir("03ch.wav"),  root=60, kind=""}},
      {sample = {path=dir("04oh.wav"),  root=60, kind=""}},
      {sample = {path=dir("05lt.wav"),  root=60, kind=""}},
      {sample = {path=dir("06ht.wav"),  root=60, kind=""}},
      {sample = {path=dir("07cy.wav"),  root=60, kind=""}},
      {sample = {path=dir("08acc_bd.wav"),  root=60, kind=""}},
      {sample = {path=dir("09acc_sd.wav"),  root=60, kind=""}},
      {sample = {path=dir("10acc_ch.wav"),  root=60, kind=""}},
      {sample = {path=dir("11acc_oh.wav"),  root=60, kind=""}},
      {sample = {path=dir("12acc_lt.wav"),  root=60, kind=""}},
      {sample = {path=dir("13acc_ht.wav"),  root=60, kind=""}},
      {sample = {path=dir("14acc_cy.wav"),  root=60, kind=""}},

   }
}
