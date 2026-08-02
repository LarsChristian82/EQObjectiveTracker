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
L["Zone"] = "Зона"
L["Status"] = "Статус"
L["Level"] = "Уровень"
L["Distance"] = "Расстояние"
L["Recent"] = "Недавние"
L["Manual"] = "Вручную"
L["General"] = "Основные"
L["Lock tracker"] = "Заблокировать трекер"
L["Keep focused quest after relog"] = "Сохранять выбранное задание после перезахода"
L["Restores the waypoint arrow."] = "Восстанавливает стрелку пути."
L["Hide tracker in combat"] = "Скрывать трекер в бою"
L["Hide tracker in instances"] = "Скрывать трекер в подземельях"
L["Raids, dungeons, delves."] = "Рейды, обычные подземелья, приключения."
L["Hide tracker when world map is open"] = "Скрывать трекер при открытой карте мира"
L["Hide tracker in Mythic+"] = "Скрывать трекер в Мифик+"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "Скрывает трекер во время активного забега Мифик+ и возвращает его после завершения."
L["Auto-track accepted quests"] = "Авто-отслеживание принятых заданий"
L["Matches Blizzard's default."] = "Соответствует стандарту Blizzard."
L["Show Options icon on the tracker"] = "Показывать значок настроек на трекере"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "Небольшая шестерёнка в правом верхнем углу трекера, открывающая панель настроек."
L["Split quest click"] = "Раздельный клик по заданию"
L["Click the icon to focus, click the title to open the quest log."] = "Нажмите на иконку, чтобы выбрать, на название - открыть журнал заданий."
L["Show usable quest item buttons"] = "Показывать кнопки используемых предметов заданий"
L["Show Quest Discovered popups"] = "Показывать всплывающие окна «Задание обнаружено»"
L["Boxes for newly discovered / completed quests."] = "Окошки для новых / выполненных заданий."
L["Simplify tracked achievements"] = "Упрощать отслеживаемые достижения"
L["Show only incomplete criteria for tracked achievements."] = "Показывать только невыполненные критерии для отслеживаемых достижений."
L["Show quest level prefix"] = "Показывать уровень задания в префиксе"
L["For example, [60] Title."] = "Пример: [60] Название."
L["Show quest ID"] = "Показывать ID задания"
L["Useful for bug reports."] = "Полезно для отчётов об ошибках."
L["Show NEW tag on recently accepted quests"] = "Показывать метку «NEW» у недавно принятых заданий"
L["For about an hour after accepting."] = "Около часа после принятия."
L["Quest Sound"] = "Звук задания"
L["Plays when a quest is ready to turn in."] = "Проигрывается, когда задание готово к сдаче."
L["Quest Complete Sound"] = "Звук выполнения задания"
L["Zone Progress Bar"] = "Полоса прогресса зоны"
L["Show zone progress bar"] = "Показывать полосу прогресса зоны"
L["Approximate questline progress."] = "Примерный прогресс по цепочкам заданий."
L["Float as a movable bar"] = "Перенос панели"
L["Drag to move; right-click to lock or reset."] = "Перетащите, чтобы переместить; \nПКМ - чтобы заблокировать или сбросить."
L["Scenario Bonus Objectives"] = "Бонусные цели сценария"
L["Show bonus objectives HUD"] = "Показывать HUD бонусных целей"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "Показывает небольшой перемещаемый список дополнительных бонусных целей, которые появляются в некоторых сценариях и вылазках, чтобы вы не пропустили их награды. Перетащите, чтобы переместить, ПКМ - чтобы заблокировать или сбросить. По умолчанию выкл."
L["HUD Scale"] = "Масштаб HUD"
L["Sizes the bonus objectives HUD."] = "Изменяет размер HUD бонусных целей."
L["Profiles"] = "Профили"
L["Active profile"] = "Активный профиль"
L["New Profile"] = "Новый профиль"
L["Profile name:"] = "Имя профиля:"
L["Create"] = "Создать"
L["Cancel"] = "Отмена"
L["Overwrite profile?"] = "Перезаписать профиль?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "Профиль с именем «%s» уже существует. Перезаписать его копией ваших текущих настроек?"
L["Overwrite"] = "Перезаписать"
L["Reset all settings"] = "Сбросить все настройки"
L["Reset"] = "Сброс"

