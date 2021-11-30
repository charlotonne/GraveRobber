ScriptName char_gr_NPCListener extends ActiveMagicEffect

char_gr_FunctionLibrary GraveRobber = None;

Actor property PlayerRef auto;

Actor TargetRef = None;
Form TargetLeft = None;
Form TargetRight = None;
Form TargetShout = None;
Form TargetAmmo = None;
int TargetAmmoCount = 0;

function RemovePlayerEquipment()
  Form kLeft = GraveRobber.GetEquippedForm(PlayerRef, 0);
  Form kRight = GraveRobber.GetEquippedForm(PlayerRef, 1);
  Form kShout = GraveRobber.GetEquippedForm(PlayerRef, 2);
  Form kAmmo = GraveRobber.GetEquippedAmmo(PlayerRef) as Form;
  int iAmmoCount = 0;

  if kLeft && kLeft.GetType() != 22
    PlayerRef.UnequipItem(kLeft, abPreventEquip = false, abSilent = true);
    PlayerRef.RemoveItem(kLeft, aiCount = 1, abSilent = true);
  elseif kLeft
    PlayerRef.UnequipSpell(kLeft as Spell, 0);
  endIf

  if kRight && kRight.GetType() != 22
    PlayerRef.UnequipItem(kRight, abPreventEquip = false, abSilent = true);
    PlayerRef.RemoveItem(kRight, aiCount = 1, abSilent = true);
  elseif kRight
    PlayerRef.UnequipSpell(kRight as Spell, 1);
  endIf

  if kAmmo
    iAmmoCount = PlayerRef.GetItemCount(kAmmo);
    PlayerRef.UnequipItem(kAmmo, abPreventEquip = false, abSilent = true);
    PlayerRef.RemoveItem(kAmmo, aiCount = iAmmoCount, abSilent = true);
  endIf

  if kShout
    PlayerRef.UnequipShout(kShout as Shout);
  endIf
endFunction

function UpdateEquipment()
  TargetLeft = GraveRobber.GetEquippedForm(TargetRef, 0);
  TargetRight = GraveRobber.GetEquippedForm(TargetRef, 1);
  TargetShout = GraveRobber.GetEquippedForm(TargetRef, 2);
  TargetAmmo = GraveRobber.GetEquippedAmmo(TargetRef) as Form;
  TargetAmmoCount = TargetRef.GetItemCount(TargetAmmo);
endFunction

function EquipPlayer()
  GraveRobber.AddForm(PlayerRef, TargetLeft, 1);
  GraveRobber.AddForm(PlayerRef, TargetRight, 1);
  GraveRobber.AddForm(PlayerRef, TargetShout, 1);
  GraveRobber.AddForm(PlayerRef, TargetAmmo, TargetAmmoCount);

  GraveRobber.EquipForm(PlayerRef, TargetLeft, 0);
  GraveRobber.EquipForm(PlayerRef, TargetRight, 1);
  GraveRobber.EquipForm(PlayerRef, TargetShout, 2);
  GraveRobber.EquipForm(PlayerRef, TargetAmmo, 3);
endFunction

Event OnEffectStart(Actor akTarget, Actor akCaster)
  GraveRobber = char_gr_FunctionLibrary.EnableFunctions();
  TargetRef = akTarget;
  UpdateEquipment();
endEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
  if aeCombatState == 1
    UpdateEquipment();
  endIf
endEvent

Event OnDeath(Actor akKiller)
  if akKiller == PlayerRef
    RemovePlayerEquipment();
    EquipPlayer();
  endIf
endEvent