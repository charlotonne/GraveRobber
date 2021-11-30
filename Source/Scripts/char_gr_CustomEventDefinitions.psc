ScriptName char_gr_CustomEventDefinitions extends Quest

char_gr_CustomEventDefinitions function EnableEvents() global
  return Game.GetFormFromFile(0x00000802, "GraveRobber.esp") as char_gr_CustomEventDefinitions;
endFunction

Actor property PlayerRef auto;
Cell PlayerCellLastKnown = None;
int CellNPCCountLastKnown = 0;

Event OnInit()
  RegisterForSingleUpdate(1.0);
endEvent

Event OnPlayerLoadGame()
    RegisterForSingleUpdate(1.0);
endEvent

Event OnUpdate()
  bool bKeepUpdating = true;

  ; CustomEvent PlayerCellChange
  if PlayerRef.GetParentCell() != PlayerCellLastKnown
    PlayerCellLastKnown = PlayerRef.GetParentCell();
    SendModEvent("PlayerCellChange");
  endIf

  ; CustomEvent CellNPCChange
  if PlayerCellLastKnown.GetNumRefs(43) != CellNPCCountLastKnown
    SendModEvent("CellNPCChange");
    CellNPCCountLastKnown = PlayerCellLastKnown.GetNumRefs(43);
  endIf
  
  if bKeepUpdating
    RegisterForSingleUpdate(1.0);
  endIf
endEvent