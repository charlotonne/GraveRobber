ScriptName charlock_npcAutoEquip Extends ActiveMagicEffect  

Actor property PlayerRef Auto
Actor TargetRef
Weapon TargetLeftWeapon
Weapon TargetRightWeapon

Event OnInit()
	TargetRef = GetCasterActor()
	TargetLeftWeapon = TargetRef.GetEquippedWeapon(true)
	TargetRightWeapon = TargetRef.GetEquippedWeapon(false)
EndEvent

Event OnDying(Actor akKiller)
	If akKiller == PlayerRef
		Weapon PlayerLeftWeapon = PlayerRef.GetEquippedWeapon(true)
		Weapon PlayerRightWeapon = PlayerRef.GetEquippedWeapon(false)

		If PlayerLeftWeapon
			PlayerRef.UnequipItem(PlayerLeftWeapon, false, true)
			PlayerRef.RemoveItem(PlayerLeftWeapon, 1, true, None)
		EndIf
		If PlayerRightWeapon
			PlayerRef.UnequipItem(PlayerRightWeapon, false, true)
			PlayerRef.RemoveItem(PlayerRightWeapon, 1, true, None)
		EndIf

		If TargetLeftWeapon
			TargetRef.UnequipItem(TargetLeftWeapon, false, true)
			;Debug.MessageBox("Unequipped Left weapon")
			TargetRef.RemoveItem(TargetLeftWeapon, 1, true, None)
			;Debug.MessageBox("removed Left weapon")
			PlayerRef.AddItem(TargetLeftWeapon, 1, true)
			;Debug.MessageBox("added Left weapon")
			PlayerRef.EquipItemEx(TargetLeftWeapon, 2, false, true)
			;Debug.MessageBox("equipped Left weapon" + TargetLeftWeapon.GetName())
		EndIf
		If TargetRightWeapon
			TargetRef.UnequipItem(TargetRightWeapon, false, true)
			;Debug.MessageBox("Unequipped right weapon")
			TargetRef.RemoveItem(TargetRightWeapon, 1, true, None)
			;Debug.MessageBox("removed right weapon")
			PlayerRef.AddItem(TargetRightWeapon, 1, true)
			;Debug.MessageBox("added right weapon")
			PlayerRef.EquipItemEx(TargetRightWeapon, 1, false, true)
			;Debug.MessageBox("equipped right weapon: " + TargetRightWeapon.GetName())
		EndIf

		;Debug.Notification("Your terrible curse has activated ...")
	EndIf
EndEvent