-- Options/TabSections.lua
L["Top"] = "Вверху"
L["Bottom"] = "Внизу"
L["World Quests"] = "Локальные задания"
L["Position"] = "Положение"

-- Options/TabAppearance.lua
L["None"] = "Нет"
L["Plain"] = "Обычный"
L["Card"] = "Карточка"
L["Left"] = "Слева"
L["Center"] = "По центру"
L["Right"] = "Справа"
L["Same as tracker font"] = "Как шрифт трекера"
L["Appearance"] = "Внешний вид"
L["Font"] = "Шрифт"
L["Font Size"] = "Размер шрифта"
L["Outline"] = "Контур"
L["Title Size Offset"] = "Размер заголовка"
L["Text Shadow"] = "Тень текста"
L["Shadow Color"] = "Цвет тени"
L["Scenario"] = "Сценарий"
L["Banner Alignment"] = "Выравнивание баннера"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "Располагает баннер сценария / вылазки в трекере. Слева выравнивает его с текстом задания, По центру оставляет по центру (по умолчанию), а Справа прижимает к правому краю трекера."
L["Banner Text Size"] = "Размер текста баннера"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "Увеличивает или уменьшает текст этапа и названия на баннере сценария / вылазки. 0 - размер по умолчанию. Изображение баннера имеет фиксированный размер, поэтому большие значения могут выйти за его пределы."
L["Criteria Text Size"] = "Размер текста критериев"
L["Tracker Scale"] = "Масштаб трекера"
L["Row Layout"] = "Вид строк"
L["Card Padding"] = "Отступы карточки"
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = "Расстояние между краем карточки и текстом внутри неё. Большие значения делают карточки выше."
L["Header Color"] = "Цвет заголовка"
L["Header Size Offset"] = "Размер заголовков"
L["Header bar"] = "Полоса заголовка"
L["Bar Color"] = "Цвет полосы"
L["Bar Style"] = "Стиль полосы"
L["Bar Height"] = "Высота полосы"
L["Edge Softness"] = "Мягкость краёв"
L["Hide scroll bar"] = "Скрыть полосу прокрутки"
L["Scroll Bar Background"] = "Фон полосы прокрутки"
L["Scroll Bar Color"] = "Цвет полосы прокрутки"
L["Solid color thumb"] = "Одноцветный бегунок"
L["Thumb Color"] = "Цвет бегунка"
L["Thumb Width"] = "Ширина бегунка"
L["Hide scroll bar arrows"] = "Скрыть стрелки полосы прокрутки"
L["Background Color"] = "Цвет фона"
L["Border Color"] = "Цвет границы"
L["Border Thickness"] = "Толщина границы"
L["Zone Bar Appearance"] = "Вид полосы зоны"
L["Bar Texture"] = "Текстура полосы"
L["Count Color"] = "Цвет счётчика"

-- Options/TabAbout.lua
L["About"] = "Об аддоне"
L["Version %s"] = "Версия %s"
L["by Wheelbarrel00"] = "от Wheelbarrel00"
L["Commands"] = "Команды"

-- Options/Frame.lua
L["Clear"] = "Сбросить"

-- Data/Filter.lua
L["World quests"] = "Локальные задания"
L["Bonus Objectives"] = "Бонусные цели"
L["Campaign"] = "Кампания"
L["Daily"] = "Ежедневно"
L["Weekly"] = "Еженедельно"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "Щёлкните ЛКМ, чтобы открыть, ПКМ - чтобы убрать отслеживание."

-- Data/Providers/Scenarios.lua
L["Dungeon"] = "Подземелье"
L["Raid"] = "Рейд"

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
