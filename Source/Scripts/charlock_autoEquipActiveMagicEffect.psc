ScriptName charlock_autoEquipActiveMagicEffect extends ActiveMagicEffect

Actor property PlayerRef auto
Spell property charlock_npcAutoEquipSpell auto

Weapon Function GetHighestValueWeapon(Actor akActor)
	Int iLoopCount = (akActor as ObjectReference).GetNumItems()
	Int highestValue = -1
	Form highestValWeapon
	While iLoopCount > 0
		iLoopCount -= 1
		Form kForm = (akActor as ObjectReference).GetNthForm(iLoopCount)
		If kForm.GetType() == 41 && kForm.GetGoldValue() > highestValue
			highestValWeapon = kForm
			highestValue = kform.GetGoldValue()
		EndIf
	EndWhile
	return highestValWeapon as Weapon
EndFunction

Event OnInit()
	RegisterForActorAction(0)
	RegisterForActorAction(6)
	;Debug.MessageBox("Successfully initiated the autoequip MagicEffect.")
EndEvent

Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	;Debug.MessageBox("Well, you certainly did something!")
	If akActor == PlayerRef
		Actor TargetRef = Game.GetCurrentCrosshairRef() as Actor

		If TargetRef
			Debug.MessageBox("Got target ref: " + TargetRef)
			If TargetRef.IsDead() && TargetRef.GetKiller() == PlayerRef
				Weapon PlayerLeftWeapon = PlayerRef.GetEquippedWeapon(true)
				Weapon PlayerRightWeapon = PlayerRef.GetEquippedWeapon(false)
				Weapon TargetRightWeapon = GetHighestValueWeapon(TargetRef)
				Weapon TargetLeftWeapon = TargetRef.GetEquippedWeapon(true)

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
			EndIf
			If !TargetRef.HasSpell(charlock_npcAutoEquipSpell)
				;Debug.Notification("Target got some sweet spell added")
				TargetRef.AddSpell(charlock_npcAutoEquipSpell)
			EndIf
		EndIf
	EndIf
EndEvent