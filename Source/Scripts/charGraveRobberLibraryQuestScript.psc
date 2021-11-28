ScriptName charGraveRobberLibraryQuestScript Extends Quest

Static property XMarker auto;
Actor property PlayerRef auto;

;
; This function allows for the script itself to be used by other scripts
;
charGraveRobberLibraryQuestScript function GetScript() global
	return Game.GetFormFromFile(0x00000809, "GraveRobber.esp") as charGraveRobberLibraryQuestScript;
endFunction

;
; This function was modified from the helpful comment of Xander9009 in this Creation Kit Wiki
; discussion thread:
; https://www.creationkit.com/index.php?title=Talk:GetDialogueTarget_-_Actor
;
; The purpose of this function is to return an array of actors near to the player.
; It will continue either until the requested actor count is reached, or until it has
; exhausted all actors in the given radius.
;
Actor[] function GetNearbyActors(float fRadius = 4096.00, int iStep = 5)
    Actor kPlayerRef = PlayerRef;
    Actor[] kTargetRef = new Actor[10];
    Actor kNthRef = None;

    Cell kCell = kPlayerRef.GetParentCell();
    int iType = 43; kNPC = 43
    int iIndex = kCell.GetNumRefs(iType);
    int iActorIndex = -1;
    int Degrees = 360;

    while iActorIndex < kTargetRef.Length
        iActorIndex += 1;

        while iIndex
            iIndex -= 1;
            kNthRef = kCell.GetNthRef(iIndex, iType) as Actor;
            if kNthRef != kPlayerRef
                kTargetRef[iActorIndex] = kNthRef;
                iActorIndex += 1;
            endIf
        endWhile

        if iActorIndex < kTargetRef.Length
            ObjectReference kXMarker = kPlayerRef.PlaceAtMe(XMarker, 1);
            Cell[] kCellA = New Cell[10];
            kCellA[0] = kCell;
            kXMarker.MoveTo(kPlayerRef, fRadius);
            iIndex = kCellA.Length;
            while Degrees > 0 && iActorIndex < kTargetRef.Length
                while iIndex
                    iIndex -= 1;
                    if kCellA[iIndex] == kXMarker.GetParentCell()
                        iIndex = -1;
                    endIf
                endWhile

                if iIndex != -1
                    iIndex = 0;
                    int iEmptyIndex;

                    while iIndex < kCellA.Length && !iEmptyIndex
                        if !kCellA[iIndex]
                            iEmptyIndex = iIndex;
                        endIf
                        iIndex += 1;
                    endWhile

                    kCellA[iEmptyIndex] = kXMarker.GetParentCell();
                    iIndex = kCell.GetNumRefs(iType);

                    while iIndex && iActorIndex < kTargetRef.Length
                        iIndex -= 1;
                        kNthRef = kCell.GetNthRef(iIndex, iType) as Actor;
                        if kNthRef != kPlayerRef
                            kTargetRef[iActorIndex] = kNthRef;
                            iActorIndex += 1
                        endIf
                    endWhile
                endIf

                Degrees -= iStep;
                float PosX = Math.Cos(Degrees) * fRadius;
                float PosY = Math.Cos(Degrees) * fRadius;
                kXMarker.MoveTo(kPlayerRef, PosX, PosY);
            endWhile
            kXMarker.Delete()
        endIf
        if Degrees <= 0 && iActorIndex < kTargetRef.Length
            iActorIndex = kTargetRef.Length;
        endIf
    endWhile
    return kTargetRef;
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
; This function will try every avenue that it can to locate what this actor
; either has equipped or should have equipped. There are a few checks that
; we can do to get to some sort of answer.
;
Form[] function GetEquippedForm(Actor akActor)
  Form kRightEquip = akActor.GetEquippedObject(1); Right Hand = 1
  Form kLeftEquip = akActor.GetEquippedObject(0); Left Hand = 0
  Form kShout = akActor.GetEquippedObject(2); Shout = 2

  Form[] kEquipment = new Form[3];
  kEquipment[0] = None;
  kEquipment[1] = None;
  kEquipment[2] = None;

  Form kFoundWeapon = None;

  if !kRightEquip && !kLeftEquip
    if akActor.IsDead()
      kFoundWeapon = FindNearbyWeapon(akActor);
      if kFoundWeapon
        kRightEquip = kFoundWeapon;
      else
        kFoundWeapon = GetHighestValueWeapon(akActor, aiWeaponType = 0);
        if kFoundWeapon
          kRightEquip = kFoundWeapon;
        endIf
      endIf
    endIf
  endif

  kEquipment[0] = kLeftEquip;
  kEquipment[1] = kRightEquip;
  kEquipment[2] = kShout;

  return kEquipment;
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