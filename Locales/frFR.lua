-- Locales/frFR.lua
-- French (frFR) translations for EQ Objective Tracker.
--
-- GENERATED FILE. Do not hand-edit: it is rebuilt from the shared translation store
-- at github.com/wheelbarrel00/EverythingLocales, which feeds this addon and Everything
-- Quests together so a phrase both use is only translated once. To add or correct a
-- translation, edit store/frFR.lua there and open a pull request - a change made
-- here is overwritten on the next build.
--
-- KEEP THESE EXACTLY AS THEY APPEAR (do not translate them):
--   |cffaaaaaa ... |r   -> color codes
--   %d  %s              -> numbers / names get inserted here
--   %1$s  %2$d          -> the same, when the order has to change in French
--   \n                  -> line break
--   \"                  -> an escaped quote inside the text
--
-- Any phrase absent from this file stays English via the metatable in
-- Locales/enUS.lua, so a partial translation is always safe.
--
-- NOTE: do NOT add an @localization@ packager token here. CurseForge
-- localization is not enabled on this project. That token fails the release
-- build with errorCode 1002. Translations are bundled directly below.

if GetLocale() ~= "frFR" then return end

local _, ns = ...
local L = ns.L

-- Options/TabGeneral.lua
L["General"] = "Général"
L["Lock tracker"] = "Verrouiller le module de suivi"
L["Disable drag-to-move and resize."] = "Désactive le glisser-déposer et le recadrage."
L["Hide tracker in combat"] = "Cacher le module de suivi pendant le combat"
L["Hide tracker in instances"] = "Cacher le module de suivi en instance"
L["Raids, dungeons, delves."] = "Raids, donjons, gouffres."
L["Hide tracker when world map is open"] = "Cacher le module de suivi quand la carte du monde est ouverte"
L["Hide tracker in Mythic+"] = "Cacher le module de suivi en Mythique+"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "Cache le module de suivi pendant une course Mythique+ en cours, puis le réaffiche une fois la course terminée."
L["Auto-track accepted quests"] = "Suivi automatique des quêtes acceptées"
L["Matches Blizzard's default."] = "Par défaut de Blizzard."
L["Keep focused quest after relog"] = "Conserver la quête suivie à la reconnexion"
L["Restores the waypoint arrow."] = "Restaure la flèche directionnelle."
L["Options Window Scale"] = "Échelle de la fenêtre d'options"
L["Resizes this EQ Objective Tracker options window only. It does not change the quest tracker or anything shown in the game world. The new size applies when you let go of the slider."] = "Redimensionne uniquement cette fenêtre d'options d'EQ Objective Tracker. Cela ne modifie pas le module de suivi des quêtes ni rien de ce qui est affiché dans le monde du jeu. La nouvelle taille s'applique lorsque vous relâchez le curseur."
L["Reset all settings"] = "Réinitialiser les réglages"
L["Reset"] = "Réinitialiser"
L["Cancel"] = "Annuler"
L["Profiles"] = "Profils"
L["Switching profiles reloads the UI. Profiles are shared across characters. Use them to keep different setups such as raid and solo. |cffEBB706New Profile|r prompts for a name and creates it on the spot."] = "Changer de profil recharge l'IU. Les profils sont partagés par tous vos personnages; utilisez-les pour conserver différents modèles (comme raid ou solo). |cffEBB706Nouveau profil|r demande un nom et crée le profil dans la foulée."
L["Active profile"] = "Activer Profil"
L["New Profile"] = "Nouveau Profil"
L["Profile name:"] = "Nom de Profil"
L["Create"] = "Créer"
L["Overwrite profile?"] = "Écraser le profil ?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "Un profil nommé « %s » existe déjà. L'écraser avec une copie de vos réglages actuels ?"
L["Overwrite"] = "Écraser"

