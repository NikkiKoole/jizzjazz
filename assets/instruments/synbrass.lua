function dir(p)
   return "assets/samples/synbrass/"..p
end

return {
   settings = {
      useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
      glide = false,        -- glide is always monophonic
      glideDuration = .15,
      monophonic = false,
      useSustain = true,
      vibrato = false,
      vibratoSpeed = 96/16,
      vibratoStrength = 10,  -- this should be in semitones
      transpose = -12,
      usePitchForADSR = false,
   },
   sounds = {
       {sample = {path=dir("JX3PSynBrsC2.wav"),  root=24, loopStart=9160,loopEnd=9835}},
       {sample = {path=dir("JX3PSynBrsC3.wav"),  root=36, loopStart=10012,loopEnd=10349}},
       {sample = {path=dir("JX3PSynBrsC4.wav"),  root=48, loopStart=9386,loopEnd=9554}},
       {sample = {path=dir("JX3PSynBrsC5.wav"),  root=60, loopStart=9153,loopEnd=9237}},
       --{sample = {path=dir("JX3PSynBrsC6.wav"),  root=72, loopStart=2273,loopEnd=2294}},
       {sample = {path=dir("JX3PSynBrsG2.wav"),  root=31, loopStart=9110,loopEnd=9560}},
       {sample = {path=dir("JX3PSynBrsG3.wav"),  root=43, loopStart=9332,loopEnd=9557}},
       {sample = {path=dir("JX3PSynBrsG4.wav"),  root=55, loopStart=9156,loopEnd=9268}},


   }
}

