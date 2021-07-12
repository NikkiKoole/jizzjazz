
function dir(p)
   return "assets/samples/Mini 2 Saw Bass/"..p
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
      {sample = {path= dir("Mini 2 Saw Bass A1.wav"), root=21, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass A2.wav"), root=21+12, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass A3.wav"), root=21+24, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass A4.wav"), root=21+36, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass A5.wav"), root=21+48, rootVelocity=50}},
      
      {sample = {path= dir("Mini 2 Saw Bass C2.wav"), root=12+12, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass C3.wav"), root=12+24, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass C4.wav"), root=12+36, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass C5.wav"), root=12+48, rootVelocity=50}},

      {sample = {path= dir("Mini 2 Saw Bass Eb2.wav"), root=15+12, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Eb3.wav"), root=15+24, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Eb4.wav"), root=15+36, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Eb5.wav"), root=15+48, rootVelocity=50}},

      {sample = {path= dir("Mini 2 Saw Bass Gb1.wav"), root=18, rootVelocity=50}},
       {sample = {path= dir("Mini 2 Saw Bass Gb2.wav"), root=18+12, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Gb3.wav"), root=18+24, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Gb4.wav"), root=18+36, rootVelocity=50}},
      {sample = {path= dir("Mini 2 Saw Bass Gb5.wav"), root=18+48, rootVelocity=50}},
      
   }
}
