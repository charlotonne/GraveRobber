ScriptName charGraveRobberLibraryQuestScript Extends Quest

Static property XMarker auto;
Actor property PlayerRef auto;

; This is essentially an Enum for the GetEquippedForm function.
int EQSLOT_LEFT = 0;
int EQSLOT_RIGHT = 1;
int EQSLOT_SHOUT = 2;
int EQSLOT_AMMO = 3;

; This is essentially an Enum for the GetEquppedItemType function.
int EQTYPE_ONE_HAND = 0;
int EQTYPE_ONE_SWORD = 1;
int EQTYPE_ONE_DAGGER = 2;
int EQTYPE_ONE_AXE = 3;
int EQTYPE_ONE_MACE = 4;
int EQTYPE_TWO_SWORD = 5;
int EQTYPE_TWO_AXE = 6;
int EQTYPE_BOW = 7;
int EQTYPE_STAFF = 8;
int EQTYPE_SPELL = 9;
int EQTYPE_SHIELD = 10;
int EQTYPE_TORCH = 11;
int EQTYPE_CROSSBOW = 12;

;
; This function allows for the script itself to be used by other scripts
;
charGraveRobberLibraryQuestScript function GetScript() global
	return Game.GetFormFromFile(0x00000809, "GraveRobber.esp") as charGraveRobberLibraryQuestScript;
endFunction

;
; This function searches within 2 cells of the player for all actors.
; An array of found actors is returned.
;
Actor[] function GetNearbyActors()
  Cell kPlayerCell = PlayerRef.GetParentCell();
  ObjectReference kXMarker = PlayerRef.PlaceAtMe(XMarker, 1);

  Cell[] kCellList = new Cell[25];
  int iCellIndex = -1;
  int iRefIndex = -1;
  int iRefLength = -1;

  Actor[] kActorList = new Actor[128];
  Actor kCurrentActor = None;

  int iActorIndex = -1;

  int[] iCoordinate = new int[5];
  iCoordinate[0] = 0;
  iCoordinate[1] = 4096;
  iCoordinate[2] = 8192;
  iCoordinate[3] = -4096;
  iCoordinate[4] = -8192;

  int iXIndex = -1;
  int iYIndex = -1;

  while iXIndex < 5
    iXIndex += 1;
    while iYIndex < 5
      iYIndex += 1;
      iCellIndex += 1;
      kXMarker.MoveTo(PlayerRef, iCoordinate[iXIndex], iCoordinate[iYIndex]);
      kCellList[iCellIndex] = kXMarker.GetParentCell();
    endWhile
    iYIndex = -1;
  endWhile
  kXMarker.Delete();

  iCellIndex = -1;
  while iCellIndex < 25
    iCellIndex += 1;
    iRefLength = kCellList[iCellIndex].GetNumRefs(43);
    iRefIndex = -1;
    while iRefIndex < iRefLength
      iRefIndex += 1;
      if iActorIndex < 128 && (kCellList[iCellIndex].GetNthRef(iRefIndex, 43) as Actor) != PlayerRef
        iActorIndex += 1;
        kActorList[iActorIndex] = kCellList[iCellIndex].GetNthRef(iRefIndex, 43) as Actor;
      endIf
    endWhile
  endWhile

  return kActorList;
endFunction

;
; This function very simply will check for whether or not the actor has a weapon
; equipped to the left or right hand and remove them. If the actor is wielding
; a bow, it will also remove the arrows. If the actor is wielding magic, it will
; swap them to fists.
;
function DisarmActor(Actor akActor)
  Form kLeftEquip = akActor.GetEquippedObject(0); Left Hand = 0
  Form kRightEquip = akActor.GetEquippedObject(1); Right Hand = 1
  Form kShoutEquip = akActor.GetEquippedObject(2); Shout = 2

  Ammo kAmmoEquip = None;
  int iAmmoCount = 0;

  int iLeftType = akActor.GetEquippedItemType(0); Left Hand = 0
  int iRightType = akActor.GetEquippedItemType(1); Right Hand = 1

  if iLeftType != 9 && iLeftType != 0
    akActor.UnequipItemEx(kLeftEquip, equipSlot = 2, preventEquip = false); Left Hand = 2
    akActor.RemoveItem(kLeftEquip, aiCount = 1, abSilent = true, akOtherContainer = None);
  elseif iLeftType == 9
    akActor.UnequipSpell(kLeftEquip as Spell, 0); Left Hand = 0
  endIf

  if iRightType != 9 && iRightType != 0
    akActor.UnequipItemEx(kRightEquip, equipSlot = 1, preventEquip = false); Right Hand = 1
    akActor.RemoveItem(kRightEquip, aiCount = 1, abSilent = true, akOtherContainer = None);
  elseif iRightType == 9
    akActor.UnequipSpell(kRightEquip as Spell, 1); Right Hand = 1
  endIf

  if iRightType == 7 || iRightType == 12 || iLeftType == 7 || iLeftType == 12
    kAmmoEquip = GetEquippedAmmo(akActor);
    iAmmoCount = akActor.GetItemCount(kAmmoEquip as Form);
    if kAmmoEquip && iAmmoCount
      akActor.UnequipItemEx(kAmmoEquip, equipSlot = 0, preventEquip = false); Default = 0
      akActor.RemoveItem(kAmmoEquip, aiCount = iAmmoCount, abSilent = true, akOtherContainer = None);
    endIf
  endIf

  if kShoutEquip
    akActor.UnequipShout(kShoutEquip as Shout);
  endIf
