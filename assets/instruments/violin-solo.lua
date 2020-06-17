function dir(p)
   return "assets/samples/nice instruments/"..p
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
      transpose = 0,
      usePitchForADSR = false,
   },
   sounds = {
      {sample = {path=dir("Solo Violin A#4.wav"),  loopStart=16447, loopEnd=22057-1,  root=58}},
      {sample = {path=dir("Solo Violin A#5.wav"),  loopStart=15234, loopEnd=20630-1,  root=70}},
      {sample = {path=dir("Solo Violin A#6.wav"),  loopStart=10192, loopEnd=16564-1,  root=82}},
      {sample = {path=dir("Solo Violin A4.wav"),  loopStart=17582, loopEnd=23522-1,  root=57}},
      {sample = {path=dir("Solo Violin C#6.wav"),  loopStart=13589, loopEnd=19077-1,  root=73}},
       {sample = {path=dir("Solo Violin C5.wav"),  loopStart=21716, loopEnd=27552-1,  root=60}},
       {sample = {path=dir("Solo Violin D#5.wav"),  loopStart=12171, loopEnd=17784-1,  root=63}},
       {sample = {path=dir("Solo Violin D7.wav"),  loopStart=12514, loopEnd=18463-1,  root=86}},
       {sample = {path=dir("Solo Violin E5.wav"),  loopStart=15669, loopEnd=21571-1,  root=64}},
       {sample = {path=dir("Solo Violin F#5.wav"),  loopStart=11850, loopEnd=17458-1,  root=66}},
       {sample = {path=dir("Solo Violin F6.wav"),  loopStart=18512, loopEnd=23955-1,  root=77}},
       {sample = {path=dir("Solo Violin G#7.wav"),  loopStart=10080, loopEnd=15958-1,  root=92}},

   }
}
