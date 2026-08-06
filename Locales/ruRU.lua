-- Locales/ruRU.lua
-- Russian (ruRU) translations for EQ Objective Tracker.
--
-- HOW TO USE: type the Russian translation between the quotes after each "=".
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

if GetLocale() ~= "ruRU" then return end

local _, ns = ...
local L = ns.L


-- Options/TabGeneral.lua
L["General"] = "Основные"
L["Lock tracker"] = "Заблокировать трекер"
L["Disable drag-to-move and resize."] = "Отключить перетаскивание и изменение размера."
L["Hide tracker in combat"] = "Скрывать трекер в бою"
L["Hide tracker in instances"] = "Скрывать трекер в подземельях"
L["Raids, dungeons, delves."] = "Рейды, обычные подземелья, приключения."
L["Hide tracker when world map is open"] = "Скрывать трекер при открытой карте мира"
L["Hide tracker in Mythic+"] = "Скрывать трекер в Мифик+"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "Скрывает трекер во время активного забега Мифик+ и возвращает его после завершения."
L["Auto-track accepted quests"] = "Авто-отслеживание принятых заданий"
L["Matches Blizzard's default."] = "Соответствует стандарту Blizzard."
L["Keep focused quest after relog"] = "Сохранять выбранное задание после перезахода"
L["Restores the waypoint arrow."] = "Восстанавливает стрелку пути."
L["Options Window Scale"] = "Масштаб окна настроек"
L["Reset all settings"] = "Сбросить все настройки"
L["Reset"] = "Сброс"
L["Cancel"] = "Отмена"
L["Profiles"] = "Профили"
L["Active profile"] = "Активный профиль"
L["New Profile"] = "Новый профиль"
L["Profile name:"] = "Имя профиля:"
L["Create"] = "Создать"
L["Overwrite profile?"] = "Перезаписать профиль?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "Профиль с именем «%s» уже существует. Перезаписать его копией ваших текущих настроек?"
L["Overwrite"] = "Перезаписать"

-- Options/TabTracker.lua
L["Zone"] = "Зона"
L["Status"] = "Статус"
L["Type"] = "Тип"
L["Level"] = "Уровень"
L["Distance"] = "Расстояние"
L["Recent"] = "Недавние"
L["Manual"] = "Вручную"
L["Profession section"] = "Профессии"
L["Achievements section"] = "Достижения"
L["World Quests section"] = "Локальные задания"
L["Top"] = "Вверху"
L["Bottom"] = "Внизу"
L["Move %s up"] = "Переместить %s вверх"
L["Move %s down"] = "Переместить %s вниз"
L["Reorders where this section sits in the tracker. A section only shows while it has something in it, so empty sections won't visibly move."] = "Меняет положение этого раздела в трекере. Раздел отображается только когда в нём что-то есть, поэтому пустые разделы не будут заметно перемещаться."
L["Tracker"] = "Трекер"
L["On-Screen Tracker"] = "Экранный трекер"
L["Changes apply immediately to the on-screen tracker."] = "Изменения применяются к экранному трекеру немедленно."
L["Simplify Mode"] = "Упрощённый режим"
L["Show only the first incomplete objective per quest."] = "Показывать только первое невыполненное условие задания."
L["Simplify tracked achievements"] = "Упрощать отслеживаемые достижения"
L["Show only incomplete criteria for tracked achievements."] = "Показывать только невыполненные критерии для отслеживаемых достижений."
L["Sort Order"] = "Порядок сортировки"
L["Filters"] = "Фильтры"
L["Show only quests in current zone"] = "Показывать только задания в текущей зоне"
L["Reset filters to defaults"] = "Сбросить фильтры"
L["Tracker Visibility"] = "Категории"
L["Auto-list current-zone world quests"] = "Авто-список локальных заданий текущей зоны"
L["Lists every WQ in your zone without tracking each."] = "Показывает все локальные задания в зоне без отслеживания каждого."
L["Set a custom World Quests height"] = "Задать свою высоту для локальных заданий"
L["By default the World Quests area shares space with your quest list and gets squeezed when you have a lot of quests. Turn this on to give it its own height, set by the slider below."] = "По умолчанию область локальных заданий делит место со списком заданий и сжимается, когда заданий много. Включите, чтобы задать ей собственную высоту с помощью ползунка ниже."
L["Section Order"] = "Порядок разделов"
L["Options"] = "Опции"
L["Quest Title Color By Difficulty"] = "Цвет названия задания по сложности"
L["Show quest level prefix"] = "Показывать уровень задания в префиксе"
L["For example, [60] Title."] = "Пример: [60] Название."
L["Show zone label under quest titles"] = "Показывать название зоны под названием задания"
L["Show objective progress numbers"] = "Показывать цифры прогресса целей"
L["For example, 0/4, 1/1, etc."] = "Пример: 0/4, 1/1 и т.д."
L["Show quest ID"] = "Показывать ID задания"
L["Useful for bug reports."] = "Полезно для отчётов об ошибках."
L["Show usable quest item buttons"] = "Показывать кнопки используемых предметов заданий"
L["Show Options icon on the tracker"] = "Показывать значок настроек на трекере"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "Небольшая шестерёнка в правом верхнем углу трекера, открывающая панель настроек."
L["Show Quest Discovered popups"] = "Показывать всплывающие окна «Задание обнаружено»"
L["Boxes for newly discovered / completed quests."] = "Окошки для новых / выполненных заданий."
L["Show NEW tag on recently accepted quests"] = "Показывать метку «NEW» у недавно принятых заданий"
L["For about an hour after accepting."] = "Около часа после принятия."
L["Split quest click"] = "Раздельный клик по заданию"
L["Click the icon to focus, click the title to open the quest log."] = "Нажмите на иконку, чтобы выбрать, на название - открыть журнал заданий."
L["Quest Sound"] = "Звук задания"
L["Plays when a quest is ready to turn in."] = "Проигрывается, когда задание готово к сдаче."
L["Quest Complete Sound"] = "Звук выполнения задания"
L["Scenario Bonus Objectives"] = "Бонусные цели сценария"
L["Show bonus objectives HUD"] = "Показывать HUD бонусных целей"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "Показывает небольшой перемещаемый список дополнительных бонусных целей, которые появляются в некоторых сценариях и вылазках, чтобы вы не пропустили их награды. Перетащите, чтобы переместить, ПКМ - чтобы заблокировать или сбросить. По умолчанию выкл."
L["HUD Scale"] = "Масштаб HUD"
L["Sizes the bonus objectives HUD."] = "Изменяет размер HUD бонусных целей."

