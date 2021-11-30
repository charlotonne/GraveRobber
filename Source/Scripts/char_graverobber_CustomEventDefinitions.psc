ScriptName char_graverobber_CustomEventDefinitions extends Quest

char_graverobber_CustomEventDefinitions function EnableEvents() global
  return Game.GetFormFromFile(0x00000000, "GraveRobber.esp") as char_graverobber_CustomEventDefinitions;
endFunction

Actor property PlayerRef auto;
Cell PlayerCellLastKnown = None;
int CellNPCCountLastKnown = 0;

;
; CustomEvent PlayerCellChange
; @description  Custom Event that triggers whenever the player changes cells.
; @param        akCell: the new cell that the player has entered
; @return       None
; @usage        RegisterForCustomEvent(char_graverobber_CustomEventDefinitions, "PlayerCellChange");
;               UnregisterForCustomEvent(char_graverobber_CustomEventDefinitions, "PlayerCellChange");
;               Event PlayerCellChange(char_graverobber_CustomEventDefinitions akSender, var[] akArgs)
;               endEvent
;
CustomEvent PlayerCellChange;

;
; CustomEvent CellNPCChange
; @description  Custom Event that triggers whenever an NPC enters or exits the player's cell.
; @param        aiPrevCount: the count of NPCs before the NPC entered or left
;               aiCount: the count of NPCs after the NPC has entered or left
; @return       None
; @usage        RegisterForCustomEvent(char_graverobber_CustomEventDefinitions, "CellNPCChange");
;               UnregisterForCustomEvent(char_graverobber_CustomEventDefinitions, "CellNPCChange");
;               Event CellNPCChange(char_graverobber_CustomEventDefinitions akSender, var[] akArgs)
;               endEvent
;
CustomEvent CellNPCChange;

Event OnInit()
  RegisterForSingleUpdate(1.0);
endEvent

Event OnUpdate()
  bool bKeepUpdating = true;

  ; CustomEvent PlayerCellChange
  if PlayerRef.GetParentCell() != PlayerCellLastKnown
    PlayerCellLastKnown = PlayerRef.GetParentCell();
    SendCustomEvent("PlayerCellChange", [PlayerCellLastKnown]);
  endIf

  ; CustomEvent CellNPCChange
  if PlayerCellLastKnown.GetNumItems(43) != CellNPCCountLastKnown
    SendCustomEvent("CellNPCChange", [CellNPCCountLastKnown, PlayerCellLastKnown.GetNumItems(43)]);
    CellNPCCountLastKnown = PlayerCellLastKnown.GetNumItems(43);
  endIf
  
  if bKeepUpdating
    RegisterForSingleUpdate(1.0);
  endIf
endEvent