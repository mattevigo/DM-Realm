# Shared starting state, sourced by case scaffolds: an English 2024 Workspace fresh
# from Setup, with one Campaign "Heroes". Every note here is INVENTED test content.
. "$(dirname "$0")/../_fixtures/workspace-setup.sh"
mkdir -p Campaigns/Heroes/NPCs Campaigns/Heroes/Sessions Campaigns/Heroes/Places Campaigns/Heroes/Quests Campaigns/Heroes/Factions Campaigns/Heroes/Attachments
printf '# Heroes\n\nA campaign on the northern border of Orsenna, the DM'"'"'s own world.\n' > Campaigns/Heroes/README.md

# Stub notes the scenario cases act on. Official ones are INVENTED placeholders with a
# source property, standing in for imported material (ADR 0003: no real data here).
mkdir -p Reference/Spells/Level_3 Reference/Feats Reference/Setting/Forgotten_Realms
printf -- '---\nsource: XPHB p. 241, v3.0.0\n---\n\n# Fireball\n\n(Placeholder for the imported official text.)\n' > Reference/Spells/Level_3/Fireball.md
printf -- '---\nsource: XPHB p. 200, v3.0.0\n---\n\n# Alert\n\n(Placeholder for the imported official text.)\n' > Reference/Feats/Alert.md
printf '# Neverwinter\n\nThe Jewel of the North, as the official lore describes it.\n' > Reference/Setting/Forgotten_Realms/Neverwinter.md
mkdir -p Adventures/The_Sunken_Keep/Places Adventures/The_Sunken_Keep/NPCs Adventures/The_Lost_Road/NPCs
printf '# The Sunken Keep\n\nA published adventure (test stub).\n' > Adventures/The_Sunken_Keep/README.md
printf '# Stonehill Inn\n\nA busy inn run by a retired soldier.\n' > Adventures/The_Sunken_Keep/Places/Stonehill_Inn.md
printf '# Glasstaff\n\nA wizard hiding in the keep.\n' > Adventures/The_Sunken_Keep/NPCs/Glasstaff.md
printf '# Sildar\n\nA knight of the Lords'"'"' Alliance.\n' > Adventures/The_Lost_Road/NPCs/Sildar.md
mkdir -p Homebrew/Monsters DM_Tools/Checklists
printf '# Ash Wraith\n\nA spirit of cinders, reusable in any campaign.\n' > Homebrew/Monsters/Ash_Wraith.md
printf '# Session Prep\n\n- [ ] Review last session\n' > DM_Tools/Checklists/Session_Prep.md
printf '# Session 3: Into the Keep\n\nThe party reached the keep. On the way they met [[Campaigns/Heroes/NPCs/Mira_Vell|Mira Vell]].\n' > Campaigns/Heroes/Sessions/Session_03_Into_the_Keep.md
printf '# Session 5: Fire\n\nA fight broke out in town.\n' > Campaigns/Heroes/Sessions/Session_05_Fire.md
printf '# Session 8: Ambush\n\nThe cultists struck on the road.\n' > Campaigns/Heroes/Sessions/Session_08_Ambush.md
mkdir -p Characters/Ayla Characters/Brom Characters/Durga/Past_Builds
printf '# Ayla\n\nElf ranger. Feats: Alert.\n' > Characters/Ayla/Ayla.md
printf '# Brom\n\nDwarf fighter. Feats: Alert.\n' > Characters/Brom/Brom.md
printf '# Durga\n\nOrc barbarian, level 5. Feats: Savage Attacker.\n\n## Equipment\n\n- Greataxe\n' > Characters/Durga/Durga.md
printf '# Durga (level 4)\n\nOrc barbarian, level 4. Feats: [[Alert]].\n' > Characters/Durga/Past_Builds/Durga_01.md
mkdir -p Campaigns/Heroes/Homebrew_Magic_Items Campaigns/Villains
printf '# Emberglass Ring\n\nFound by [[Ayla]] during the Heroes campaign. Stores one fire spell.\n' > Campaigns/Heroes/Homebrew_Magic_Items/Emberglass_Ring.md
printf '# Villains\n\nA second campaign, from the villains'"'"' side.\n' > Campaigns/Villains/README.md
printf '# Mira Vell\n\nInnkeeper of the Gull'"'"'s Rest in [[Porto_Ladro]]. Met the party in Session 3; owes [[Ayla]] a favour.\n' > Campaigns/Heroes/NPCs/Mira_Vell.md

# The DM's own world, Orsenna, and a homebrew spell with no world in it.
mkdir -p World/Orsenna/Places World/Orsenna/Pantheon Homebrew/Spells/Level_2
printf '# Porto Ladro\n\nA harbour town of smugglers on the Orsenna coast.\n' > World/Orsenna/Places/Porto_Ladro.md
printf '# Sethra\n\nGoddess of the tides, worshipped along the coast.\n' > World/Orsenna/Pantheon/Sethra.md
printf '# Tidecall\n\n2nd-level evocation. A wave strikes a 20-foot line: 3d8 bludgeoning damage.\n' > Homebrew/Spells/Level_2/Tidecall.md