-- Options/TabAppearance.lua
L["None"] = "Нет"
L["Outline"] = "Контур"
L["Thick"] = "Толстый"
L["Mono"] = "Моноширинный"
L["Mono Outline"] = "Моно + контур"
L["Mono Thick"] = "Моно + толстый"
L["Plain"] = "Обычный"
L["Card"] = "Карточка"
L["Header Bar 1"] = "Полоса заголовка 1"
L["Header Bar 2"] = "Полоса заголовка 2"
L["Left"] = "Слева"
L["Center"] = "По центру"
L["Right"] = "Справа"
L["Same as tracker font"] = "Как шрифт трекера"
L["Appearance"] = "Внешний вид"
L["Font"] = "Шрифт"
L["Font Size"] = "Размер шрифта"
L["Title Size Offset"] = "Размер заголовка"
L["Sizes quest and achievement titles separately from the objective text. This value is added to the Font Size above: 0 keeps titles the same size as the base font, positive makes them larger, negative smaller."] = "Изменяет размер заголовков заданий и достижений отдельно от текста целей. Это значение прибавляется к размеру шрифта выше: 0 оставляет заголовки того же размера, что и базовый шрифт, положительные значения увеличивают их, отрицательные - уменьшают."
L["Header Size Offset"] = "Размер заголовков"
L["Sizes the section headers (Quests, Campaign, and so on) independently of the quest text. Added on top of the Font Size above: the default 4 keeps headers at their current size, lower shrinks them (handy on a low UI scale), higher enlarges them."] = "Изменяет размер заголовков разделов (Задания, Кампания и т.д.) независимо от текста заданий. Прибавляется к размеру шрифта выше: значение по умолчанию 4 оставляет заголовки текущего размера, меньше - уменьшает их (удобно при мелком масштабе интерфейса), больше - увеличивает."
L["Font Outline"] = "Контур шрифта"
L["Text Shadow"] = "Тень текста"
L["Draws a soft drop-shadow behind all tracker text so it stays readable over bright or busy backgrounds. Use Shadow Color to tint it and Shadow Size to set how far it's cast."] = "Отрисовывает мягкую тень позади всего текста трекера, чтобы он оставался читаемым на ярких или насыщенных фонах. Используйте «Цвет тени» для оттенка и «Размер тени» для настройки её отступа."
L["Shadow Color"] = "Цвет тени"
L["Shadow Size"] = "Размер тени"
L["Scenario"] = "Сценарий"
L["Banner Alignment"] = "Выравнивание баннера"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "Располагает баннер сценария / вылазки в трекере. Слева выравнивает его с текстом задания, По центру оставляет по центру (по умолчанию), а Справа прижимает к правому краю трекера."
L["Banner Text Size"] = "Размер текста баннера"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "Увеличивает или уменьшает текст этапа и названия на баннере сценария / вылазки. 0 - размер по умолчанию. Изображение баннера имеет фиксированный размер, поэтому большие значения могут выйти за его пределы."
L["Criteria Text Size"] = "Размер текста критериев"
L["Sizes the scenario / delve objective (criteria) lines shown under the banner, separately from the Banner Text Size above. Raise it if the criteria text looks small next to your quest and World Quest text."] = "Задаёт размер строк целей (критериев) сценария / вылазки, отображаемых под баннером, отдельно от «Размера текста баннера» выше. Увеличьте, если текст критериев выглядит мелким рядом с текстом ваших заданий и локальных заданий."
L["Hide scroll bar"] = "Скрыть полосу прокрутки"
L["Scroll Bar Background"] = "Фон полосы прокрутки"
L["Scroll Bar Color"] = "Цвет полосы прокрутки"
L["Solid color thumb"] = "Одноцветный бегунок"
L["Thumb Color"] = "Цвет бегунка"
L["Thumb Width"] = "Ширина бегунка"
L["Hide scroll bar arrows"] = "Скрыть стрелки полосы прокрутки"
L["Hides the up and down arrow buttons at the ends of the tracker scroll bar. The bar still scrolls by dragging the thumb or using the mouse wheel."] = "Скрывает кнопки-стрелки вверх и вниз на концах полосы прокрутки трекера. Полоса всё ещё прокручивается перетаскиванием бегунка или колёсиком мыши."
L["Background"] = "Фон"
L["Background Color"] = "Цвет фона"
L["Border"] = "Граница"
L["Border Color"] = "Цвет границы"
L["Border Thickness"] = "Толщина границы"
L["Header Bar"] = "Полоса заголовка"
L["Bar Color"] = "Цвет полосы"
L["Bar Style"] = "Стиль полосы"
L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."] = "«Полоса заголовка 1» - это горизонтальный градиент (яркий слева, тёмный справа). «Полоса заголовка 2» - это вертикальный градиент (яркий сверху, тёмный снизу). «Цвет полосы», «Высота полосы» и «Мягкие края» применяются к выбранному стилю."
L["Soft edges"] = "Мягкие края"
L["Bar Height"] = "Высота полосы"
L["Edge Softness"] = "Мягкость краёв"
L["Colors & Dimensions"] = "Цвета и размеры"
L["Reset to Defaults"] = "Сбросить к стандартным"
L["Quest Title Color Override"] = "Цвет заданий"
L["When cleared, falls back to difficulty coloring or default yellow."] = "Если не задано, используется цвет по сложности или стандартный жёлтый."
L["Colors quest, achievement, and endeavor titles with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "Окрашивает названия заданий, достижений и устремлений в цвет класса персонажа, за которого вы сейчас играете. Пока включено, заменяет цвет выше. По умолчанию выкл."
L["Use title color for completed quests"] = "Использовать цвет названия для выполненных заданий"
L["Instead of green."] = "Вместо зелёного."
L["Section Header Color"] = "Цвет категорий"
L["Colors the section headers (Quests, Campaign, and so on) with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "Окрашивает заголовки разделов (Задания, Кампания и т.д.) в цвет класса персонажа, за которого вы сейчас играете. Пока включено, заменяет цвет выше. По умолчанию выкл."
L["Divider Line Color"] = "Цвет разделительной линии"
L["Sets the color of the thin line under each section header. Defaults to the original gold."] = "Задаёт цвет тонкой линии под каждым заголовком раздела. По умолчанию - исходный золотой."
L["Tracker Scale"] = "Масштаб трекера"
L["Block Spacing"] = "Расстояние между категориями"
L["Line Spacing"] = "Интервал между строками"
L["Adds vertical space between a quest's objective lines, across the whole tracker. 0 keeps the default spacing."] = "Добавляет вертикальное расстояние между строками целей задания во всём трекере. 0 оставляет интервал по умолчанию."
L["Header Spacing"] = "Интервал заголовков"
L["Adds or removes space around section headers and beneath each quest's title. 0 keeps the default spacing."] = "Добавляет или убирает расстояние вокруг заголовков разделов и под названием каждого задания. 0 оставляет интервал по умолчанию."
L["Quest Rows"] = "Строки заданий"
L["Row Layout"] = "Вид строк"
L["How each quest is drawn in the tracker. |cffffffffPlain|r is the default look - text straight on the tracker background. |cffffffffCard|r gives every quest its own panel with a background and border, which makes long lists easier to read apart."] = "Определяет, как каждое задание отображается в трекере. |cffffffffОбычный|r - вид по умолчанию: текст прямо на фоне трекера. |cffffffffКарточка|r даёт каждому заданию собственную панель с фоном и границей, благодаря чему длинные списки легче различать."
L["Fill color behind each quest card. Only used while Row Layout is set to Card."] = "Цвет заливки под каждой карточкой задания. Используется, только когда «Вид строк» установлен на «Карточка»."
L["Outline color around each quest card. Only used while Row Layout is set to Card."] = "Цвет контура вокруг каждой карточки задания. Используется, только когда «Вид строк» установлен на «Карточка»."
L["How thick the card outline is, in pixels. 0 hides the outline and leaves just the fill."] = "Толщина контура карточки в пикселях. 0 скрывает контур и оставляет только заливку."
L["Card Padding"] = "Отступы карточки"
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = "Расстояние между краем карточки и текстом внутри неё. Большие значения делают карточки выше."
L["Tint cards by quest type"] = "Окрашивать карточки по типу задания"
L["Campaign"] = "Кампания"
L["Legendary"] = "Легендарное"
L["Dungeon"] = "Подземелье"
L["Raid"] = "Рейд"
L["Zone Progress Bar"] = "Полоса прогресса зоны"
L["Show zone progress bar"] = "Показывать полосу прогресса зоны"
L["Approximate questline progress."] = "Примерный прогресс по цепочкам заданий."
L["Float as a movable bar"] = "Перенос панели"
L["Zone Bar Scale"] = "Масштаб полосы зоны"
L["Bar Texture"] = "Текстура полосы"
L["Sets the fill texture of the zone progress bar. Textures added by other media addons (such as SharedMedia, ElvUI, or Details) appear here too."] = "Задаёт текстуру заливки полосы прогресса зоны. Текстуры, добавленные другими медиа-аддонами (такими как SharedMedia, ElvUI или Details), также отображаются здесь."
L["Header Color"] = "Цвет заголовка"
L["Count Color"] = "Цвет счётчика"

-- Options/TabAbout.lua
L["About"] = "Об аддоне"
L["Version %s"] = "Версия %s"
L["by Wheelbarrel00"] = "от Wheelbarrel00"
L["Commands"] = "Команды"

-- Options/Frame.lua
L["Clear"] = "Сбросить"

-- Data/Filter.lua
L["World Quests"] = "Локальные задания"
L["Bonus Objectives"] = "Бонусные цели"
L["Campaign quests"] = "Кампания"
L["Daily quests"] = "Ежедневные задания"
L["Weekly quests"] = "Еженедельные задания"
L["Normal quests"] = "Обычные задания"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "Щёлкните ЛКМ, чтобы открыть, ПКМ - чтобы убрать отслеживание."

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = "Готово к сдаче"

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = "Бонусная добыча вылазки"

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = "Нажмите, чтобы посмотреть задание"
L["Quest Complete!"] = "Задание выполнено!"
L["Quest Discovered!"] = "Задание обнаружено!"

-- UI/RewardTooltip.lua
L["Equip \226\128\148 empty slot"] = "Экипировать - пустой слот"
L["Equipped: ilvl %d"] = "Экипировано: ур. %d"
L["+%d ilvl upgrade"] = "+%d ур. улучшение"
L["%d ilvl lower"] = "на %d ур. ниже"
L["Same item level"] = "Тот же уровень предмета"
L["ilvl %d"] = "ур. %d"
L["%d XP"] = "%d опыта"
L["Choose one:"] = "Выберите одно:"
L["Time Left: "] = "Осталось: "

-- UI/Row.lua
L["Find Group"] = "Найти группу"
L["Open the Premade Group Finder for this quest."] = "Открыть поиск готовых групп для этого задания."

-- UI/Scenario.lua
L["Final Stage"] = "Финальный этап"
L["Stage %d"] = "Этап %d"

-- UI/ScenarioBonusHUD.lua
L["Unlock (allow moving)"] = "Разблокировать (разрешить перемещение)"
L["Lock position"] = "Заблокировать положение"
L["Reset position"] = "Сбросить положение"

-- UI/Sections.lua
L["Zone Progress"] = "Прогресс зоны"
L["Quests"] = "Задания"
L["Achievements"] = "Достижения"
L["Endeavors"] = "Устремления"
L["Profession"] = "Профессия"

-- UI/Tracker.lua
L["Tracker locked"] = "Трекер заблокирован"
L["Open the options panel"] = "Открыть панель настроек"
