ScriptName char_graverobber_PlayerListener extends ActiveMagicEffect

; Import related external scripts
char_graverobber_CustomEventDefinitions GraveRobberEvents = char_graverobber_CustomEventDefinitions.EnableEvents();
char_graverobber_FunctionLibrary GraveRobber = char_graverobber_FunctionLibrary.EnableFunctions();

Actor property PlayerRef auto;
Spell property char_graverobber_NPCListenerSpell auto;

Actor[] kNPCList = new Actor[0]
Cell kPlayerCell = None;

function UpdateNPCList()
  kNPCList = GraveRobber.GetCellActors(kPlayerCell);
  kNPCList = GraveRobber.FilterActors(kNPCList);
  ApplyNPCListener();
endFunction

function ApplyNPCListener()
  iIndex = -1;
  if kNPCList.length > 0
    while iIndex < kNPCList.length
      iIndex += 1;
      kNPCList[iIndex].AddSpell(char_graverobber_NPCListenerSpell, abVerbose = false);
    endWhile
  endIf
  kNPCList = new Actor[0];
endFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
  RegisterForCustomEvent(GraveRobberEvents, "PlayerCellChange");
  RegisterForCustomEvent(GraveRobberEvents, "CellNPCChange");
endEvent

Event GraveRobberEvents.PlayerCellChange(char_graverobber_CustomEventDefinitions akSender, var[] akArgs)
  kPlayerCell = akArgs[0];
  UpdateNPCList();
endEvent

Event GraveRobberEvents.CellNPCChange(char_graverobber_CustomEventDefinitions akSender, var[] akArgs)
  UpdateNPCList();
endEvent