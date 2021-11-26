Scriptname charlock_addAutoEquip extends Quest
{Automatically equips the player with the ability}

Actor property PlayerRef auto
Spell property charlock_autoEquipSpell auto

Event OnInit()
	Utility.Wait(1)
	PlayerRef.AddSpell(charlock_autoEquipSpell, false)
	Utility.Wait(1)
	self.Stop()
EndEvent
