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
L["General"] = "일반"
L["Lock tracker"] = "추적기 잠금"
L["Disable drag-to-move and resize."] = "드래그 이동/크기 조정 비활성화."
L["Hide tracker in combat"] = "전투 중 추적기 숨김"
L["Hide tracker in instances"] = "인스턴스에서 추적기 숨김"
L["Raids, dungeons, delves."] = "공격대, 던전, 구렁."
L["Hide tracker when world map is open"] = "지도 열면 추적기 숨김"
L["Hide tracker in Mythic+"] = "쐐기에서 추적기 숨김"
L["Hides the tracker during an active Mythic+ run, then brings it back when the run ends."] = "쐐기 진행 중에는 추적기를 숨기고, 종료되면 다시 표시합니다."
L["Auto-track accepted quests"] = "수락한 퀘스트 자동 추적"
L["Matches Blizzard's default."] = "블리자드 기본값과 동일."
L["Keep focused quest after relog"] = "재접속 후 집중 추적 퀘스트 유지"
L["Restores the waypoint arrow."] = "경로 화살표를 복원합니다."
L["Options Window Scale"] = "설정 창 배율"
L["Reset all settings"] = "모든 설정 초기화"
L["Reset"] = "초기화"
L["Cancel"] = "취소"
L["Profiles"] = "프로필"
L["Active profile"] = "활성 프로필"
L["New Profile"] = "새 프로필"
L["Profile name:"] = "프로필 이름:"
L["Create"] = "만들기"
L["Overwrite profile?"] = "프로필 덮어쓸까요?"
L["A profile named \"%s\" already exists. Overwrite it with a copy of your current settings?"] = "\"%s\" 프로필이 이미 있습니다. 현재 설정의 사본으로 덮어쓸까요?"
L["Overwrite"] = "덮어쓰기"

-- Options/TabTracker.lua
L["Zone"] = "지역"
L["Status"] = "상태"
L["Type"] = "종류"
L["Level"] = "레벨"
L["Distance"] = "거리"
L["Recent"] = "최근"
L["Manual"] = "수동"
L["Profession section"] = "전문기술 섹션"
L["Achievements section"] = "업적 섹션"
L["World Quests section"] = "전역 퀘스트 섹션"
L["Top"] = "위"
L["Bottom"] = "아래"
L["Move %s up"] = "%s 위로 이동"
L["Move %s down"] = "%s 아래로 이동"
L["Reorders where this section sits in the tracker. A section only shows while it has something in it, so empty sections won't visibly move."] = "이 섹션이 추적기에서 놓이는 위치를 바꿉니다. 섹션은 내용이 있을 때만 표시되므로, 비어 있는 섹션은 눈에 띄게 움직이지 않습니다."
L["Tracker"] = "추적기"
L["On-Screen Tracker"] = "화면 추적기"
L["Changes apply immediately to the on-screen tracker."] = "변경 사항이 화면 추적기에 즉시 적용됩니다."
L["Simplify Mode"] = "간소화 모드"
L["Show only the first incomplete objective per quest."] = "퀘스트당 첫 미완료 목표만 표시."
L["Simplify tracked achievements"] = "추적 업적 간소화"
L["Show only incomplete criteria for tracked achievements."] = "추적 업적의 미완료 조건만 표시."
L["Sort Order"] = "정렬 순서"
L["Filters"] = "필터"
L["Show only quests in current zone"] = "현재 지역의 퀘스트만 표시"
L["Reset filters to defaults"] = "필터를 기본값으로 초기화"
L["Tracker Visibility"] = "추적기 표시"
L["Auto-list current-zone world quests"] = "현재 지역 전역 퀘스트 자동 목록"
L["Lists every WQ in your zone without tracking each."] = "각각 추적하지 않고 지역의 모든 전역 퀘스트를 나열합니다."
L["Set a custom World Quests height"] = "전역 퀘스트 높이 사용자 지정"
L["By default the World Quests area shares space with your quest list and gets squeezed when you have a lot of quests. Turn this on to give it its own height, set by the slider below."] = "기본적으로 전역 퀘스트 영역은 퀘스트 목록과 공간을 공유하여 퀘스트가 많으면 좁아집니다. 이 설정을 켜면 아래 슬라이더로 지정한 자체 높이를 갖습니다."
L["Section Order"] = "섹션 순서"
L["Options"] = "설정"
L["Quest Title Color By Difficulty"] = "난이도별 퀘스트 제목 색상"
L["Show quest level prefix"] = "퀘스트 레벨 접두 표시"
L["For example, [60] Title."] = "예: [60] 제목."
L["Show zone label under quest titles"] = "퀘스트 제목 아래 지역 표시"
L["Show objective progress numbers"] = "목표 진행 숫자 표시"
L["For example, 0/4, 1/1, etc."] = "예: 0/4, 1/1 등."
L["Show quest ID"] = "퀘스트 ID 표시"
L["Useful for bug reports."] = "버그 신고에 유용."
L["Show usable quest item buttons"] = "사용 가능한 퀘스트 아이템 버튼 표시"
L["Show Options icon on the tracker"] = "추적기에 설정 아이콘 표시"
L["A small cogwheel at the top-right of the tracker that opens the options panel."] = "추적기 우상단의 작은 톱니바퀴로 설정 패널을 엽니다."
L["Show Quest Discovered popups"] = "퀘스트 발견 팝업 표시"
L["Boxes for newly discovered / completed quests."] = "새로 발견/완료된 퀘스트 상자."
L["Show NEW tag on recently accepted quests"] = "최근 수락 퀘스트에 NEW 표시"
L["For about an hour after accepting."] = "수락 후 약 1시간 동안."
L["Split quest click"] = "퀘스트 클릭 분리"
L["Click the icon to focus, click the title to open the quest log."] = "아이콘 클릭은 집중 추적, 제목 클릭은 퀘스트 일지를 엽니다."
L["Quest Sound"] = "퀘스트 소리"
L["Plays when a quest is ready to turn in."] = "퀘스트를 완료할 수 있을 때 재생됩니다."
L["Quest Complete Sound"] = "퀘스트 완료 소리"
L["Scenario Bonus Objectives"] = "시나리오 보너스 목표"
L["Show bonus objectives HUD"] = "보너스 목표 HUD 표시"
L["Shows a small movable checklist of the extra bonus objectives that appear during some scenarios and delves, so you do not miss their rewards. Drag to move, right-click to lock or reset. Off by default."] = "일부 시나리오와 구렁에서 나타나는 추가 보너스 목표를 작은 이동식 체크리스트로 표시하여 보상을 놓치지 않게 합니다. 드래그로 이동, 우클릭으로 잠금 또는 초기화. 기본은 꺼짐."
L["HUD Scale"] = "HUD 배율"
L["Sizes the bonus objectives HUD."] = "보너스 목표 HUD의 크기를 조정합니다."

