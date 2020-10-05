function dir(p)
   return "assets/samples/kr55/"..p
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
      {sample = {path=dir("KR55CHAT.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55CLAV.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55CNGA.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55COWB.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55CYMB.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55KICK.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55OHAT.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55RIM.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55SNAR.WAV"),  root=60, kind=""}},
      {sample = {path=dir("KR55TOM.WAV"),  root=60, kind=""}},
    

   }
}
