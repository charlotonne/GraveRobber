ScriptName char_gr_PlayerListener extends ActiveMagicEffect

; Import related external scripts
char_gr_FunctionLibrary GraveRobber = None;

Actor property PlayerRef auto;
Spell property char_gr_NPCListenerSpell auto;

Actor[] kNPCList = None;
Cell kPlayerCell = None;

function UpdateNPCList()
  kNPCList = GraveRobber.GetCellActors(kPlayerCell);
  kNPCList = GraveRobber.FilterActors(kNPCList);
  ApplyNPCListener();
endFunction

function ApplyNPCListener()
  int iIndex = -1;
  if kNPCList.length > 0
    while iIndex < kNPCList.length
      iIndex += 1;
      kNPCList[iIndex].AddSpell(char_gr_NPCListenerSpell, abVerbose = false);
    endWhile
  endIf
  kNPCList = None;
endFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  RegisterForModEvent("PlayerCellChange", "OnPlayerCellChange");
  RegisterForModEvent("CellNPCChange", "OnCellNPCChange");
endEvent

Event OnInit()
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  RegisterForModEvent("PlayerCellChange", "OnPlayerCellChange");
  RegisterForModEvent("CellNPCChange", "OnCellNPCChange");
endEvent

Event OnPlayerLoadGame()
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  RegisterForModEvent("PlayerCellChange", "OnPlayerCellChange");
  RegisterForModEvent("CellNPCChange", "OnCellNPCChange");
endEvent

Event OnPlayerCellChange(string eventName, string strArg, float numArg, Form sender)
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  kPlayerCell = PlayerRef.GetParentCell();
  UpdateNPCList();
endEvent

Event OnCellNPCChange(string eventName, string strArg, float numArg, Form sender)
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  UpdateNPCList();
endEvent