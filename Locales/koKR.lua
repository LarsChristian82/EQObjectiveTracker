-- Locales/koKR.lua
-- Korean (koKR) translations for EQ Objective Tracker.
--
-- HOW TO USE: type the Korean translation between the quotes after each "=".
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

if GetLocale() ~= "koKR" then return end

local _, ns = ...
local L = ns.L


-- Options/TabGeneral.lua
L["Zone"] = "지역"
L["Status"] = "상태"
L["Level"] = "레벨"
L["Distance"] = "거리"
L["Recent"] = "최근"
L["Manual"] = "수동"
L["General"] = "일반"
L["Lock tracker"] = "추적기 잠금"
L["Keep focused quest after relog"] = "재접속 후 집중 추적 퀘스트 유지"
L["Restores the waypoint arrow."] = "경로 화살표를 복원합니다."
L["Hide tracker in combat"] = "전투 중 추적기 숨김"
L["Hide tracker in instances"] = "인스턴스에서 추적기 숨김"
L["Raids, dungeons, delves."] = "공격대, 던전, 구렁."
L["Hide tracker when world map is open"] = "지도 열면 추적기 숨김"
L["Hide tracker in Mythic+"] = "쐐기에서 추적기 숨김"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "쐐기 진행 중에는 추적기를 숨기고, 종료되면 다시 표시합니다."
L["Auto-track accepted quests"] = "수락한 퀘스트 자동 추적"
L["Matches Blizzard's default."] = "블리자드 기본값과 동일."
L["Show Options icon on the tracker"] = "추적기에 설정 아이콘 표시"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "추적기 우상단의 작은 톱니바퀴로 설정 패널을 엽니다."
L["Split quest click"] = "퀘스트 클릭 분리"
L["Click the icon to focus, click the title to open the quest log."] = "아이콘 클릭은 집중 추적, 제목 클릭은 퀘스트 일지를 엽니다."
L["Show usable quest item buttons"] = "사용 가능한 퀘스트 아이템 버튼 표시"
L["Show Quest Discovered popups"] = "퀘스트 발견 팝업 표시"
L["Boxes for newly discovered / completed quests."] = "새로 발견/완료된 퀘스트 상자."
L["Simplify tracked achievements"] = "추적 업적 간소화"
L["Show only incomplete criteria for tracked achievements."] = "추적 업적의 미완료 조건만 표시."
L["Show quest level prefix"] = "퀘스트 레벨 접두 표시"
L["For example, [60] Title."] = "예: [60] 제목."
L["Show quest ID"] = "퀘스트 ID 표시"
L["Useful for bug reports."] = "버그 신고에 유용."
L["Show NEW tag on recently accepted quests"] = "최근 수락 퀘스트에 NEW 표시"
L["For about an hour after accepting."] = "수락 후 약 1시간 동안."
L["Quest Sound"] = "퀘스트 소리"
L["Plays when a quest is ready to turn in."] = "퀘스트를 완료할 수 있을 때 재생됩니다."
L["Quest Complete Sound"] = "퀘스트 완료 소리"
L["Zone Progress Bar"] = "지역 진행 막대"
L["Show zone progress bar"] = "지역 진행 막대 표시"
L["Approximate questline progress."] = "대략적인 퀘스트라인 진행도."
L["Float as a movable bar"] = "이동 가능한 막대로 띄우기"
L["Drag to move; right-click to lock or reset."] = "드래그로 이동, 우클릭으로 잠금 또는 초기화."
L["Scenario Bonus Objectives"] = "시나리오 보너스 목표"
L["Show bonus objectives HUD"] = "보너스 목표 HUD 표시"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "일부 시나리오와 구렁에서 나타나는 추가 보너스 목표를 작은 이동식 체크리스트로 표시하여 보상을 놓치지 않게 합니다. 드래그로 이동, 우클릭으로 잠금 또는 초기화. 기본은 꺼짐."
L["HUD Scale"] = "HUD 배율"
L["Sizes the bonus objectives HUD."] = "보너스 목표 HUD의 크기를 조정합니다."
L["Profiles"] = "프로필"
L["Active profile"] = "활성 프로필"
L["New Profile"] = "새 프로필"
L["Profile name:"] = "프로필 이름:"
L["Create"] = "만들기"
L["Cancel"] = "취소"
L["Overwrite profile?"] = "프로필 덮어쓸까요?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "\"%s\" 프로필이 이미 있습니다. 현재 설정의 사본으로 덮어쓸까요?"
L["Overwrite"] = "덮어쓰기"
L["Reset all settings"] = "모든 설정 초기화"
L["Reset"] = "초기화"

-- Options/TabSections.lua
L["Top"] = "위"
L["Bottom"] = "아래"
L["World Quests"] = "전역 퀘스트"
L["Position"] = "위치"