-- Options/TabTracker.lua
L["Zone"] = "Zone"
L["Status"] = "Statut"
L["Type"] = "Type"
L["Level"] = "Niveau"
L["Distance"] = "Distance"
L["Recent"] = "Récent"
L["Manual"] = "Manuel"
L["Profession section"] = "Section profession"
L["Achievements section"] = "Section Hauts-faits"
L["World Quests section"] = "Section Expéditions"
L["Top"] = "Haut"
L["Bottom"] = "Bas"
L["Move %s up"] = "Déplacer %s vers le haut"
L["Move %s down"] = "Déplacer %s vers le bas"
L["Reorders where this section sits in the tracker. A section only shows while it has something in it, so empty sections won't visibly move."] = "Change la position de cette section dans le module de suivi. Une section ne s'affiche que lorsqu'elle contient quelque chose, donc les sections vides ne bougeront pas visiblement."
L["Tracker"] = "Module"
L["On-Screen Tracker"] = "Module de suivi"
L["Changes apply immediately to the on-screen tracker."] = "Les changements s'appliquent immédiatement sur le module de suivi"
L["Show only tracked quests"] = "Montrer uniquement les quêtes visibles"
L["Simplify Mode"] = "Mode simplifié"
L["Show only the first incomplete objective per quest."] = "Affiche le prochain objectif incomplet de la quête."
L["Simplify tracked achievements"] = "Simplifier les hauts-faits suivis"
L["Show only incomplete criteria for tracked achievements."] = "Affiche uniquement les critères incomplets des hauts-faits suivis."
L["Sort Order"] = "Ordre de tri"
L["Drag and drop the quests in the tracker to reorder them however you like."] = "Glisser-déposer les quêtes dans le module de suivi pour les réorganiser comme vous le souhaitez."
L["Filters"] = "Filtres"
L["Show only quests in current zone"] = "Montrer uniquement les quêtes dans la zone actuelle"
L["Reset filters to defaults"] = "Réinitialiser les filtres"
L["Tracker Visibility"] = "Visibilité du module de suivi"
L["Auto-list current-zone world quests"] = "Lister automatiquement les expéditions de la zone actuelle"
L["Lists every WQ in your zone without tracking each."] = "Liste les expéditions de la zone sans les suivre."
L["Set a custom World Quests height"] = "Définir une hauteur personnalisée pour les Expéditions"
L["World Quests Height"] = "Hauteur des Expéditions"
L["Section Order"] = "Ordre des sections"
L["Rearrange the tracker's sections with the arrows below. A section only appears on the tracker while it has something in it, so reordering an empty section won't look like anything changed. World Quests scroll in their own panel and can only sit at the very top or bottom, so use the Top/Bottom control."] = "Réorganisez les sections du module de suivi avec les flèches ci-dessous. Une section n'apparaît sur le module que lorsqu'elle contient quelque chose, donc réordonner une section vide ne semblera rien changer. Les Expéditions défilent dans leur propre panneau et ne peuvent être placées qu'en haut ou en bas. Utilisez le réglage Haut/Bas."
L["World Quests Position"] = "Position des Expéditions"
L["Where the World Quests panel sits on the tracker. |cffffffffTop|r puts it above your quests. |cffffffffBottom|r keeps it below your quests, which is the default. World Quests scroll in their own capped panel, which is why they can't be mixed in between the other sections."] = "Où se place le panneau des Expéditions sur le module de suivi. |cffffffffHaut|r le place au-dessus de vos quêtes; |cffffffffBas|r le garde en dessous de vos quêtes (par défaut). Les Expéditions défilent dans leur propre panneau à hauteur limitée, c'est pourquoi elles ne peuvent pas être intercalées entre les autres sections."
L["Options"] = "Options"
L["Quest Title Color By Difficulty"] = "Coloriser les noms de quête en fonction de la difficulté"
L["Show quest level prefix"] = "Montrer le préfixe du niveau de quête"
L["For example, [60] Title."] = "Par exemple, [60] dans le titre."
L["Show zone label under quest titles"] = "Montrer le nom de la zone sous le nom de la quête"
L["Show objective progress numbers"] = "Affichage numérique du progrès des quêtes"
L["For example, 0/4, 1/1, etc."] = "Par exemple, 0/4, 1/1, etc."
L["Show quest ID"] = "Affiche l'ID de la quête"
L["Useful for bug reports."] = "Utile pour signaler les bugs."
L["Show usable quest item buttons"] = "Affiche les objets de quête utilisables"
L["Show Options icon on the tracker"] = "Afficher l'icône Options sur le module de suivi"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "Un petit engrenage en haut à droite du module de suivi qui ouvre le panneau d'options."
L["Show Quest Discovered popups"] = "Affiche les alertes de découverte"
L["Boxes for newly discovered / completed quests."] = "Quêtes récemment découvertes / complétées."
L["Show NEW tag on recently accepted quests"] = "Affiche NEW sur les quêtes récemment acceptées"
L["For about an hour after accepting."] = "Dure environ une heure."
L["Split quest click"] = "Séparer les clics sur les quêtes"
L["Click the icon to focus, click the title to open the quest log."] = "Icône pour suivre, nom pour le journal de quête."
L["Quest Sound"] = "Son de quête"
L["Plays when a quest is ready to turn in."] = "Joue quand une quête est prête à être rendue."
L["Quest Complete Sound"] = "Son pour Quête Complétée"
L["Scenario Bonus Objectives"] = "Objectifs bonus de scénario"
L["Show bonus objectives HUD"] = "Afficher le HUD des objectifs bonus"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "Affiche une petite liste déplaçable des objectifs bonus supplémentaires qui apparaissent dans certains scénarios et gouffres, pour ne pas manquer leurs récompenses. Glisser-déposer pour déplacer, clic droit pour verrouiller ou réinitialiser. Désactivé par défaut."
L["HUD Scale"] = "Échelle du HUD"
L["Sizes the bonus objectives HUD."] = "Dimensionne le HUD des objectifs bonus."

