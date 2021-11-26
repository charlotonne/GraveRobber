ScriptName charlock_helperFunctions Extends Quest

Static property XMarker auto;

;
; This function allows for the script itself to be used by other scripts
;
charlock_helperFunctions function GetScript() global
	return Game.GetFormFromFile(0x00000809, "GraveRobber.esp") as charlock_helperFunctions
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
    Actor kPlayerRef = Game.GetPlayer();
    Actor[] kTargetRef = new Actor[50];
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
function RemoveActorWeapons(Actor kActorRef)
    Weapon kActorRightWeapon = kActorRef.GetEquippedWeapon(false);
    Weapon kActorLeftWeapon = kActorRef.GetEquippedWeapon(true);
    Spell kActorRightSpell = kActorRef.GetEquippedSpell(1); Right Hand = 1
    Spell kActorLeftSpell = kActorRef.GetEquippedSpell(0); Left Hand = 0

    int iInventoryIndex = -1;
    int iInventoryLength = (kActorRef as ObjectReference).GetNumItems();
    Form kCurrentForm = None;
    Ammo kActorAmmo = None;
    int iAmmoCount = 0;

    ; In this check, we'll be removing the actor's ammunition if they have a ranged weapon wielded.
    ; We'll first check if the player has either a left or right weapon.
    if kActorRightWeapon || kActorLeftWeapon
        ; Now, we need to check if the weapon is a bow or crossbow.
        ; Bow = 7
        ; Crossbow = 9
        if kActorRightWeapon.GetWeaponType() == 7 || kActorRightWeapon.GetWeaponType() == 9 || kActorLeftWeapon.GetWeaponType() == 7 || kActorLeftWeapon.GetWeaponType() == 9
            ; Now, we'll be cycling through the actor's inventory for any equipped ammo.
            ; I'll be honest -- I'm doing it this way because I have no idea what slot ammo is equipped to.
            ; And it doesn't seem to be documented anywhere.
            kActorAmmo = GetEquippedAmmo(kActorRef);
            ; Just in case we couldn't find any equipped ammo, we'll check to ensure it exists.
            if kActorAmmo
                iAmmoCount = (kActorRef as ObjectReference).GetItemCount(kActorAmmo);
                kActorRef.UnequipItem(kActorAmmo, abPreventEquip = false, abSilent = true);
                kActorRef.RemoveItem(kActorAmmo, aiCount = iAmmoCount, abSilent = true);
            endIf
        endIf
    endIf

    ; Alright, now we'll cycle through whether or not the actor is wielding a standard weapon.
    ; If they are, we'll yank that right off of them.
    if kActorRightWeapon
        kActorRef.UnequipItem(kActorRightWeapon, abPreventEquip = false, abSilent = true);
        kActorRef.RemoveItem(kActorRightWeapon, aiCount = 1, abSilent = true);
    endIf
    if kActorLeftWeapon
        kActorRef.UnequipItem(kActorLeftWeapon, abPreventEquip = false, abSilent = true);
        kActorRef.RemoveItem(kActorLeftWeapon, aiCount = 1, abSilent = true);
    endIf

    ; Finally, we need to check for whether or not the actor is wielding a spell so we can stop that.
    if kActorRightSpell
        kActorRef.UnequipSpell(kActorRightSpell, 1); Right Hand = 1
    endIf
    if kActorLeftSpell
        kActorRef.UnequipSpell(kActorRightSpell, 0); Left Hand = 0
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
    
    return kCurrentForm;
endFunction

;
; This function will return the weapon currently wielded by the given Actor.
; If no weapon is wielded, we will check if they have ammo equipped.
; If they do, we'll return the ranged weapon of highest value.
; Otherwise, we will return the melee weapon of highest value.
; If no weapons are present, we will return None.
;
Form function FindEquippedForm(Actor kActor, bool leftHand = false)
    Weapon kWeaponLeft = kActor.GetEquippedWeapon(true);
    Weapon kWeaponRight = kActor.GetEquippedWeapon(false);
    Weapon kWeaponDesired = kActor.GetEquippedWeapon(leftHand);
    Ammo kEquippedAmmo = GetEquippedAmmo(kActor);

    Spell kSpellLeft = kActor.GetEquippedSpell(0); Left Hand = 0
    Spell kSpellRight = kActor.GetEquippedSpell(1); Right Hand = 1
    Spell kSpellDesired = kActor.GetEquippedSpell((!leftHand) as int);

    Form kFormDesired = None;
    
    ; If there is no weapon or spell in any slot, we'll check
    ; through the inventory.
    if !kWeaponLeft && !kWeaponRight && !kSpellLeft && !kSpellRight
        ; Let's see if this actor has ammo equipped for some reason and no weapon.
        if kEquippedAmmo
            ; Now, we need to check if the ammo is bolts so we know what
            ; weapon to look for in the inventory.
            if kEquippedAmmo.IsBolt()
                kWeaponDesired = GetHighestValueWeapon(kActor, 9); Crossbows = 9
            else
                kWeaponDesired = GetHighestValueWeapon(kActor, 7); Bows = 7
            endIf
        else
            ; Well, that was a bust, so we need to search through the inventory
            ; for the highest value weapon.
            kWeaponDesired = GetHighestValueWeapon(kActor);
        endIf
    endIf
    if kWeaponDesired && !kSpellDesired
        kFormDesired = kWeaponDesired;
    elseif kSpellDesired && !kWeaponDesired
        kFormDesired = kSpellDesired;
    else
        kFormDesired = None
    endIf
    return kFormDesired;
endFunction

;
; This function will search the given actor's inventory for the highest
; value weapon. If the weapon type is anything but zero, it will look
; for a specific type. On zero, it will just return the highest value weapon.
;
Weapon function GetHighestValueWeapon(Actor kActor, int iWeaponType = 0)
    int iInventoryLength = (kActor as ObjectReference).GetNumItems();
    int iInventoryIndex = -1;
    int iHighestValue = -1;
    Form kCurrentForm = None;
    Weapon kActorWeapon = None;

    while iInventoryIndex < iInventoryLength
        iInventoryIndex += 1;
        kCurrentForm = kActor.GetNthForm(iInventoryIndex);
        ; Now, we handle whether we are looking for a specific item type
        ; or not.
        if iWeaponType
            if kCurrentForm.GetType() == 41 && (kCurrentForm as Weapon).GetWeaponType() == iWeaponType && kCurrentForm.GetGoldValue() > iHighestValue; kWeapon = 41
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
Ammo function GetEquippedAmmo(Actor kActor)
    int iInventoryLength = (kActor as ObjectReference).GetNumItems();
    int iInventoryIndex = -1;
    Form kCurrentForm = None;
    Ammo kActorAmmo = None;
    int iAmmoCount = 0;

    while iInventoryIndex < iInventoryLength && !kActorAmmo
        iInventoryIndex += 1;
        kCurrentForm = kActor.GetNthForm(iInventoryIndex);
        if kCurrentForm.GetType() == 42 && kActor.IsEquipped(kCurrentForm); kAmmo = 42
            kActorAmmo = kCurrentForm as Ammo;
            iAmmoCount = (kActor as ObjectReference).GetItemCount(kCurrentForm);
            kCurrentForm = None;
        endIf
    endWhile
    return kActorAmmo;
endFunction