-- Options/TabAppearance.lua
L["None"] = "없음"
L["Left"] = "왼쪽"
L["Center"] = "중앙"
L["Right"] = "오른쪽"
L["Same as tracker font"] = "추적기 글꼴과 동일"
L["Appearance"] = "외형"
L["Font"] = "글꼴"
L["Font Size"] = "글꼴 크기"
L["Outline"] = "외곽선"
L["Title Size Offset"] = "제목 크기 보정"
L["Text Shadow"] = "글자 그림자"
L["Shadow Color"] = "그림자 색상"
L["Scenario"] = "시나리오"
L["Banner Alignment"] = "배너 정렬"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "시나리오/구렁 배너를 추적기 안에서 정렬합니다. 왼쪽은 퀘스트 글자에 맞추고, 중앙은 가운데 정렬(기본값), 오른쪽은 추적기의 오른쪽 끝으로 붙입니다."
L["Banner Text Size"] = "배너 글자 크기"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "시나리오/구렁 배너의 단계 및 이름 글자를 키우거나 줄입니다. 0이 기본 크기입니다. 배너 그림은 크기가 고정이라 값이 크면 넘칠 수 있습니다."
L["Criteria Text Size"] = "목표 글자 크기"
L["Tracker Scale"] = "추적기 배율"
L["Header Color"] = "헤더 색상"
L["Header Size Offset"] = "머리글 크기 보정"
L["Header bar"] = "헤더 막대"
L["Bar Color"] = "막대 색상"
L["Bar Style"] = "막대 스타일"
L["Bar Height"] = "막대 높이"
L["Edge Softness"] = "가장자리 부드러움"
L["Hide scroll bar"] = "스크롤 막대 숨김"
L["Scroll Bar Background"] = "스크롤 막대 배경"
L["Scroll Bar Color"] = "스크롤 막대 색상"
L["Solid color thumb"] = "단색 손잡이"
L["Thumb Color"] = "손잡이 색상"
L["Thumb Width"] = "손잡이 너비"
L["Hide scroll bar arrows"] = "스크롤 막대 화살표 숨김"
L["Background Color"] = "배경 색상"
L["Border Color"] = "테두리 색상"
L["Border Thickness"] = "테두리 두께"
L["Zone Bar Appearance"] = "지역 막대 외형"
L["Count Color"] = "개수 색상"

-- Options/TabAbout.lua
L["About"] = "정보"
L["Version %s"] = "버전 %s"
L["by Wheelbarrel00"] = "제작: Wheelbarrel00"
L["Commands"] = "명령어"

-- Options/Frame.lua
L["Clear"] = "비우기"

-- Data/Filter.lua
L["World quests"] = "전역 퀘스트"
L["Bonus Objectives"] = "보너스 목표"
L["Campaign"] = "대장정"
L["Daily"] = "일일"
L["Weekly"] = "주간"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "좌클릭하여 열기, 우클릭하여 추적 해제."

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = "완료 가능"

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = "구렁 보너스 전리품"

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = "클릭하여 퀘스트 보기"
L["Quest Complete!"] = "퀘스트 완료!"
L["Quest Discovered!"] = "퀘스트 발견!"

-- UI/RewardTooltip.lua
L["Equip \226\128\148 empty slot"] = "장착 - 빈 슬롯"
L["Equipped: ilvl %d"] = "장착 중: 아이템 레벨 %d"
L["+%d ilvl upgrade"] = "+%d 아이템 레벨 상승"
L["%d ilvl lower"] = "%d 아이템 레벨 낮음"
L["Same item level"] = "동일 아이템 레벨"
L["ilvl %d"] = "아이템 레벨 %d"
L["%d XP"] = "%d 경험치"
L["Choose one:"] = "하나 선택:"

-- UI/Row.lua
L["Find Group"] = "그룹 찾기"
L["Open the Premade Group Finder for this quest."] = "이 퀘스트의 사전 구성 그룹 찾기를 엽니다."

-- UI/Scenario.lua
L["Final Stage"] = "마지막 단계"
L["Stage %d"] = "%d단계"

-- UI/ScenarioBonusHUD.lua
L["Unlock (allow moving)"] = "잠금 해제(이동 허용)"
L["Lock position"] = "위치 잠금"
L["Reset position"] = "위치 초기화"

-- UI/Sections.lua
L["Zone Progress"] = "지역 진행도"
L["Quests"] = "퀘스트"
L["Achievements"] = "업적"
L["Endeavors"] = "과업"
L["Profession"] = "전문기술"

-- UI/Tracker.lua
L["Tracker locked"] = "추적기 잠김"
L["Open the options panel"] = "설정 패널 열기"
