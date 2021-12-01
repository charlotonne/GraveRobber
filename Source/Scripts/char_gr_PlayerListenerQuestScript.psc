Scriptname char_gr_PlayerListenerQuestScript extends Quest
{Automatically equips the player with the ability}

Actor property PlayerRef auto
Spell property char_gr_PlayerListenerSpell auto

Event OnInit()
	Utility.Wait(1)
	PlayerRef.AddSpell(char_gr_PlayerListenerSpell, false)
	Utility.Wait(1)
	self.Stop()
EndEvent