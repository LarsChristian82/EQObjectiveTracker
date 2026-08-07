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
L["Resizes this EQ Objective Tracker options window only. It does not change the quest tracker or anything shown in the game world. The new size applies when you let go of the slider."] = "이 EQ Objective Tracker 설정 창의 크기만 조절합니다. 퀘스트 추적기나 게임 화면에 표시되는 것은 바뀌지 않습니다. 슬라이더에서 손을 떼면 새 크기가 적용됩니다."
L["Reset all settings"] = "모든 설정 초기화"
L["Reset"] = "초기화"
L["Cancel"] = "취소"
L["Profiles"] = "프로필"
L["Switching profiles reloads the UI. Profiles are shared across characters. Use them to keep different setups such as raid and solo. |cffEBB706New Profile|r prompts for a name and creates it on the spot."] = "프로필을 전환하면 UI가 리로드됩니다. 프로필은 캐릭터 간 공유되며, 서로 다른 설정(예: 공격대 vs 솔로)을 유지하는 데 씁니다. |cffEBB706새 프로필|r은 이름을 입력받아 즉시 만듭니다."
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
L["Show only tracked quests"] = "추적 중인 퀘스트만 표시"
L["Simplify Mode"] = "간소화 모드"
L["Show only the first incomplete objective per quest."] = "퀘스트당 첫 미완료 목표만 표시."
L["Simplify tracked achievements"] = "추적 업적 간소화"
L["Show only incomplete criteria for tracked achievements."] = "추적 업적의 미완료 조건만 표시."
L["Sort Order"] = "정렬 순서"
L["Drag and drop the quests in the tracker to reorder them however you like."] = "추적기의 퀘스트를 드래그해서 원하는 대로 순서를 바꿀 수 있습니다."
L["Filters"] = "필터"
L["Show only quests in current zone"] = "현재 지역의 퀘스트만 표시"
L["Reset filters to defaults"] = "필터를 기본값으로 초기화"
L["Tracker Visibility"] = "추적기 표시"
L["Auto-list current-zone world quests"] = "현재 지역 전역 퀘스트 자동 목록"
L["Lists every WQ in your zone without tracking each."] = "각각 추적하지 않고 지역의 모든 전역 퀘스트를 나열합니다."
L["Set a custom World Quests height"] = "전역 퀘스트 높이 사용자 지정"
L["By default the World Quests area shares space with your quest list and gets squeezed when you have a lot of quests. Turn this on to give it its own height, set by the slider below."] = "기본적으로 전역 퀘스트 영역은 퀘스트 목록과 공간을 공유하여 퀘스트가 많으면 좁아집니다. 이 설정을 켜면 아래 슬라이더로 지정한 자체 높이를 갖습니다."
L["World Quests Height"] = "전역 퀘스트 높이"
L["Section Order"] = "섹션 순서"
L["Rearrange the tracker's sections with the arrows below. A section only appears on the tracker while it has something in it, so reordering an empty section won't look like anything changed. World Quests scroll in their own panel and can only sit at the very top or bottom, so use the Top/Bottom control."] = "아래 화살표로 추적기의 섹션 순서를 바꿉니다. 섹션은 내용이 있을 때만 추적기에 나타나므로, 비어 있는 섹션의 순서를 바꿔도 변화가 없어 보일 수 있습니다. 전역 퀘스트는 자체 패널에서 스크롤되며 맨 위 또는 맨 아래에만 놓을 수 있습니다 - 위/아래 조절을 사용하세요."
L["World Quests Position"] = "전역 퀘스트 위치"
L["Where the World Quests panel sits on the tracker. |cffffffffTop|r puts it above your quests. |cffffffffBottom|r keeps it below your quests, which is the default. World Quests scroll in their own capped panel, which is why they can't be mixed in between the other sections."] = "전역 퀘스트 패널이 추적기에서 놓이는 위치입니다. |cffffffff위|r는 퀘스트 위에, |cffffffff아래|r는 퀘스트 아래(기본값)에 둡니다. 전역 퀘스트는 자체 제한된 패널에서 스크롤되므로 다른 섹션 사이에 섞을 수 없습니다."
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
L["Plain"] = "단순"
L["Card"] = "카드"
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
L["How far the text drop-shadow is cast behind the letters. Higher values give a larger, more pronounced shadow. Lower values keep it tight. Only applies while Text Shadow is on."] = "글자 뒤로 그림자가 퍼지는 거리. 값이 클수록 그림자가 크고 뚜렷하며, 작을수록 좁습니다. 글자 그림자가 켜져 있을 때만 적용됩니다."
L["Scenario"] = "시나리오"
L["Draws a drop-shadow behind the scenario / delve banner text (the Stage and name lines). This is SEPARATE from the Text Shadow above, which affects only the quest and objective text. The banner is styled on its own."] = "시나리오/구렁 배너 글자(단계 및 이름 줄) 뒤에 그림자를 그립니다. 이는 위의 글자 그림자와 별개이며, 글자 그림자는 퀘스트와 목표 글자에만 적용됩니다 - 배너는 따로 스타일링됩니다."
L["How far the scenario banner's drop-shadow is cast. Higher values give a larger, more pronounced shadow. Lower values keep it tight. Only applies while the Scenario Text Shadow above is on."] = "시나리오 배너 그림자가 퍼지는 거리. 값이 클수록 크고 뚜렷하며, 작을수록 좁습니다. 위의 시나리오 글자 그림자가 켜져 있을 때만 적용됩니다."
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
L["Replaces the tracker scroll bar's textured thumb (the draggable block) with a flat single-color block. Use the Thumb Color and Thumb Width controls to style it. Off restores the stock Blizzard bar."] = "추적기 스크롤 막대의 텍스처 손잡이(드래그 블록)를 단색 블록으로 교체합니다. 손잡이 색상과 손잡이 너비로 스타일을 조정하세요. 끄면 블리자드 기본 막대로 복원됩니다."
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
L["Draws a colored gradient bar behind each section header (Quests, Campaign, World Quests, and so on), for a look closer to the default Blizzard tracker. Off by default."] = "각 섹션 머리글(퀘스트, 대장정, 전역 퀘스트 등) 뒤에 색상 그라데이션 막대를 그려 기본 블리자드 추적기에 가까운 모습으로 만듭니다. 기본은 꺼짐."
L["Bar Color"] = "막대 색상"
L["Bar Style"] = "막대 스타일"
L["Header Bar 1 is a horizontal gradient (bright on the left, dark on the right). Header Bar 2 is a vertical gradient (bright at the top, dark at the bottom). Bar Color, Bar Height, and Soft edges all apply to whichever style you pick."] = "헤더 막대 1은 가로 그라데이션입니다(왼쪽이 밝고 오른쪽이 어두움). 헤더 막대 2는 세로 그라데이션입니다(위쪽이 밝고 아래쪽이 어두움). 막대 색상, 막대 높이, 부드러운 가장자리는 선택한 스타일에 모두 적용됩니다."
L["Soft edges"] = "부드러운 가장자리"
L["Feathers the top, left, and right edges of the header bar so it blends into the UI instead of sitting in a hard box. The gradient color is unchanged. Only applies while Header bars is on. Off by default."] = "헤더 막대의 위쪽, 왼쪽, 오른쪽 가장자리를 부드럽게 하여 딱딱한 상자처럼 보이지 않고 UI에 자연스럽게 어우러지게 합니다. 그라데이션 색상은 그대로 유지됩니다. 헤더 막대가 켜져 있을 때만 적용되며, 기본값으로 꺼짐."
L["Bar Height"] = "막대 높이"
L["How tall the section-header bar is. The bar is centered on the header row, so larger values fill more of it."] = "섹션 머리글 막대의 높이입니다. 막대는 머리글 줄에 가운데 정렬되므로 값이 클수록 더 많이 채웁니다."
L["Edge Softness"] = "가장자리 부드러움"
L["How soft the header bar's feathered edges are when Soft edges is on. Higher is softer, lower tightens toward a hard edge."] = "부드러운 가장자리가 켜져 있을 때 헤더 막대의 가장자리가 얼마나 부드러운지 설정합니다. 값이 클수록 부드럽고, 작을수록 딱딱한 가장자리에 가까워집니다."
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
L["Line Spacing"] = "줄 간격"
L["Adds vertical space between a quest's objective lines, across the whole tracker. 0 keeps the default spacing."] = "추적기 전체에서 퀘스트 목표 줄 사이에 세로 여백을 추가합니다. 0은 기본 간격을 유지합니다."
L["Header Spacing"] = "머리글 간격"
L["Adds or removes space around section headers and beneath each quest's title. 0 keeps the default spacing."] = "섹션 머리글 주위와 각 퀘스트 제목 아래의 여백을 늘리거나 줄입니다. 0은 기본 간격을 유지합니다."
L["Quest Rows"] = "퀘스트 줄"
L["Row Layout"] = "줄 배치"
L["How each quest is drawn in the tracker. |cffffffffPlain|r is the default look - text straight on the tracker background. |cffffffffCard|r gives every quest its own panel with a background and border, which makes long lists easier to read apart."] = "추적기에서 각 퀘스트를 그리는 방식입니다. |cffffffff단순|r은 기본 모양으로, 추적기 배경 위에 글자만 표시합니다. |cffffffff카드|r는 퀘스트마다 배경과 테두리가 있는 개별 판을 주어 목록이 길어져도 구분하기 쉽습니다."
L["Fill color behind each quest card. Only used while Row Layout is set to Card."] = "각 퀘스트 카드 뒤의 채우기 색상입니다. 줄 배치가 카드일 때만 사용됩니다."
L["Outline color around each quest card. Only used while Row Layout is set to Card."] = "각 퀘스트 카드 둘레의 외곽선 색상입니다. 줄 배치가 카드일 때만 사용됩니다."
L["How thick the card outline is, in pixels. 0 hides the outline and leaves just the fill."] = "카드 외곽선의 두께입니다(픽셀). 0으로 하면 외곽선을 숨기고 채우기만 남깁니다."
L["Card Padding"] = "카드 여백"
L["Breathing room between a card's edge and the text inside it. Larger values make taller cards."] = "카드 가장자리와 그 안의 글자 사이 여백입니다. 값이 클수록 카드가 높아집니다."
L["Tint cards by quest type"] = "퀘스트 종류별 카드 색상"
L["Campaign"] = "대장정"
L["Legendary"] = "전설"
L["Dungeon"] = "던전"
L["Raid"] = "공격대"
L["Zone Progress Bar"] = "지역 진행 막대"
L["Show zone progress bar"] = "지역 진행 막대 표시"
L["Approximate questline progress."] = "대략적인 퀘스트라인 진행도."
L["Float as a movable bar"] = "이동 가능한 막대로 띄우기"
L["Zone Bar Scale"] = "지역 막대 배율"
L["Bar Texture"] = "막대 텍스처"
L["Sets the fill texture of the zone progress bar. Textures added by other media addons (such as SharedMedia, ElvUI, or Details) appear here too."] = "지역 진행 막대의 채우기 텍스처를 설정합니다. 다른 미디어 애드온(SharedMedia, ElvUI, Details 등)이 추가한 텍스처도 여기에 표시됩니다."
L["Header Color"] = "헤더 색상"
L["Count Color"] = "개수 색상"

