-- Locales/frFR.lua
-- French (frFR) translations for EQ Objective Tracker.
--
-- HOW TO USE: type the French translation between the quotes after each "=".
-- The English text is the key inside L["..."]. Example:
--     L["Hide tracker in combat"] = "..."
--
-- KEEP THESE EXACTLY AS THEY APPEAR (do not translate them):
--   |cffaaaaaa ... |r   -> colour codes
--   %d  %s              -> numbers / names get inserted here
--   \n                  -> line break
--   \"                  -> an escaped quote inside the text
--
-- Any phrase absent from this file stays English via the metatable in
-- Locales/enUS.lua, so a partial translation is always safe.
--
-- NOTE: do NOT add an @localization@ packager token here. CurseForge
-- localization is not enabled on this project. That token fails the release
-- build with errorCode 1002. Translations are bundled directly below.
--
-- Maintained by docs/_port_translations.py, which fills in any phrase Everything
-- Quests already translates and words identically. It is ADDITIVE: a line already
-- here wins over EQ's and survives a re-run, so corrections and contributions made
-- in this file are safe to keep.

if GetLocale() ~= "frFR" then return end

local _, ns = ...
local L = ns.L


-- Options/TabGeneral.lua
L["Zone"] = "Zone"
L["Status"] = "Statut"
L["Level"] = "Niveau"
L["Distance"] = "Distance"
L["Recent"] = "Récent"
L["Manual"] = "Manuel"
L["General"] = "Général"
L["Lock tracker"] = "Verrouiller le module de suivi"
L["Keep focused quest after relog"] = "Conserver la quête suivie à la reconnexion"
L["Restores the waypoint arrow."] = "Restaure la flèche directionnelle."
L["Hide tracker in combat"] = "Cacher le module de suivi pendant le combat"
L["Hide tracker in instances"] = "Cacher le module de suivi en instance"
L["Raids, dungeons, delves."] = "Raids, donjons, gouffres."
L["Hide tracker when world map is open"] = "Cacher le module de suivi quand la carte du monde est ouverte"
L["Hide tracker in Mythic+"] = "Cacher le module de suivi en Mythique+"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "Cache le module de suivi pendant une course Mythique+ en cours, puis le réaffiche une fois la course terminée."
L["Auto-track accepted quests"] = "Suivi automatique des quêtes acceptées"
L["Matches Blizzard's default."] = "Par défaut de Blizzard."
L["Show Options icon on the tracker"] = "Afficher l'icône Options sur le module de suivi"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "Un petit engrenage en haut à droite du module de suivi qui ouvre le panneau d'options."
L["Split quest click"] = "Séparer les clics sur les quêtes"
L["Click the icon to focus, click the title to open the quest log."] = "Icône pour suivre, nom pour le journal de quête."
L["Show usable quest item buttons"] = "Affiche les objets de quête utilisables"
L["Show Quest Discovered popups"] = "Affiche les alertes de découverte"
L["Boxes for newly discovered / completed quests."] = "Quêtes récemment découvertes / complétées."
L["Simplify tracked achievements"] = "Simplifier les hauts-faits suivis"
L["Show only incomplete criteria for tracked achievements."] = "Affiche uniquement les critères incomplets des hauts-faits suivis."
L["Show quest level prefix"] = "Montrer le préfixe du niveau de quête"
L["For example, [60] Title."] = "Par exemple, [60] dans le titre."
L["Show quest ID"] = "Affiche l'ID de la quête"
L["Useful for bug reports."] = "Utile pour signaler les bugs."
L["Show NEW tag on recently accepted quests"] = "Affiche NEW sur les quêtes récemment acceptées"
L["For about an hour after accepting."] = "Dure environ une heure."
L["Quest Sound"] = "Son de quête"
L["Plays when a quest is ready to turn in."] = "Joue quand une quête est prête à être rendue."
L["Quest Complete Sound"] = "Son pour Quête Complétée"
L["Zone Progress Bar"] = "Barre de progrès de la zone"
L["Show zone progress bar"] = "Montrer la barre de progrès de la zone"
L["Approximate questline progress."] = "Progrès approximatif dans la zone."
L["Float as a movable bar"] = "Déplaçable"
L["Drag to move; right-click to lock or reset."] = "Glisser-déposer; clic droit pour verrouiller ou réinitialiser."
L["Scenario Bonus Objectives"] = "Objectifs bonus de scénario"
L["Show bonus objectives HUD"] = "Afficher le HUD des objectifs bonus"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "Affiche une petite liste déplaçable des objectifs bonus supplémentaires qui apparaissent dans certains scénarios et gouffres, pour ne pas manquer leurs récompenses. Glisser-déposer pour déplacer, clic droit pour verrouiller ou réinitialiser. Désactivé par défaut."
L["HUD Scale"] = "Échelle du HUD"
L["Sizes the bonus objectives HUD."] = "Dimensionne le HUD des objectifs bonus."
L["Profiles"] = "Profils"
L["Active profile"] = "Activer Profil"
L["New Profile"] = "Nouveau Profil"
L["Profile name:"] = "Nom de Profil"
L["Create"] = "Créer"
L["Cancel"] = "Annuler"
L["Overwrite profile?"] = "Écraser le profil ?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "Un profil nommé « %s » existe déjà. L'écraser avec une copie de vos réglages actuels ?"
L["Overwrite"] = "Écraser"
L["Reset all settings"] = "Réinitialiser les réglages"
L["Reset"] = "Réinitialiser"

