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

Form function GetEquippedForm(Actor akActor, int aiSlot)
  iType = 0;
  if aiSlot <= 1
    iType = akActor.GetEquippedItemType(aiSlot);
    if iType == 9
      return akActor.GetEquippedSpell(aiSlot) as Form;
    elseif iType == 10
      return akActor.GetEquippedShield() as Form;
    else
      return akActor.GetEquippedWeapon(!(aiSlot as bool)) as Form;
  elseif aiSlot == 2
    return akActor.GetEquippedShout();
  endif
  return None;
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

function EquipForm(Actor akActor, Form akForm, int aiSlot)
  iType = 0;
  if akActor && akForm
    if aiSlot <= 1
      iType = akForm.GetType();
      if iType == 22 || iType == 82
        akActor.EquipSpell(akForm as Spell, aiSlot);
      else
        akActor.EquipItem(akForm, abPreventRemoval = false, abSilent = true);
      endIf
    elseif aiSlot == 2
      akActor.EquipShout(akForm as Shout);
    elseif aiSlot == 3
      akActor.EquipItem(akForm, abPreventRemoval = false, abSilent = true);
    endIf
  endIf
endFunction

function AddForm(Actor akActor, Form akForm, int aiCount)
  if akForm && akActor
    iType = akForm.GetType()
    if iType == 22 || iType == 82
      akActor.AddSpell(akForm as Spell);
    elseif iType == 119
      akActor.AddShout(akForm as Shout);
      ; Using a SKSE function here because there is no viable replacement yet.
      Game.TeachWord((akForm as Shout).GetNthWordOfPower(0));
      Game.TeachWord((akForm as Shout).GetNthWordOfPower(1));
      Game.TeachWord((akForm as Shout).GetNthWordOfPower(2));
    else
      akActor.AddItem(akForm, aiCount, abSilent = true);
    endIf
  endIf
endFunction