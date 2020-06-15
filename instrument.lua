function getDefaultInstrument()
   return {
      settings = {
         useVanillaLooping = false, 
         glide = false,        
         glideDuration = .5,
         monophonic = false,
         useSustain = true,
         useEcho = false,

         vibrato = false,
         vibratoSpeed = 96/16,
         vibratoStrength = 10, 
         transpose = 0,
         usePitchForADSR = false,
      },
      
      sounds = {
         {
            sample = {
               path="assets/samples/Upright Bass F#2.wav",
               loopStart=6376,
               loopEnd=6676,
               root=60,
               
            },
         }
      },

      
   }
end