-- Options/TabSections.lua
L["Top"] = "Haut"
L["Bottom"] = "Bas"
L["World Quests"] = "Expéditions"
L["Position"] = "Position"

-- Options/TabAppearance.lua
L["None"] = "Aucun"
L["Plain"] = "Simple"
L["Card"] = "Carte"
L["Left"] = "Gauche"
L["Center"] = "Centre"
L["Right"] = "Droite"
L["Same as tracker font"] = "Identique à la police du module de suivi"
L["Appearance"] = "Apparence"
L["Font"] = "Police"
L["Font Size"] = "Taille de police"
L["Outline"] = "Contour"
L["Title Size Offset"] = "Décalage de taille des titres"
L["Text Shadow"] = "Ombre du texte"
L["Shadow Color"] = "Couleur de l'ombre"
L["Scenario"] = "Scénario"
L["Banner Alignment"] = "Alignement de la bannière"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "Positionne la bannière de scénario / gouffre dans le module de suivi. Gauche l'aligne sur le texte des quêtes, Centre la garde centrée (par défaut), et Droite la pousse contre le bord droit du module de suivi."
L["Banner Text Size"] = "Taille du texte de la bannière"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "Agrandit ou réduit le texte Phase et nom de la bannière de scénario / gouffre. 0 est la taille par défaut. L'illustration de la bannière a une taille fixe, donc de grandes valeurs peuvent la déborder."
L["Criteria Text Size"] = "Taille du texte des critères"
L["Tracker Scale"] = "Échelle du module de suivi"
L["Row Layout"] = "Disposition des lignes"
L["Card Padding"] = "Marge intérieure de la carte"
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = "Espace entre le bord d'une carte et le texte qu'elle contient. Des valeurs plus grandes donnent des cartes plus hautes."
L["Header Color"] = "Couleur de l'en-tête"
L["Header Size Offset"] = "Décalage de taille des en-têtes"
L["Header bar"] = "Barre d'en-tête"
L["Bar Color"] = "Couleur de la barre"
L["Bar Style"] = "Style de la barre"
L["Bar Height"] = "Hauteur de la barre"
L["Edge Softness"] = "Douceur des bordures"
L["Hide scroll bar"] = "Cacher la barre de défilement"
L["Scroll Bar Background"] = "Arrière-plan scroll bar"
L["Scroll Bar Color"] = "Couleur scroll bar"
L["Solid color thumb"] = "Curseur de couleur unie"
L["Thumb Color"] = "Couleur du curseur"
L["Thumb Width"] = "Largeur du curseur"
L["Hide scroll bar arrows"] = "Cacher les flèches de la barre de défilement"
L["Background Color"] = "Couleur d'arrière-plan"
L["Border Color"] = "Couleur de bordure"
L["Border Thickness"] = "Épaisseur de bordure"
L["Zone Bar Appearance"] = "Apparence de la barre de progrès de zone"
L["Bar Texture"] = "Texture de la barre"
L["Count Color"] = "Couleur du compteur"

-- Options/TabAbout.lua
L["About"] = "À propos"
L["Version %s"] = "Version %s"
L["by Wheelbarrel00"] = "par Wheelbarrel00"
L["Commands"] = "Commandes"

-- Options/Frame.lua
L["Clear"] = "Nettoyer"

-- Data/Filter.lua
L["World quests"] = "Expéditions"
L["Bonus Objectives"] = "Objectifs bonus"
L["Campaign"] = "Campagne"
L["Daily"] = "Quotidien"
L["Weekly"] = "Hebdomadaire"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "Clic gauche pour ouvrir, clic droit pour ne plus suivre."

-- Data/Providers/Scenarios.lua
L["Dungeon"] = "Donjon"
L["Raid"] = "Raid"

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = "Prête à rendre"

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = "Butin bonus de gouffre"

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = "Cliquez pour voir la quête"
L["Quest Complete!"] = "Quête Complétée!"
L["Quest Discovered!"] = "Quête Découverte!"

-- UI/RewardTooltip.lua
L["Equip \226\128\148 empty slot"] = "Équiper — emplacement vide"
L["Equipped: ilvl %d"] = "Équipé: ilvl %d"
L["+%d ilvl upgrade"] = "Amélioration de +%d ilvl"
L["%d ilvl lower"] = "%d ilvl de moins"
L["Same item level"] = "Même ilvl"
L["ilvl %d"] = "ilvl %d"
L["%d XP"] = "%d XP"
L["Choose one:"] = "Choisissez votre récompense:"

-- UI/Row.lua
L["Find Group"] = "Trouver un groupe"
L["Open the Premade Group Finder for this quest."] = "Ouvrir la recherche de groupe pour cette quête"

-- UI/Scenario.lua
L["Final Stage"] = "Phase finale"
L["Stage %d"] = "Phase %d"

-- UI/ScenarioBonusHUD.lua
L["Unlock (allow moving)"] = "Dévérouiller (autorise le déplacement)"
L["Lock position"] = "Verrouiller position"
L["Reset position"] = "Réinitialiser position"

-- UI/Sections.lua
L["Zone Progress"] = "Progrès de la zone"
L["Quests"] = "Quêtes"
L["Achievements"] = "Hauts-Faits"
L["Endeavors"] = "Initiatives"
L["Profession"] = "Profession"

-- UI/Tracker.lua
L["Tracker locked"] = "Module verrouillé"
L["Open the options panel"] = "Ouvrir le panneau d'options"
