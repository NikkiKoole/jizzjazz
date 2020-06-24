function dir(p)
   return "assets/samples/jazz funk kit/mono/"..p
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
      {sample = {path=dir("bop kick - snares off - 1 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("flat ride - 5 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("floor tom - snares on - 2 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("hihat - close - 4 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("hihat - closed - 4 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("hihat - closed side - 3 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("hihat - opened 1 - 3 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("kick - snares off - 1 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("snare - snares off - 2 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("snare - snares on - 5 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("stickshot - snares off - 3 mono.wav"),  root=60, kind=""}},
      {sample = {path=dir("stickshot - snares on - 3 mono.wav"),  root=60, kind=""}},
      


   }
}