-- Options/TabAbout.lua
L["About"] = "정보"
L["Version %s"] = "버전 %s"
L["by Wheelbarrel00"] = "제작: Wheelbarrel00"
L["Commands"] = "명령어"

-- Options/Frame.lua
L["Clear"] = "비우기"

-- Core/Init.lua
L["Copy the link below (it's pre-selected \226\128\148 just press Ctrl+C):"] = "아래 링크를 복사하세요(이미 선택됨 - Ctrl+C):"
L["Close"] = "닫기"

-- Data/Filter.lua
L["World Quests"] = "전역 퀘스트"
L["Bonus Objectives"] = "보너스 목표"
L["Campaign quests"] = "대장정 퀘스트"
L["Daily quests"] = "일일 퀘스트"
L["Weekly quests"] = "주간 퀘스트"
L["Normal quests"] = "일반 퀘스트"

-- Data/Providers/Achievements.lua
L["Left-click to open, right-click to untrack."] = "좌클릭하여 열기, 우클릭하여 추적 해제."

-- Data/Providers/Professions.lua
L["Left-click to open the recipe, right-click to untrack."] = "좌클릭하여 열기, 우클릭하여 추적 해제."

-- Data/Providers/WorldQuests.lua
L["Ready to turn in"] = "완료 가능"

