function dir(p)
   return "assets/samples/jazz_drum_kit/"..p
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
      {sample = {path=dir("JK_BD_02.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_BD_06.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_BRSH_01.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_BRSH_02.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_HH_01.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_HH_02.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_03.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_04.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_05.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_06.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_09.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_PRC_10.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_SNR_01.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_SNR_02.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_SNR_03.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_SNR_04.WAV"),  root=60, kind=""}},
      {sample = {path=dir("JK_SNR_07.WAV"),  root=60, kind=""}},

     
   }
}
