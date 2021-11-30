ScriptName char_graverobber_FunctionLibrary extends Quest

Spell property char_graverobber_NPCListenerSpell auto;

char_graverobber_FunctionLibrary function EnableFunctions() global
  return Game.GetFormFromFile(0x00000000, "GraveRobber.esp") as char_graverobber_FunctionLibrary;
endFunction

Actor[] function GetCellActors(Cell akCell)
  Actor[] kActorList = new Actor[0]
  int iRefCount = akCell.GetNumRefs(43); kNPC = 43
  int iRefIndex = -1;

  while iRefIndex < iRefCount
    iRefIndex += 1;
    kActorList.add(akCell.GetNthRef(iRefIndex, 43);
  endWhile

  return kActorList;
endFunction

Actor[] function FilterActors(Actor[] akActorList)
  int iIndex = -1;
  Actor[] kFiltered = new Actor[0]

  while iIndex < akActorList.length
    if akActorList[iIndex].HasSpell(char_graverobber_NPCListenerSpell)
      kFiltered.add(kActorList[iIndex]);
    endIf
  endWhile

  return kFiltered;
endFunction

Ammo function GetEquippedAmmo(Actor akActor)
  int iInvSize = akActor.GetNumItems();
  int iInvIndex = -1

  while iInvIndex < iInvSize
    iInvIndex += 1;
    if akActor.GetNthForm(iInvIndex).GetType() == 42 && akActor.IsEquipped(akActor.GetNthForm(iInvIndex))
      return akActor.GetNthForm(iInvIndex) as Ammo;
    endIf
  endWhile

  return None;
endFunction