-- Data/ScenarioBonus.lua
L["Delve Bonus Loot"] = "구렁 보너스 전리품"

-- UI/AutoQuestPopup.lua
L["Click to view quest"] = "클릭하여 퀘스트 보기"
L["Quest Complete!"] = "퀘스트 완료!"
L["Quest Discovered!"] = "퀘스트 발견!"

-- UI/Commands.lua
L["tracker locked."] = "추적기 잠김"

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

-- UI/RowMenu.lua
L["Pin to tracker"] = "추적기에 고정"
L["Unpin from tracker"] = "추적기에서 고정 해제"
L["Track Quest"] = "퀘스트 추적"
L["Untrack Quest"] = "퀘스트 추적 해제"
L["Focus"] = "집중 추적"
L["Unfocus"] = "집중 추적 해제"
L["Super-track (follow arrow)"] = "주요 추적 (화살표 따라가기)"
L["Open in Map & Quest Log"] = "지도 및 퀘스트 일지에서 열기"
L["Pop Out Quest Details"] = "퀘스트 상세 정보 창 띄우기"
L["Search on Wowhead"] = "Wowhead에서 검색"
L["Abandon Quest"] = "퀘스트 포기"

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
L["/eqot for options"] = "/eqot 로 설정 열기"
L["Open the options panel"] = "설정 패널 열기"
