ScriptName charlock_autoEquipActiveMagicEffect extends ActiveMagicEffect

Actor property PlayerRef auto;
Spell property charlock_npcAutoEquipSpell auto;
charlock_helperFunctions hFunc = None;

; The moment this ability is attached to the player,
; we need to register a listener on three actions.
Event OnInit()
	hFunc = charlock_helperFunctions.GetScript();
	RegisterForActorAction(0); Weapon Swing = 0
	RegisterForActorAction(6); Bow Release = 6
	RegisterForActorAction(8); Draw End = 8
EndEvent

; Now to handle the previously registered listeners.
Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
	Actor[] kNearbyActors;
	int iActorIndex = -1;
	Actor TargetRef = Game.GetCurrentCrosshairRef() as Actor

	; First, let's ensure that it's the player that activated this particular action.
	if akActor == PlayerRef
		; Now, let's handle the main event, which is if the player has just drawn their weapon.
		if actionType == 8
			; First, we'll look for all actors that are close to the player.
			kNearbyActors = hFunc.GetNearbyActors()
			; Now, we iterate through those nearby actors and add the proper
			; magic effect onto them.
			while iActorIndex < kNearbyActors.Length
				iActorIndex += 1;
				if !kNearbyActors[iActorIndex].HasSpell(charlock_npcAutoEquipSpell)
					kNearbyActors[iActorIndex].AddSpell(charlock_npcAutoEquipSpell);
				endIf
			endWhile
		else
			; For the other listeners, we just want to double-check that whatever the player's
			; crosshairs are aimed at has also had the spell added.
			if !TargetRef.HasSpell(charlock_npcAutoEquipSpell)
				TargetRef.AddSpell(charlock_npcAutoEquipSpell);
			endIf
		endIf
	endIf
endEvent