-- Options/TabAppearance.lua
L["None"] = "없음"
L["Outline"] = "외곽선"
L["Thick"] = "두꺼움"
L["Mono"] = "모노"
L["Mono Outline"] = "모노 외곽선"
L["Mono Thick"] = "모노 두꺼움"
L["Header Bar 1"] = "헤더 막대 1"
L["Header Bar 2"] = "헤더 막대 2"
L["Left"] = "왼쪽"
L["Center"] = "중앙"
L["Right"] = "오른쪽"
L["Same as tracker font"] = "추적기 글꼴과 동일"
L["Appearance"] = "외형"
L["Font"] = "글꼴"
L["Font Size"] = "글꼴 크기"
L["Title Size Offset"] = "제목 크기 보정"
L["Sizes quest and achievement titles separately from the objective text. This value is added to the Font Size above: 0 keeps titles the same size as the base font, positive makes them larger, negative smaller."] = "퀘스트와 업적 제목을 목표 글자와 별도로 크기 조정합니다. 이 값은 위의 글꼴 크기에 더해집니다: 0이면 제목이 기본 글꼴과 같은 크기, 양수면 크게, 음수면 작게."
L["Header Size Offset"] = "머리글 크기 보정"
L["Sizes the section headers (Quests, Campaign, and so on) independently of the quest text. Added on top of the Font Size above: the default 4 keeps headers at their current size, lower shrinks them (handy on a low UI scale), higher enlarges them."] = "섹션 머리글(퀘스트, 대장정 등)을 퀘스트 글자와 독립적으로 크기 조정합니다. 위의 글꼴 크기에 더해집니다: 기본값 4는 머리글을 현재 크기로 유지하고, 낮추면 작아지며(낮은 UI 배율에서 유용), 높이면 커집니다."
L["Font Outline"] = "글꼴 외곽선"
L["Text Shadow"] = "글자 그림자"
L["Draws a soft drop-shadow behind all tracker text so it stays readable over bright or busy backgrounds. Use Shadow Color to tint it and Shadow Size to set how far it's cast."] = "추적기의 모든 글자 뒤에 부드러운 그림자를 그려 밝거나 복잡한 배경 위에서도 잘 보이게 합니다. 그림자 색상으로 색을 입히고 그림자 크기로 퍼지는 정도를 설정합니다."
L["Shadow Color"] = "그림자 색상"
L["Shadow Size"] = "그림자 크기"
L["Scenario"] = "시나리오"
L["Banner Alignment"] = "배너 정렬"
L["Positions the scenario / delve banner within the tracker. Left lines it up with the quest text, Center keeps it centered (the default), and Right pushes it to the tracker's right edge."] = "시나리오/구렁 배너를 추적기 안에서 정렬합니다. 왼쪽은 퀘스트 글자에 맞추고, 중앙은 가운데 정렬(기본값), 오른쪽은 추적기의 오른쪽 끝으로 붙입니다."
L["Banner Text Size"] = "배너 글자 크기"
L["Grows or shrinks the scenario / delve banner's Stage and name text. 0 is the default size. The banner artwork is a fixed size, so large values may overflow it."] = "시나리오/구렁 배너의 단계 및 이름 글자를 키우거나 줄입니다. 0이 기본 크기입니다. 배너 그림은 크기가 고정이라 값이 크면 넘칠 수 있습니다."
L["Criteria Text Size"] = "목표 글자 크기"
L["Sizes the scenario / delve objective (criteria) lines shown under the banner, separately from the Banner Text Size above. Raise it if the criteria text looks small next to your quest and World Quest text."] = "배너 아래에 표시되는 시나리오/구렁 목표(달성 조건) 줄의 크기를 위의 배너 글자 크기와 별도로 조정합니다. 목표 글자가 퀘스트 및 전역 퀘스트 글자보다 작아 보이면 높이세요."
L["Hide scroll bar"] = "스크롤 막대 숨김"
L["Scroll Bar Background"] = "스크롤 막대 배경"
L["Scroll Bar Color"] = "스크롤 막대 색상"
L["Solid color thumb"] = "단색 손잡이"
L["Thumb Color"] = "손잡이 색상"
L["Thumb Width"] = "손잡이 너비"
L["Hide scroll bar arrows"] = "스크롤 막대 화살표 숨김"
L["Hides the up and down arrow buttons at the ends of the tracker scroll bar. The bar still scrolls by dragging the thumb or using the mouse wheel."] = "추적기 스크롤 막대 양 끝의 위/아래 화살표 버튼을 숨깁니다. 막대는 손잡이를 드래그하거나 마우스 휠로 계속 스크롤됩니다."
L["Background"] = "배경"
L["Background Color"] = "배경 색상"
L["Border"] = "테두리"
L["Border Color"] = "테두리 색상"
L["Border Thickness"] = "테두리 두께"
L["Header Bar"] = "헤더 막대"
L["Bar Color"] = "막대 색상"
L["Bar Style"] = "막대 스타일"
L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."] = "헤더 막대 1은 가로 그라데이션입니다(왼쪽이 밝고 오른쪽이 어두움). 헤더 막대 2는 세로 그라데이션입니다(위쪽이 밝고 아래쪽이 어두움). 막대 색상, 막대 높이, 부드러운 가장자리는 선택한 스타일에 모두 적용됩니다."
L["Soft edges"] = "부드러운 가장자리"
L["Bar Height"] = "막대 높이"
L["Edge Softness"] = "가장자리 부드러움"
L["Colors & Dimensions"] = "색상 및 크기"
L["Reset to Defaults"] = "기본값으로 초기화"
L["Quest Title Color Override"] = "퀘스트 제목 색상 덮어쓰기"
L["When cleared, falls back to difficulty coloring or default yellow."] = "비우면 난이도 색상 또는 기본 노란색으로 돌아갑니다."
L["Colors quest, achievement, and endeavor titles with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "퀘스트, 업적, 과업 제목을 현재 접속한 캐릭터의 직업 색상으로 표시합니다. 켜져 있는 동안 위의 색상을 덮어씁니다. 기본은 꺼짐."
L["Use title color for completed quests"] = "완료 퀘스트에 제목 색상 사용"
L["Instead of green."] = "녹색 대신."
L["Section Header Color"] = "섹션 헤더 색상"
L["Colors the section headers (Quests, Campaign, and so on) with the class color of the character you are currently logged in on. Overrides the color above while it is on. Off by default."] = "섹션 머리글(퀘스트, 대장정 등)을 현재 접속한 캐릭터의 직업 색상으로 표시합니다. 켜져 있는 동안 위의 색상을 덮어씁니다. 기본은 꺼짐."
L["Divider Line Color"] = "구분선 색상"
L["Sets the color of the thin line under each section header. Defaults to the original gold."] = "각 섹션 머리글 아래의 가는 선 색상을 설정합니다. 기본값은 원래의 금색입니다."
L["Tracker Scale"] = "추적기 배율"
L["Block Spacing"] = "블록 간격"
L["Campaign"] = "대장정"
L["Zone Progress Bar"] = "지역 진행 막대"
L["Show zone progress bar"] = "지역 진행 막대 표시"
L["Approximate questline progress."] = "대략적인 퀘스트라인 진행도."
L["Float as a movable bar"] = "이동 가능한 막대로 띄우기"
L["Zone Bar Scale"] = "지역 막대 배율"
L["Header Color"] = "헤더 색상"
L["Count Color"] = "개수 색상"

-- Options/TabAbout.lua
L["About"] = "정보"
L["Version %s"] = "버전 %s"
L["by Wheelbarrel00"] = "제작: Wheelbarrel00"
L["Commands"] = "명령어"

-- Options/Frame.lua
L["Clear"] = "비우기"

-- Data/Filter.lua
L["World Quests"] = "전역 퀘스트"
L["Bonus Objectives"] = "보너스 목표"
L["Campaign quests"] = "대장정 퀘스트"
L["Daily quests"] = "일일 퀘스트"
L["Weekly quests"] = "주간 퀘스트"
L["Normal quests"] = "일반 퀘스트"

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
L["Time Left: "] = "남은 시간: "

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
