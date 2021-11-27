ScriptName charlock_npcAutoEquip Extends ActiveMagicEffect  
{This script contains the effect necessary for the NPC to operate.}

; This will allow us to use the functions located in charlock_helperFunctions
charlock_helperFunctions hFunc = None;

Actor property PlayerRef Auto

; We are declaring these ahead of time in order to use them in both events.
Actor TargetRef
Form TargetLeftWeapon
Form TargetRightWeapon

Event OnInit()
	hFunc = charlock_helperFunctions.GetScript();
	; This will allow us to work with the player's target and listen for their death.
	; Additionally, we declare it here so that we can pre-grab what their equipped weapon is.
	TargetRef = GetTargetActor();
	TargetLeftWeapon = hFunc.FindEquippedForm(TargetRef, true);
	TargetRightWeapon = hFunc.FindEquippedForm(TargetRef, false);
EndEvent

; We're going to update the equipped weapon whenever the NPC
; enters into combat.
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if aeCombatState == 1
		TargetLeftWeapon = hFunc.FindEquippedForm(TargetRef, true);
		TargetRightWeapon = hFunc.FindEquippedForm(TargetRef, false);
	endIf
endEvent

; This is the actual weapon swap script.
; It will occur whenever this particular NPC bites the dust.
Event OnDeath(Actor akKiller)
	int iLeftType = -1;
	int iRightType = -1;
	int iAmmoCount = 0;
	Ammo kAmmo = None;

	; We need to make sure that the event was triggered specifically
	; by the player killing the NPC.
	if akKiller == PlayerRef
		; Now that we know the player has murdered, it's time to
		; yoink their current weapons.
		hFunc.RemoveActorWeapons(PlayerRef);

		; Now, we need to look to see if the NPC is wielding anything.
		if TargetLeftWeapon || TargetRightWeapon
			; So far, so good. Now let's check if the left weapon exists.
			if TargetLeftWeapon
				; It does, so we need to get the form type to properly handle it.
				iLeftType = TargetLeftWeapon.GetType();
				if iLeftType == 41; kWeapon = 41
					; First, we'll unequip and remove the item from the target.
					; We'll also check around the target to ensure it didn't just drop into the world.
					TargetRef.UnequipItemEx(TargetLeftWeapon, equipSlot = 2, preventEquip = false);
					TargetRef.RemoveItem(TargetLeftWeapon, aiCount = 1, abSilent = true);
					(hFunc.GetNearbyForm(TargetRef, TargetLeftWeapon) as ObjectReference).DisableNoWait(true);
					; Now, we can add and equip the weapon to the proper slot on the player.
					PlayerRef.AddItem(TargetLeftWeapon, aiCount = 1, abSilent = true);
					PlayerRef.EquipItemEx(TargetLeftWeapon, equipSlot = 2, preventUnequip = false, equipSound = false);
				elseif iLeftType == 22; kSpell = 22
					; There's nowhere near the same amount of stuff to do here.
					; We just need to check if the player has the spell, add it if not.
					; Then equip the spell to the player.
					if !PlayerRef.HasSpell(TargetLeftWeapon as Spell)
						PlayerRef.AddSpell(TargetLeftWeapon as Spell, abVerbose = false);
					endIf
					PlayerRef.EquipSpell(TargetLeftWeapon as Spell, 0); Left Hand = 0
				endIf
			endIf

			; We do the same thing for the right hand
			if TargetRightWeapon
				; It does, so we need to get the form type to properly handle it.
				iRightType = TargetRightWeapon.GetType();
				if iRightType == 41; kWeapon = 41
					; First, we'll unequip and remove the item from the target.
					; We'll also check around the target to ensure it didn't just drop into the world.
					TargetRef.UnequipItemEx(TargetRightWeapon, equipSlot = 1, preventEquip = false);
					TargetRef.RemoveItem(TargetRightWeapon, aiCount = 1, abSilent = true);
					(hFunc.GetNearbyForm(TargetRef, TargetRightWeapon) as ObjectReference).DisableNoWait(true);
					; Now, we can add and equip the weapon to the proper slot on the player.
					PlayerRef.AddItem(TargetRightWeapon, aiCount = 1, abSilent = true);
					PlayerRef.EquipItemEx(TargetRightWeapon, equipSlot = 0, preventUnequip = false, equipSound = false);
				elseif iRightType == 22; kSpell = 22
					; There's nowhere near the same amount of stuff to do here.
					; We just need to check if the player has the spell, add it if not.
					; Then equip the spell to the player.
					if !PlayerRef.HasSpell(TargetRightWeapon)
						PlayerRef.AddSpell(TargetRightWeapon as Spell, abVerbose = false);
					endIf
					PlayerRef.EquipSpell(TargetRightWeapon as Spell, 1); Right Hand = 1
				endIf
			endIf

			if iRightType == 41 && !kAmmo && !iAmmoCount
				if (TargetRightWeapon as Weapon).GetWeaponType() == 9 || (TargetRightWeapon as Weapon).GetWeaponType() == 7
					kAmmo = GetEquippedAmmo(TargetRef);
					iAmmoCount = (TargetRef as ObjectReference).GetItemCount(kAmmo);
				endIf
			endIf
			if iLeftType == 41 && !kAmmo && !iAmmoCount
				if (TargetLeftWeapon as Weapon).GetWeaponType() == 9 || (TargetLeftWeapon as Weapon).GetWeaponType() == 7
					kAmmo = GetEquippedAmmo(TargetRef);
					iAmmoCount = (TargetRef as ObjectReference).GetItemCount(kAmmo);
				endIf
			endIf
			if kAmmo && iAmmoCount
				PlayerRef.AddItem(kAmmo, aiCount = iAmmoCount, abSilent = true);
				PlayerRef.EquipItemEx(kAmmo, equipSlot = 0, preventUnequip = false, equipSound = false);
			endIf
		endIf
	endIf
endEvent