endFunction

;
; This function will allow us to look near an actor (or corpse) for a specific form.
; It will return the reference for us to do with as we please.
; This will return None if the form cannot be found, otherwise it returns the form.
;
Form function GetNearbyForm(Actor kActor, Form kTargetForm)
    Cell kCell = kActor.GetParentCell();
    int iFormTypeFilter = kTargetForm.GetType();
    int iFormCount = kCell.GetNumRefs(iFormTypeFilter);
    int iFormIndex = -1;
    Form kCurrentForm = None;
    Form kLocatedForm = None;

    while iFormIndex < iFormCount && !kLocatedForm
        iFormIndex += 1;
        kCurrentForm = kCell.GetNthRef(iFormIndex, iFormTypeFilter) as Form;
        if kCurrentForm == kTargetForm
            kLocatedForm = kCurrentForm;
        endIf
    endWhile
    
    return kLocatedForm;
endFunction

;
; This function will allow us to look near an actor (or corpse) for a
; weapon of some kind. If we find one, we'll check in the actor's inventory.
; If it's present, return it, otherwise, no.
;
Weapon function FindNearbyWeapon(Actor kActor)
    Cell kCell = kActor.GetParentCell();
    int iFormTypeFilter = 41; kWeapon = 41
    int iFormCount = kCell.GetNumRefs(iFormTypeFilter);
    int iFormIndex = -1;
    Form kCurrentForm = None;
    Form kLocatedForm = None;

    while iFormIndex < iFormCount && !kLocatedForm
        iFormIndex += 1;
        kCurrentForm = kCell.GetNthRef(iFormIndex, 41) as Form;
        if kActor.GetItemCount(kCurrentForm)
            kLocatedForm = kCurrentForm;
        endIf
    endWhile

    return kLocatedForm as Weapon;
endFunction

;
; This function will search the given actor's inventory for the highest
; value weapon. If the weapon type is anything but zero, it will look
; for a specific type. On zero, it will just return the highest value weapon.
;
Weapon function GetHighestValueWeapon(Actor akActor, int aiWeaponType = 0)
    int iInventoryLength = akActor.GetNumItems();
    int iInventoryIndex = -1;
    int iHighestValue = -1;
    Form kCurrentForm = None;
    Weapon kActorWeapon = None;

    while iInventoryIndex < iInventoryLength
        iInventoryIndex += 1;
        kCurrentForm = akActor.GetNthForm(iInventoryIndex);
        ; Now, we handle whether we are looking for a specific item type
        ; or not.
        if aiWeaponType
            if kCurrentForm.GetType() == 41 && (kCurrentForm as Weapon).GetWeaponType() == aiWeaponType && kCurrentForm.GetGoldValue() > iHighestValue; kWeapon = 41
                kActorWeapon = kCurrentForm as Weapon;
                iHighestValue = kCurrentForm.GetGoldValue();
                kCurrentForm = None;
            endIf
        else
            if kCurrentForm.GetType() == 41 && kCurrentForm.GetGoldValue() > iHighestValue; kWeapon = 41
                kActorWeapon = kCurrentForm as Weapon;
                iHighestValue = kCurrentForm.GetGoldValue();
                kCurrentForm = None;
            endIf
        endIf
    endWhile
endFunction


;
; As far as I can tell, there is no baked-in function to pull what ammo
; is equipped by an actor. This function goes around the station to get to
; the train in front of it, so to speak.
;
Ammo function GetEquippedAmmo(Actor akActor)
    int iInventoryLength = akActor.GetNumItems();
    int iInventoryIndex = -1;
    Form kCurrentForm = None;
    Ammo kActorAmmo = None;

    while iInventoryIndex < iInventoryLength && !kActorAmmo
        iInventoryIndex += 1;
        kCurrentForm = akActor.GetNthForm(iInventoryIndex);
        if kCurrentForm.GetType() == 42 && akActor.IsEquipped(kCurrentForm); kAmmo = 42
            kActorAmmo = kCurrentForm as Ammo;
            kCurrentForm = None;
        endIf
    endWhile
    return kActorAmmo;
endFunction

;
; This function returns an array of the weapons, spells, and shouts equipped.
;
Form[] function GetEquippedForm(Actor akActor)
  Form[] kEquipment = new Form[4];
  kEquipment[EQSLOT_LEFT] = akActor.GetEquippedObject(0);
  kEquipment[EQSLOT_RIGHT] = akActor.GetEquippedObject(1);
  kEquipment[EQSLOT_SHOUT] = akActor.GetEquippedObject(2);
  kEquipment[EQSLOT_AMMO] = GetEquippedAmmo(akActor) as Form;

  return kEquipment;
endFunction