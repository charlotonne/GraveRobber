ScriptName charAddListenerMagicEffectScript extends ActiveMagicEffect
{This script allows for the player to actually add the death listener onto NPCs}

Actor property PlayerRef auto;
Spell property charNPCListenerSpell auto;

charGraveRobberLibraryQuestScript GraveRobber = None;

; The moment this ability is attached to the player,
; we need to register a listener on three actions.
Event OnInit()
	GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

	RegisterForActorAction(0); Weapon Swing = 0
	RegisterForActorAction(6); Bow Release = 6
	RegisterForActorAction(8); Draw End = 8
EndEvent

; Now to handle the previously registered listeners.
Event OnActorAction(int actionType, Actor akActor, Form source, int slot)
  GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

	Actor[] kNearbyActors;
	int iActorIndex = 0;
	Actor TargetRef = Game.GetCurrentCrosshairRef() as Actor

	; First, let's ensure that it's the player that activated this particular action.
	if akActor == PlayerRef
    if actionType == 8
		  ; First, we'll look for all actors that are close to the player.
		  kNearbyActors = GraveRobber.GetNearbyActors()
		  ; Now, we iterate through those nearby actors and add the proper
		  ; magic effect onto them.
		  while iActorIndex < kNearbyActors.Length && kNearbyActors[iActorIndex]
			  kNearbyActors[iActorIndex].AddSpell(charNPCListenerSpell);
        iActorIndex += 1;
		  endWhile
    else
    ; We now want to double-check that whatever the player's
		; crosshairs are aimed at has also had the spell added.
		  if !TargetRef.HasSpell(charNPCListenerSpell);
			  TargetRef.AddSpell(charNPCListenerSpell);
		  endIf
	  endIf
  endIf
endEvent