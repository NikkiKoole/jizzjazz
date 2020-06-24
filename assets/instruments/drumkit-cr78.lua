function dir(p)
   return "assets/samples/cr78/"..p
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
      {sample = {path=dir("Bongo High.wav"),  root=60, kind=""}},
      {sample = {path=dir("Bongo Low.wav"),  root=60, kind=""}},
      {sample = {path=dir("Conga Low.wav"),  root=60, kind=""}},
      {sample = {path=dir("Cowbell.wav"),  root=60, kind=""}},
      {sample = {path=dir("Cymbal.wav"),  root=60, kind=""}},
      {sample = {path=dir("Guiro 1.wav"),  root=60, kind=""}},
      {sample = {path=dir("HiHat.wav"),  root=60, kind=""}},
      {sample = {path=dir("HiHat Metal.wav"),  root=60, kind=""}},
      {sample = {path=dir("Kick.wav"),  root=60, kind=""}},
      {sample = {path=dir("Rim Shot.wav"),  root=60, kind=""}},
      {sample = {path=dir("Snare.wav"),  root=60, kind=""}},
      {sample = {path=dir("Tamb 1.wav"),  root=60, kind=""}},
      


   }
}

-- local names = {
--       "Bass Drum BD",
--       "Snare Drum SD",
--       "Low Tom LT",
--       "Mid Tom MT",
--       "Hi Tom HT",
--       "Low Conga LC",
--       "Mid Conga MC",
--       "Hi Conga HC",
--       "Rim Shot RS",
--       "Claves CL",
--       "Hand Clap CP",
--       "Maracas MA",
--       "Cowbell CB",
--       "Cymbal CY",
--       "Open Hihat OH",
--       "Closed Hihat CH",
--       "Guiro GU",
--       "Tambourine TM"
--    }
