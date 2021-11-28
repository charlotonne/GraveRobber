ScriptName charNPCListenerMagicEffectScript Extends ActiveMagicEffect  
{This script contains the effect necessary for the NPC to operate.}

charGraveRobberLibraryQuestScript GraveRobber = None;

Actor property PlayerRef Auto

; We are declaring these ahead of time in order to use them in both events.
Actor TargetRef;
Form TargetLeftEquip;
Form TargetRightEquip;
Form TargetShout;
Form[] TargetEquipped;
Ammo TargetAmmo;

int TargetLeftType;
int TargetRightType;

Event OnInit()
	GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

	; This will allow us to work with the player's target and listen for their death.
	; Additionally, we declare it here so that we can pre-grab what their equipped weapon is.
  
	TargetRef = GetTargetActor();
  TargetEquipped = GraveRobber.GetEquippedForm(TargetRef);

	TargetLeftEquip = TargetEquipped[0];
	TargetRightEquip = TargetEquipped[1];
  TargetShout = TargetEquipped[2];
  TargetAmmo = GraveRobber.GetEquippedAmmo(TargetRef);

  TargetLeftType = TargetRef.GetEquippedItemType(0); Left Hand = 0
  TargetRightType = TargetRef.GetEquippedItemType(1); Right Hand = 1
EndEvent

Event OnEffectStart(Actor akTarget, Actor akCaster)
  GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

  TargetRef = akTarget;
  TargetEquipped = GraveRobber.GetEquippedForm(TargetRef);

	TargetLeftEquip = TargetEquipped[0];
	TargetRightEquip = TargetEquipped[1];
  TargetShout = TargetEquipped[2];
  TargetAmmo = GraveRobber.GetEquippedAmmo(TargetRef);

  TargetLeftType = TargetRef.GetEquippedItemType(0); Left Hand = 0
  TargetRightType = TargetRef.GetEquippedItemType(1); Right Hand = 1
endEvent

; We're going to update the equipped weapon whenever the NPC
; enters into combat.
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

	if aeCombatState == 1; In Combat = 1
		TargetRef = GetTargetActor();
    TargetEquipped = GraveRobber.GetEquippedForm(TargetRef);

	  TargetLeftEquip = TargetEquipped[0];
	  TargetRightEquip = TargetEquipped[1];
    TargetShout = TargetEquipped[2];
    TargetAmmo = GraveRobber.GetEquippedAmmo(TargetRef);

    TargetLeftType = TargetRef.GetEquippedItemType(0); Left Hand = 0
    TargetRightType = TargetRef.GetEquippedItemType(1); Right Hand = 1
	endIf
endEvent

; We also want to capture whenever the actor changes what they have equipped.
Event onObjectEquipped(Form akBaseObject, ObjectReference akReference)
  GraveRobber = charGraveRobberLibraryQuestScript.GetScript();

  TargetRef = GetTargetActor();
  TargetEquipped = GraveRobber.GetEquippedForm(TargetRef);

  TargetLeftEquip = TargetEquipped[0];
  TargetRightEquip = TargetEquipped[1];
  TargetShout = TargetEquipped[2];
  TargetAmmo = GraveRobber.GetEquippedAmmo(TargetRef);

  TargetLeftType = TargetRef.GetEquippedItemType(0); Left Hand = 0
  TargetRightType = TargetRef.GetEquippedItemType(1); Right Hand = 1
endEvent

; This is the actual weapon swap script.
; It will occur whenever this particular NPC bites the dust.
Event OnDeath(Actor akKiller)
  GraveRobber = charGraveRobberLibraryQuestScript.GetScript();
  
  int iAmmoCount = 0;
	; We need to make sure that the event was triggered specifically
	; by the player killing the NPC.
	if akKiller == PlayerRef
    ; Let's strip the player of their equipped stuff first.
    GraveRobber.DisarmActor(PlayerRef);
    ; Now, let's ensure that we know about some equipped stuff.
    if TargetLeftEquip || TargetRightEquip
      ; Fantastic! We know there's some stuff to equip. Hot diggidy!
      ; Now we can put these onto the player!
      if TargetLeftEquip
        Debug.MessageBox(TargetLeftEquip + " found in left hand.");
        if TargetLeftType != 0 && TargetLeftType != 9
          PlayerRef.AddItem(TargetLeftEquip, aiCount = 1, abSilent = true);
          PlayerRef.EquipItemEx(TargetLeftEquip, equipSlot = 2, preventUnequip = false, equipSound = false);
        elseif TargetLeftType == 9
          if !PlayerRef.HasSpell(TargetLeftEquip as Spell)
            PlayerRef.AddSpell(TargetLeftEquip as Spell);
          endIf
          PlayerRef.EquipSpell(TargetLeftEquip as Spell, 0);
        endif
      endif
      if TargetRightEquip
        Debug.MessageBox(TargetRightEquip + " found in right hand.");
        if TargetRightType != 0 && TargetRightType != 9
          PlayerRef.AddItem(TargetRightEquip, aiCount = 1, abSilent = true);
          PlayerRef.EquipItemEx(TargetRightEquip, equipSlot = 1, preventUnequip = false, equipSound = false);
        elseif TargetRightType == 9
          if !PlayerRef.HasSpell(TargetRightEquip as Spell)
            PlayerRef.AddSpell(TargetRightEquip as Spell);
          endIf
          PlayerRef.EquipSpell(TargetRightEquip as Spell, 1);
        endif
      endif
    endIf

    if TargetShout
      PlayerRef.AddShout(TargetShout as Shout);
      Game.TeachWord((TargetShout as Shout).GetNthWordOfPower(0));
      Game.TeachWord((TargetShout as Shout).GetNthWordOfPower(1));
      Game.TeachWord((TargetShout as Shout).GetNthWordOfPower(2));
      PlayerRef.EquipShout(TargetShout as Shout);
    endIf

    if TargetRightType == 7 || TargetRightType == 12 || TargetLeftType == 7 || TargetLeftType == 12
      iAmmoCount = TargetRef.GetItemCount(TargetAmmo);
      PlayerRef.AddItem(TargetAmmo, aiCount = iAmmoCount, abSilent = true);
      PlayerRef.EquipItem(TargetAmmo, abPreventRemoval = false, abSilent = true);
    endIf
	endIf
endEvent