
function dir(p)
   return "assets/samples/rhodes all/"..p
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
      {sample = {path= dir("A_029__F1_1.wav"), loopStart=270858,loopEnd=274888, root=29,rootVelocity=100}},
{sample = {path= dir("A_029__F1_2.wav"), loopStart=216406,loopEnd=221444, root=29,rootVelocity=75}},
{sample = {path= dir("A_029__F1_3.wav"), loopStart=165661,loopEnd=169724, root=29,rootVelocity=50}},
{sample = {path= dir("A_029__F1_4.wav"), loopStart=97231,loopEnd=102325, root=29,rootVelocity=25}},
{sample = {path= dir("A_029__F1_5.wav"), loopStart=55230,loopEnd=60329, root=29,rootVelocity=10}},
{sample = {path= dir("A_035__B1_1.wav"), loopStart=210691,loopEnd=212121, root=35,rootVelocity=100}},
{sample = {path= dir("A_035__B1_2.wav"), loopStart=183903,loopEnd=184620, root=35,rootVelocity=75}},
{sample = {path= dir("A_035__B1_3.wav"), loopStart=119965,loopEnd=122111, root=35,rootVelocity=50}},
{sample = {path= dir("A_035__B1_4.wav"), loopStart=84155,loopEnd=89884, root=35,rootVelocity=25}},
{sample = {path= dir("A_035__B1_5.wav"), loopStart=70763,loopEnd=78646, root=35,rootVelocity=10}},
{sample = {path= dir("A_040__E2_1.wav"), loopStart=196070,loopEnd=197668, root=40,rootVelocity=100}},
{sample = {path= dir("A_040__E2_2.wav"), loopStart=211917,loopEnd=212452, root=40,rootVelocity=75}},
{sample = {path= dir("A_040__E2_3.wav"), loopStart=131975,loopEnd=134638, root=40,rootVelocity=50}},
{sample = {path= dir("A_040__E2_4.wav"), loopStart=108884,loopEnd=114216, root=40,rootVelocity=25}},
{sample = {path= dir("A_040__E2_5.wav"), loopStart=86114,loopEnd=91982, root=40,rootVelocity=10}},
{sample = {path= dir("A_045__A2_1.wav"), loopStart=219884,loopEnd=224282, root=45,rootVelocity=100}},
{sample = {path= dir("A_045__A2_2.wav"), loopStart=205473,loopEnd=207475, root=45,rootVelocity=75}},
{sample = {path= dir("A_045__A2_3.wav"), loopStart=117892,loopEnd=123090, root=45,rootVelocity=50}},
{sample = {path= dir("A_045__A2_4.wav"), loopStart=98571,loopEnd=103773, root=45,rootVelocity=25}},
{sample = {path= dir("A_045__A2_5.wav"), loopStart=80972,loopEnd=86578, root=45,rootVelocity=10}},
{sample = {path= dir("A_050__D3_1.wav"), loopStart=90612,loopEnd=93604, root=50,rootVelocity=100}},
{sample = {path= dir("A_050__D3_2.wav"), loopStart=107443,loopEnd=108341, root=50,rootVelocity=75}},
{sample = {path= dir("A_050__D3_3.wav"), loopStart=136430,loopEnd=140318, root=50,rootVelocity=50}},
{sample = {path= dir("A_050__D3_4.wav"), loopStart=85746,loopEnd=89634, root=50,rootVelocity=25}},
{sample = {path= dir("A_050__D3_5.wav"), loopStart=121960,loopEnd=130329, root=50,rootVelocity=10}},
{sample = {path= dir("A_055__G3_1.wav"), loopStart=112911,loopEnd=116281, root=55,rootVelocity=100}},
{sample = {path= dir("A_055__G3_2.wav"), loopStart=128743,loopEnd=129193, root=55,rootVelocity=75}},
{sample = {path= dir("A_055__G3_3.wav"), loopStart=112434,loopEnd=117151, root=55,rootVelocity=50}},
{sample = {path= dir("A_055__G3_4.wav"), loopStart=84330,loopEnd=89945, root=55,rootVelocity=25}},
{sample = {path= dir("A_055__G3_5.wav"), loopStart=66855,loopEnd=73818, root=55,rootVelocity=10}},
{sample = {path= dir("A_059__B3_1.wav"), loopStart=89796,loopEnd=91403, root=59,rootVelocity=100}},
{sample = {path= dir("A_059__B3_2.wav"), loopStart=88211,loopEnd=88747, root=59,rootVelocity=75}},
{sample = {path= dir("A_059__B3_3.wav"), loopStart=72198,loopEnd=74161, root=59,rootVelocity=50}},
{sample = {path= dir("A_059__B3_4.wav"), loopStart=68565,loopEnd=72845, root=59,rootVelocity=25}},
{sample = {path= dir("A_059__B3_5.wav"), loopStart=72309,loopEnd=76410, root=59,rootVelocity=10}},
{sample = {path= dir("A_062__D4_1.wav"), loopStart=91751,loopEnd=94297, root=62,rootVelocity=100}},
{sample = {path= dir("A_062__D4_2.wav"), loopStart=89475,loopEnd=89775, root=62,rootVelocity=75}},
{sample = {path= dir("A_062__D4_3.wav"), loopStart=83233,loopEnd=84882, root=62,rootVelocity=50}},
{sample = {path= dir("A_062__D4_4.wav"), loopStart=85185,loopEnd=92372, root=62,rootVelocity=25}},
{sample = {path= dir("A_062__D4_5.wav"), loopStart=70294,loopEnd=75534, root=62,rootVelocity=10}},
{sample = {path= dir("A_065__F4_1.wav"), loopStart=95933,loopEnd=98208, root=65,rootVelocity=100}},
{sample = {path= dir("A_065__F4_2.wav"), loopStart=79646,loopEnd=81162, root=65,rootVelocity=75}},
{sample = {path= dir("A_065__F4_3.wav"), loopStart=86984,loopEnd=88120, root=65,rootVelocity=50}},
{sample = {path= dir("A_065__F4_4.wav"), loopStart=95027,loopEnd=100331, root=65,rootVelocity=25}},
{sample = {path= dir("A_065__F4_5.wav"), loopStart=70150,loopEnd=74191, root=65,rootVelocity=10}},
{sample = {path= dir("A_071__B4_1.wav"), loopStart=122499,loopEnd=124638, root=71,rootVelocity=100}},
{sample = {path= dir("A_071__B4_2.wav"), loopStart=79962,loopEnd=80497, root=71,rootVelocity=75}},
{sample = {path= dir("A_071__B4_4.wav"), loopStart=81475,loopEnd=86821, root=71,rootVelocity=25}},
{sample = {path= dir("A_071__B4_5.wav"), loopStart=58847,loopEnd=61520, root=71,rootVelocity=10}},
{sample = {path= dir("A_076__E5_1.wav"), loopStart=82013,loopEnd=82080, root=76,rootVelocity=100}},
{sample = {path= dir("A_076__E5_2.wav"), loopStart=56002,loopEnd=56336, root=76,rootVelocity=75}},
{sample = {path= dir("A_076__E5_4.wav"), loopStart=52301,loopEnd=53235, root=76,rootVelocity=25}},
{sample = {path= dir("A_076__E5_5.wav"), loopStart=75822,loopEnd=77290, root=76,rootVelocity=10}},
{sample = {path= dir("A_081__A5_2.wav"), loopStart=64517,loopEnd=66167, root=81,rootVelocity=75}},
{sample = {path= dir("A_081__A5_3.wav"), loopStart=70847,loopEnd=73746, root=81,rootVelocity=50}},
{sample = {path= dir("A_086__D6_2.wav"), loopStart=98160,loopEnd=98722, root=86,rootVelocity=75}},
{sample = {path= dir("A_086__D6_3.wav"), loopStart=82297,loopEnd=85256, root=86,rootVelocity=50}},
{sample = {path= dir("A_091__G6_2.wav"), loopStart=70307,loopEnd=71120, root=91,rootVelocity=75}},
{sample = {path= dir("A_091__G6_3.wav"), loopStart=45932,loopEnd=46885, root=91,rootVelocity=50}},
{sample = {path= dir("A_096__C7_2.wav"), loopStart=63888,loopEnd=108100, root=96,rootVelocity=75}},
 {sample = {path= dir("A_096__C7_3.wav"), loopStart=46750,loopEnd=47338, root=96,rootVelocity=50}},

   }
}


