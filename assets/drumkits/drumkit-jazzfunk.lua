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
      {sample = {path=dir("bop kick - snares off - 1 mono.wav"),  root=60, kind="bop"}},
      {sample = {path=dir("flat ride - 5 mono.wav"),  root=60, kind="ride"}},
      {sample = {path=dir("floor tom - snares on - 2 mono.wav"),  root=60, kind="tom"}},
      {sample = {path=dir("hihat - close - 4 mono.wav"),  root=60, kind="hihat close"}},
      {sample = {path=dir("hihat - closed - 4 mono.wav"),  root=60, kind="hihat closed"}},
      {sample = {path=dir("hihat - closed side - 3 mono.wav"),  root=60, kind="hihat c"}},
      {sample = {path=dir("hihat - opened 1 - 3 mono.wav"),  root=60, kind="hihat o"}},
      {sample = {path=dir("kick - snares off - 1 mono.wav"),  root=60, kind="kick"}},
      {sample = {path=dir("snare - snares off - 2 mono.wav"),  root=60, kind="snare off"}},
      {sample = {path=dir("snare - snares on - 5 mono.wav"),  root=60, kind="snare on"}},
      {sample = {path=dir("stickshot - snares off - 3 mono.wav"),  root=60, kind="stick off"}},
      {sample = {path=dir("stickshot - snares on - 3 mono.wav"),  root=60, kind="stick on"}},
      


   }
}
