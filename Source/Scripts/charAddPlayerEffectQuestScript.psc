Scriptname charAddPlayerEffectQuestScript extends Quest
{Automatically equips the player with the ability}

Actor property PlayerRef auto
Spell property charGraveRobberPlayerEffectSpell auto

Event OnInit()
	Utility.Wait(1)
	PlayerRef.AddSpell(charGraveRobberPlayerEffectSpell, false)
	Utility.Wait(1)
	self.Stop()
EndEvent