-- Options/TabAppearance.lua
L["None"] = "Aucun"
L["Outline"] = "Contour"
L["Thick"] = "Épais"
L["Mono"] = "Mono"
L["Mono Outline"] = "Mono contour"
L["Mono Thick"] = "Mono épais"
L["Plain"] = "Simple"
L["Card"] = "Carte"
L["Header Bar 1"] = "Barre d'en-tête 1"
L["Header Bar 2"] = "Barre d'en-tête 2"
L["Left"] = "Gauche"
L["Center"] = "Centre"
L["Right"] = "Droite"
L["Same as tracker font"] = "Identique à la police du module de suivi"
L["Appearance"] = "Apparence"
L["Font"] = "Police"
L["Font Size"] = "Taille de police"
L["Title Size Offset"] = "Décalage de taille des titres"
L["Sizes quest and achievement titles separately from the objective text. This value is added to the Font Size above: 0 keeps titles the same size as the base font, positive makes them larger, negative smaller."] = "Dimensionne les titres de quêtes et de hauts-faits séparément du texte des objectifs. Cette valeur s'ajoute à la Taille de police ci-dessus: 0 garde les titres à la même taille que la police de base, une valeur positive les agrandit, une valeur négative les réduit."
L["Header Size Offset"] = "Décalage de taille des en-têtes"
L["Sizes the section headers (Quests, Campaign, and so on) independently of the quest text. Added on top of the Font Size above: the default 4 keeps headers at their current size, lower shrinks them (handy on a low UI scale), higher enlarges them."] = "Dimensionne les en-têtes de section (Quêtes, Campagne, etc.) indépendamment du texte des quêtes. S'ajoute à la Taille de police ci-dessus: la valeur par défaut 4 garde les en-têtes à leur taille actuelle, une valeur plus basse les réduit (pratique sur une échelle d'interface réduite), une plus élevée les agrandit."
L["Font Outline"] = "Contour de police"
L["Text Shadow"] = "Ombre du texte"
L["Draws a soft drop-shadow behind all tracker text so it stays readable over bright or busy backgrounds. Use Shadow Color to tint it and Shadow Size to set how far it's cast."] = "Dessine une légère ombre portée derrière tout le texte du module de suivi pour qu'il reste lisible sur des arrière-plans clairs ou chargés. Utilisez Couleur de l'ombre pour la teinter et Taille de l'ombre pour régler sa portée."
L["Shadow Color"] = "Couleur de l'ombre"
L["Shadow Size"] = "Taille de l'ombre"
L["How far the text drop-shadow is cast behind the letters. Higher values give a larger, more pronounced shadow. Lower values keep it tight. Only applies while Text Shadow is on."] = "Jusqu'où l'ombre portée du texte s'étend derrière les lettres. Des valeurs plus élevées donnent une ombre plus grande et plus prononcée; des valeurs plus basses la gardent serrée. Ne s'applique que lorsque Ombre du texte est activé."
L["Scenario"] = "Scénario"
L["Draws a drop-shadow behind the scenario / delve banner text (the Stage and name lines). This is SEPARATE from the Text Shadow above, which affects only the quest and objective text. The banner is styled on its own."] = "Dessine une ombre portée derrière le texte de la bannière de scénario / gouffre (les lignes Phase et nom). Ceci est SÉPARÉ de l'Ombre du texte ci-dessus, qui n'affecte que le texte des quêtes et des objectifs — la bannière a son propre style."
L["How far the scenario banner's drop-shadow is cast. Higher values give a larger, more pronounced shadow. Lower values keep it tight. Only applies while the Scenario Text Shadow above is on."] = "Jusqu'où l'ombre portée de la bannière de scénario s'étend. Des valeurs plus élevées donnent une ombre plus grande et plus prononcée; des valeurs plus basses la gardent serrée. Ne s'applique que lorsque l'Ombre du texte du scénario ci-dessus est activée."
L["Banner Alignment"] = "Alignement de la bannière"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "Positionne la bannière de scénario / gouffre dans le module de suivi. Gauche l'aligne sur le texte des quêtes, Centre la garde centrée (par défaut), et Droite la pousse contre le bord droit du module de suivi."
L["Banner Text Size"] = "Taille du texte de la bannière"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "Agrandit ou réduit le texte Phase et nom de la bannière de scénario / gouffre. 0 est la taille par défaut. L'illustration de la bannière a une taille fixe, donc de grandes valeurs peuvent la déborder."
L["Criteria Text Size"] = "Taille du texte des critères"
L["Sizes the scenario / delve objective (criteria) lines shown under the banner, separately from the Banner Text Size above. Raise it if the criteria text looks small next to your quest and World Quest text."] = "Ajuste la taille des lignes d'objectifs (critères) du scénario / gouffre affichées sous la bannière, indépendamment de la Taille du texte de la bannière ci-dessus. Augmentez-la si le texte des critères paraît petit à côté du texte de vos quêtes et Expéditions."
L["Hide scroll bar"] = "Cacher la barre de défilement"
L["Scroll Bar Background"] = "Arrière-plan scroll bar"
L["Scroll Bar Color"] = "Couleur scroll bar"
L["Solid color thumb"] = "Curseur de couleur unie"
L["Replaces the tracker scroll bar's textured thumb (the draggable block) with a flat single-color block. Use the Thumb Color and Thumb Width controls to style it. Off restores the stock Blizzard bar."] = "Remplace le curseur texturé de la barre de défilement du module de suivi (le bloc déplaçable) par un bloc d'une seule couleur unie. Utilisez les contrôles Couleur du curseur et Largeur du curseur pour le personnaliser. Désactivé restaure la barre Blizzard d'origine."
L["Thumb Color"] = "Couleur du curseur"
L["Thumb Width"] = "Largeur du curseur"
L["Hide scroll bar arrows"] = "Cacher les flèches de la barre de défilement"
L["Hides the up and down arrow buttons at the ends of the tracker scroll bar. The bar still scrolls by dragging the thumb or using the mouse wheel."] = "Cache les boutons fléchés haut et bas aux extrémités de la barre de défilement du module de suivi. Le défilement par la molette ou en glissant le curseur reste activé."
L["Background"] = "Arrière-plan"
L["Background Color"] = "Couleur d'arrière-plan"
L["Border"] = "Bordure"
L["Border Color"] = "Couleur de bordure"
L["Border Thickness"] = "Épaisseur de bordure"
L["Header Bar"] = "Barre d'en-tête"
L["Draws a colored gradient bar behind each section header (Quests, Campaign, World Quests, and so on), for a look closer to the default Blizzard tracker. Off by default."] = "Dessine une barre dégradée colorée derrière chaque en-tête de section (Quêtes, Campagne, Expéditions, etc.), pour un rendu plus proche du module de suivi Blizzard par défaut. Désactivé par défaut."
L["Bar Color"] = "Couleur de la barre"
L["Bar Style"] = "Style de la barre"
L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."] = "Barre d'en-tête 1 est un dégradé horizontal (clair à gauche, foncé à droite). Barre d'en-tête 2 est un dégradé vertical (clair en haut, foncé en bas). Couleur de la barre, Hauteur de la barre et Bordures douces s'appliquent toutes au style que vous choisissez."
L["Soft edges"] = "Bordures douces"
L["Feathers the top, left, and right edges of the header bar so it blends into the UI instead of sitting in a hard box. The gradient color is unchanged. Only applies while Header bars is on. Off by default."] = "Adoucit les bordures supérieure, gauche et droite de la barre d'en-tête pour qu'elle se fonde dans l'interface au lieu de rester dans un cadre net. La couleur du dégradé est inchangée. Ne s'applique que lorsque Barre d'en-tête est activée; désactivé par défaut."
L["Bar Height"] = "Hauteur de la barre"
L["How tall the section-header bar is. The bar is centered on the header row, so larger values fill more of it."] = "Hauteur de la barre d'en-tête de section. La barre est centrée sur la ligne de l'en-tête, donc des valeurs plus grandes en remplissent davantage."
L["Edge Softness"] = "Douceur des bordures"
L["How soft the header bar's feathered edges are when Soft edges is on. Higher is softer, lower tightens toward a hard edge."] = "Détermine la douceur des bordures adoucies de la barre d'en-tête lorsque Bordures douces sont activées. Plus la valeur est élevée, plus c'est doux; plus elle est basse, plus la bordure devient nette."
L["Colors & Dimensions"] = "Couleurs & dimensions"
L["Reset to Defaults"] = "Réinitialiser par défaut"
L["Quest Title Color Override"] = "Couleur titres de quêtes"
L["When cleared, falls back to difficulty coloring or default yellow."] = "Quand nettoyé, retourne à la couleur de difficulté ou à la couleur par défaut"
L["Colors quest, achievement, and endeavor titles with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "Colore les titres de quêtes, de hauts-faits et d'initiatives avec la couleur de classe du personnage actuellement connecté. Remplace la couleur ci-dessus lorsqu'activé. Désactivé par défaut."
L["Use title color for completed quests"] = "Utiliser la couleur des titres pour les quêtes complétées"
L["Instead of green."] = "Au lieu du vert."
L["Section Header Color"] = "Couleur nom de section"
L["Colors the section headers (Quests, Campaign, and so on) with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "Colore les en-têtes de section (Quêtes, Campagne, etc.) avec la couleur de classe du personnage actuellement connecté. Remplace la couleur ci-dessus lorsqu'activé. Désactivé par défaut."
L["Divider Line Color"] = "Couleur de la ligne de séparation"
L["Sets the color of the thin line under each section header. Defaults to the original gold."] = "Définit la couleur de la fine ligne sous chaque en-tête de section. Par défaut, l'or d'origine."
L["Tracker Scale"] = "Échelle du module de suivi"
L["Block Spacing"] = "Espacement des blocs"
L["Line Spacing"] = "Espacement des lignes"
L["Adds vertical space between a quest's objective lines, across the whole tracker. 0 keeps the default spacing."] = "Ajoute de l'espace vertical entre les lignes d'objectif d'une quête, dans tout le module de suivi. 0 conserve l'espacement par défaut."
L["Header Spacing"] = "Espacement des en-têtes"
L["Adds or removes space around section headers and beneath each quest's title. 0 keeps the default spacing."] = "Ajoute ou retire de l'espace autour des en-têtes de section et sous le titre de chaque quête. 0 conserve l'espacement par défaut."
L["Quest Rows"] = "Lignes de quête"
L["Row Layout"] = "Disposition des lignes"
L["How each quest is drawn in the tracker. |cffffffffPlain|r is the default look - text straight on the tracker background. |cffffffffCard|r gives every quest its own panel with a background and border, which makes long lists easier to read apart."] = "Détermine comment chaque quête est dessinée dans le module de suivi. |cffffffffSimple|r est le rendu par défaut: le texte directement sur l'arrière-plan du module de suivi. |cffffffffCarte|r donne à chaque quête son propre panneau avec un arrière-plan et une bordure, ce qui rend les longues listes plus faciles à distinguer."
L["Fill color behind each quest card. Only used while Row Layout is set to Card."] = "Couleur de remplissage derrière chaque carte de quête. Utilisée uniquement lorsque Disposition des lignes est réglée sur Carte."
L["Outline color around each quest card. Only used while Row Layout is set to Card."] = "Couleur du contour autour de chaque carte de quête. Utilisée uniquement lorsque Disposition des lignes est réglée sur Carte."
L["How thick the card outline is, in pixels. 0 hides the outline and leaves just the fill."] = "Épaisseur du contour de la carte, en pixels. 0 masque le contour et ne laisse que le remplissage."
L["Card Padding"] = "Marge intérieure de la carte"
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = "Espace entre le bord d'une carte et le texte qu'elle contient. Des valeurs plus grandes donnent des cartes plus hautes."
L["Tint cards by quest type"] = "Teinter les cartes selon le type de quête"
L["Campaign"] = "Campagne"
L["Legendary"] = "Légendaire"
L["Dungeon"] = "Donjon"
L["Raid"] = "Raid"
L["Zone Progress Bar"] = "Barre de progrès de la zone"
L["Show zone progress bar"] = "Montrer la barre de progrès de la zone"
L["Approximate questline progress."] = "Progrès approximatif dans la zone."
L["Float as a movable bar"] = "Déplaçable"
L["Zone Bar Scale"] = "Échelle de la barre de progrès de zone"
L["Bar Texture"] = "Texture de la barre"
L["Sets the fill texture of the zone progress bar. Textures added by other media addons (such as SharedMedia, ElvUI, or Details) appear here too."] = "Définit la texture de remplissage de la barre de progrès de la zone. Les textures ajoutées par d'autres addons multimédia (comme SharedMedia, ElvUI ou Details) apparaissent également ici."
L["Header Color"] = "Couleur de l'en-tête"
L["Count Color"] = "Couleur du compteur"

-- Options/TabAbout.lua
L["About"] = "À propos"
L["Version %s"] = "Version %s"
L["by Wheelbarrel00"] = "par Wheelbarrel00"
L["Join our Discord"] = "Nous rejoindre sur Discord"
L["CurseForge"] = "CurseForge"
L["GitHub"] = "GitHub"
L["Report a Bug"] = "Signaler un bug"
L["Commands"] = "Commandes"
L["Thanks"] = "Remerciements"
L["Changelog"] = "Journal des modifications"
L["Older versions are on CurseForge"] = "Les anciennes versions sont sur CurseForge"

-- Options/Frame.lua
L["Clear"] = "Nettoyer"
L["Join our Discord!"] = "Rejoignez-nous sur Discord!"

-- Core/Init.lua
L["Copy the link below (it's pre-selected \226\128\148 just press Ctrl+C):"] = "Copiez le lien ci-dessous (pré-sélectionné - faites juste Ctrl+C):"
L["Close"] = "Fermer"
L["Join the community for help, feedback, and updates.\nCopy the invite below (it's pre-selected \226\128\148 just press Ctrl+C):"] = "Rejoignez la communauté pour de l'aide, des suggestions, et des mises à jour.\nCopiez l'invitation ci-dessous (pré-sélectionnée - faites juste Ctrl+C):"

-- Data/Filter.lua
L["World Quests"] = "Expéditions"
L["Bonus Objectives"] = "Objectifs bonus"
L["Campaign quests"] = "Quête de Campagne"
L["Daily quests"] = "Quête journalière"
L["Weekly quests"] = "Quête hebdomadaire"
L["Normal quests"] = "Quête normale"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "Clic gauche pour ouvrir, clic droit pour ne plus suivre."

-- Data/Providers/Professions.lua
L["Left-click to open the recipe, right-click to untrack."] = "Clic gauche pour ouvrir, clic droit pour ne plus suivre."

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = "Prête à rendre"

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = "Butin bonus de gouffre"

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = "Cliquez pour voir la quête"
L["Quest Complete!"] = "Quête Complétée!"
L["Quest Discovered!"] = "Quête Découverte!"

-- UI/Commands.lua
L["tracker locked."] = "Module verrouillé"

-- UI/RewardTooltip.lua
L["Equip \226\128\148 empty slot"] = "Équiper — emplacement vide"
L["Equipped: ilvl %d"] = "Équipé: ilvl %d"
L["+%d ilvl upgrade"] = "Amélioration de +%d ilvl"
L["%d ilvl lower"] = "%d ilvl de moins"
L["Same item level"] = "Même ilvl"
L["ilvl %d"] = "ilvl %d"
L["%d XP"] = "%d XP"
L["Choose one:"] = "Choisissez votre récompense:"
L["Time Left: "] = "Temps restant : "

-- UI/Row.lua
L["Find Group"] = "Trouver un groupe"
L["Open the Premade Group Finder for this quest."] = "Ouvrir la recherche de groupe pour cette quête"

-- UI/RowMenu.lua
L["Pin to tracker"] = "Épingler au module de suivi"
L["Unpin from tracker"] = "Désépingler du module de suivi"
L["Track Quest"] = "Suivre la quête"
L["Untrack Quest"] = "Ne plus suivre la quête"
L["Focus"] = "Super-suivi"
L["Unfocus"] = "Arrêter le super-suivi"
L["Super-track (follow arrow)"] = "Super-suivi (flèche directionnelle)"
L["Open in Map & Quest Log"] = "Ouvrir dans la carte et le journal de quête"
L["Pop Out Quest Details"] = "Détacher les détails de la quête"
L["Search on Wowhead"] = "Rechercher sur Wowhead"
L["Abandon Quest"] = "Abandonner la quête"

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
L["/eqot for options"] = "/eqot pour les options"
L["Open the options panel"] = "Ouvrir le panneau d'options"
