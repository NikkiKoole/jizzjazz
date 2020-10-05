
function dir(p)
   return "assets/samples/rhodes small/"..p
end

return {
   settings = {
      useVanillaLooping = false,   -- whne creating the sound this decides static or queue 
      glide = false,        -- glide is always monophonic
      glideDuration = .5,
      monophonic = false,
      useSustain = true,
      vibrato = false,
      vibratoSpeed = 96/16,
      vibratoStrength = 10,  -- this should be in semitones
      transpose = 0,
      usePitchForADSR = false,
   },
   
   sounds = {
      {sample = {path= dir("A_029__F1_3.wav"), loopStart=165661, loopEnd=169724, root=29, rootVelocity=50}},
      {sample = {path= dir("A_035__B1_3.wav"), loopStart=119965, loopEnd=122111, root=35, rootVelocity=50}},
      {sample = {path= dir("A_040__E2_3.wav"), loopStart=131975, loopEnd=134638, root=40, rootVelocity=50}},
      {sample = {path= dir("A_045__A2_3.wav"), loopStart=117892, loopEnd=123090, root=45, rootVelocity=50}},
      {sample = {path= dir("A_050__D3_3.wav"), loopStart=136430, loopEnd=140318, root=50, rootVelocity=50}},
      {sample = {path= dir("A_055__G3_3.wav"), loopStart=112434,loopEnd=117151, root=55, rootVelocity=50}},
      {sample = {path= dir("A_059__B3_3.wav"), loopStart=72198, loopEnd=74161, root=59, rootVelocity=50}},
      {sample = {path= dir("A_062__D4_3.wav"), loopStart=83233, loopEnd=84882, root=62, rootVelocity=50}},
      {sample = {path= dir("A_065__F4_3.wav"), loopStart=86984, loopEnd=88120, root=65, rootVelocity=50}},
      {sample = {path= dir("A_071__B4_4.wav"), loopStart=81475, loopEnd=86821, root=71, rootVelocity=50}},
      {sample = {path= dir("A_076__E5_4.wav"), loopStart=52301, loopEnd=53235, root=76, rootVelocity=50}},
      {sample = {path= dir("A_081__A5_3.wav"), loopStart=70847, loopEnd=73746, root=81, rootVelocity=50}},
      {sample = {path= dir("A_086__D6_3.wav"), loopStart=82297, loopEnd=85256, root=86, rootVelocity=50}},
      {sample = {path= dir("A_091__G6_3.wav"), loopStart=45932, loopEnd=46885, root=91, rootVelocity=50}},
      {sample = {path= dir("A_096__C7_3.wav"), loopStart=46750, loopEnd=47338, root=96, rootVelocity=50}},
   }
}

