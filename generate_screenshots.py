import os
import math
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# 폰트 로드
FONT_PATH = '/System/Library/Fonts/AppleSDGothicNeo.ttc'
def get_font(size, weight='bold'):
    idx = 6 if weight == 'bold' else (4 if weight == 'semibold' else (2 if weight == 'medium' else 0))
    return ImageFont.truetype(FONT_PATH, size=size, index=idx)

WIDTH = 1080
HEIGHT = 1920
DESKTOP = os.path.expanduser('~/Desktop')
ASSETS_DIR = '/Users/hasangseon/good_morning/assets/images'

def create_gradient(w, h, top_color, bot_color):
    base = Image.new('RGBA', (w, h), top_color)
    top_r, top_g, top_b = top_color[:3]
    bot_r, bot_g, bot_b = bot_color[:3]
    for y in range(h):
        ratio = y / h
        r = int(top_r + (bot_r - top_r) * ratio)
        g = int(top_g + (bot_g - top_g) * ratio)
        b = int(top_b + (bot_b - top_b) * ratio)
        for x in range(w):
            base.putpixel((x, y), (r, g, b, 255))
    return base

def draw_header(draw, tag_text, tag_bg, tag_fg, title_text, sub_text, text_color=(30, 30, 35)):
    # 뱃지
    tag_font = get_font(30, 'bold')
    tag_bbox = tag_font.getbbox(tag_text)
    tag_w = tag_bbox[2] - tag_bbox[0] + 48
    tag_h = 56
    tag_x = (WIDTH - tag_w) // 2
    tag_y = 120
    draw.rounded_rectangle([tag_x, tag_y, tag_x + tag_w, tag_y + tag_h], radius=28, fill=tag_bg)
    draw.text((WIDTH // 2, tag_y + tag_h // 2), tag_text, fill=tag_fg, font=tag_font, anchor='mm')
    
    # 타이틀
    title_font = get_font(68, 'bold')
    lines = title_text.split('\n')
    line_y = tag_y + tag_h + 40
    for line in lines:
        draw.text((WIDTH // 2, line_y), line, fill=text_color, font=title_font, anchor='mt')
        line_y += 82
        
    # 서브타이틀
    sub_font = get_font(34, 'medium')
    draw.text((WIDTH // 2, line_y + 15), sub_text, fill=(110, 110, 120), font=sub_font, anchor='mt')

def create_phone_frame(screen_content):
    # phone dimension
    pw, ph = 780, 1380
    phone = Image.new('RGBA', (pw, ph), (0, 0, 0, 0))
    pdraw = ImageDraw.Draw(phone)
    
    # 바깥 블랙 베젤
    pdraw.rounded_rectangle([0, 0, pw, ph], radius=70, fill=(35, 38, 44))
    # 테두리 하이라이트
    pdraw.rounded_rectangle([2, 2, pw-2, ph-2], radius=68, outline=(70, 75, 85), width=3)
    
    # 내부 스크린 영역
    sw, sh = 744, 1344
    sx, sy = 18, 18
    
    # 스크린 내용 리사이즈 및 둥근 모서리 마스킹
    resized_screen = screen_content.resize((sw, sh), Image.Resampling.LANCZOS).convert('RGBA')
    mask = Image.new('L', (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh], radius=54, fill=255)
    
    phone.paste(resized_screen, (sx, sy), mask)
    
    # 다이나믹 아일랜드 / 카메라
    cam_w, cam_h = 160, 36
    cam_x = (pw - cam_w) // 2
    cam_y = sy + 14
    pdraw.rounded_rectangle([cam_x, cam_y, cam_x + cam_w, cam_y + cam_h], radius=18, fill=(15, 15, 18))
    
    # 드롭 섀도우 만들기
    shadow_pad = 60
    total_w = pw + shadow_pad * 2
    total_h = ph + shadow_pad * 2
    shadow_img = Image.new('RGBA', (total_w, total_h), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow_img)
    sdraw.rounded_rectangle([shadow_pad, shadow_pad + 20, shadow_pad + pw, shadow_pad + ph + 20], radius=70, fill=(0, 0, 0, 100))
    shadow_blurred = shadow_img.filter(ImageFilter.GaussianBlur(30))
    
    # 합성
    shadow_blurred.paste(phone, (shadow_pad, shadow_pad), phone)
    return shadow_blurred

def draw_bottom_bar(draw, w, h, active_idx=0):
    bar_h = 110
    bar_y = h - bar_h
    draw.rectangle([0, bar_y, w, h], fill=(255, 253, 249))
    draw.line([0, bar_y, w, bar_y], fill=(230, 225, 220), width=2)
    
    tabs = [('마음카드', '🖼️'), ('좋은글·명언', '📖'), ('매일건강', '🌿'), ('내 카드함', '📁')]
    tab_w = w / len(tabs)
    for i, (name, icon) in enumerate(tabs):
        tx = int(i * tab_w + tab_w / 2)
        is_act = (i == active_idx)
        color = (230, 74, 25) if is_act else (140, 120, 115)
        f_name = get_font(22, 'bold' if is_act else 'medium')
        f_icon = get_font(32, 'regular')
        
        draw.text((tx, bar_y + 32), icon, fill=color, font=f_icon, anchor='mm')
        draw.text((tx, bar_y + 75), name, fill=color, font=f_name, anchor='mm')

# 1. SCREENSHOT 1: 아침 인사 카드
def render_screen_1():
    sw, sh = 744, 1344
    img = Image.new('RGBA', (sw, sh), (250, 248, 245))
    draw = ImageDraw.Draw(img)
    
    # 상태바
    draw.text((50, 24), '09:41', fill=(40, 40, 40), font=get_font(24, 'bold'), anchor='lt')
    draw.text((sw - 50, 24), 'LTE 100%', fill=(40, 40, 40), font=get_font(22, 'medium'), anchor='rt')
    
    # 상단 앱바
    draw.text((sw // 2, 90), '마음카드', fill=(30, 30, 30), font=get_font(36, 'bold'), anchor='mm')
    draw.text((sw - 40, 90), '⚙️', fill=(80, 80, 80), font=get_font(32, 'regular'), anchor='mm')
    
    # 메인 카드 프리뷰 (bg_cherry_blossom.png)
    card_w, card_h = 664, 820
    card_x = (sw - card_w) // 2
    card_y = 140
    
    bg_img_path = os.path.join(ASSETS_DIR, 'bg_cherry_blossom.png')
    bg = Image.open(bg_img_path).resize((card_w, card_h), Image.Resampling.LANCZOS).convert('RGBA')
    
    # 카드 둥근 마스크
    cmask = Image.new('L', (card_w, card_h), 0)
    ImageDraw.Draw(cmask).rounded_rectangle([0, 0, card_w, card_h], radius=32, fill=255)
    
    # 어두운 틴트 오버레이 (텍스트 가독성)
    tint = Image.new('RGBA', (card_w, card_h), (0, 0, 0, 80))
    bg.paste(tint, (0, 0), tint)
    
    # 카드 안 텍스트
    bg_draw = ImageDraw.Draw(bg)
    card_title = "좋은 아침입니다 🌸"
    card_msg = "오늘 하루도 꽃처럼 화사하고\n웃음 가득한 행복한 하루\n보내시길 진심으로 바랍니다."
    bg_draw.text((card_w // 2, card_h // 2 - 80), card_title, fill=(255, 245, 200), font=get_font(42, 'bold'), anchor='mm')
    
    for idx, l in enumerate(card_msg.split('\n')):
        bg_draw.text((card_w // 2, card_h // 2 - 10 + idx * 56), l, fill=(255, 255, 255), font=get_font(34, 'bold'), anchor='mm')
    
    img.paste(bg, (card_x, card_y), cmask)
    
    # 카드 외곽선
    draw.rounded_rectangle([card_x, card_y, card_x + card_w, card_y + card_h], radius=32, outline=(230, 220, 210), width=2)
    
    # 카카오톡 전송 버튼
    btn_y = card_y + card_h + 36
    btn_h = 100
    draw.rounded_rectangle([card_x, btn_y, card_x + card_w, btn_y + btn_h], radius=24, fill=(254, 229, 0)) # 카카오 노랑
    draw.text((card_x + 70, btn_y + btn_h // 2), '💬', fill=(60, 30, 0), font=get_font(40, 'bold'), anchor='mm')
    draw.text((card_x + card_w // 2 + 20, btn_y + btn_h // 2), '카카오톡으로 바로 공유하기', fill=(58, 29, 0), font=get_font(34, 'bold'), anchor='mm')
    
    # 저장 및 복사 버튼
    sub_btn_y = btn_y + btn_h + 16
    draw.text((sw // 2, sub_btn_y + 20), '💾 갤러리 저장  |  📋 문구 복사', fill=(130, 120, 110), font=get_font(24, 'medium'), anchor='mm')
    
    # 하단 탭바
    draw_bottom_bar(draw, sw, sh, active_idx=0)
    return img

# 2. SCREENSHOT 2: 간편 제작 & 배경/문구 편집
def render_screen_2():
    sw, sh = 744, 1344
    img = Image.new('RGBA', (sw, sh), (250, 248, 245))
    draw = ImageDraw.Draw(img)
    
    draw.text((50, 24), '09:41', fill=(40, 40, 40), font=get_font(24, 'bold'), anchor='lt')
    draw.text((sw - 50, 24), 'LTE 100%', fill=(40, 40, 40), font=get_font(22, 'medium'), anchor='rt')
    
    draw.text((sw // 2, 90), '카드 만들기', fill=(30, 30, 30), font=get_font(36, 'bold'), anchor='mm')
    
    # 카드 미리보기 (bg_coffee_1786333143337.png)
    card_w, card_h = 664, 520
    card_x = (sw - card_w) // 2
    card_y = 140
    
    bg_img_path = os.path.join(ASSETS_DIR, 'bg_coffee_1786333143337.png')
    bg = Image.open(bg_img_path).resize((card_w, card_h), Image.Resampling.LANCZOS).convert('RGBA')
    cmask = Image.new('L', (card_w, card_h), 0)
    ImageDraw.Draw(cmask).rounded_rectangle([0, 0, card_w, card_h], radius=28, fill=255)
    
    tint = Image.new('RGBA', (card_w, card_h), (0, 0, 0, 90))
    bg.paste(tint, (0, 0), tint)
    bg_draw = ImageDraw.Draw(bg)
    bg_draw.text((card_w // 2, card_h // 2 - 40), "따뜻한 커피 한 잔 ☕", fill=(255, 230, 160), font=get_font(38, 'bold'), anchor='mm')
    bg_draw.text((card_w // 2, card_h // 2 + 30), "바쁜 일상 속에서도\n마음의 여유를 잃지 마세요", fill=(255, 255, 255), font=get_font(30, 'bold'), anchor='mm')
    img.paste(bg, (card_x, card_y), cmask)
    
    # 배경 선택 섹션
    sec_y = card_y + card_h + 30
    draw.text((card_x, sec_y), '배경 테마 선택 (30+)', fill=(40, 40, 40), font=get_font(28, 'bold'), anchor='lt')
    
    thumb_w, thumb_h = 148, 148
    sample_bgs = ['bg_sunrise_1786333105571.png', 'bg_rose_1786333119291.png', 'bg_forest_1786333154906.png', 'bg_sunflower.png']
    for idx, sbg in enumerate(sample_bgs):
        bx = card_x + idx * (thumb_w + 24)
        by = sec_y + 45
        t_img = Image.open(os.path.join(ASSETS_DIR, sbg)).resize((thumb_w, thumb_h), Image.Resampling.LANCZOS).convert('RGBA')
        tmask = Image.new('L', (thumb_w, thumb_h), 0)
        ImageDraw.Draw(tmask).rounded_rectangle([0, 0, thumb_w, thumb_h], radius=20, fill=255)
        img.paste(t_img, (bx, by), tmask)
        if idx == 0:
            draw.rounded_rectangle([bx, by, bx + thumb_w, by + thumb_h], radius=20, outline=(230, 74, 25), width=4)
    
    # 글꼴/색상/효과 툴바
    tool_y = sec_y + 45 + thumb_h + 35
    draw.text((card_x, tool_y), '글자 꾸미기 & 크기 조절', fill=(40, 40, 40), font=get_font(28, 'bold'), anchor='lt')
    
    tools = [('🔤 글꼴', '나눔명조'), ('🎨 글자색', '골드/화이트'), ('🔍 크기', '크게'), ('✍️ 문구수정', '직접입력')]
    tool_btn_w = (card_w - 30) // 2
    tool_btn_h = 75
    for i, (t1, t2) in enumerate(tools):
        row = i // 2
        col = i % 2
        tx = card_x + col * (tool_btn_w + 30)
        ty = tool_y + 45 + row * (tool_btn_h + 16)
        draw.rounded_rectangle([tx, ty, tx + tool_btn_w, ty + tool_btn_h], radius=18, fill=(255, 255, 255), outline=(225, 220, 215), width=2)
        draw.text((tx + 24, ty + tool_btn_h // 2), t1, fill=(50, 50, 50), font=get_font(26, 'bold'), anchor='lm')
        draw.text((tx + tool_btn_w - 24, ty + tool_btn_h // 2), t2, fill=(150, 100, 70), font=get_font(22, 'medium'), anchor='rm')
    
    draw_bottom_bar(draw, sw, sh, active_idx=0)
    return img

# 3. SCREENSHOT 3: 좋은글 & 명언
def render_screen_3():
    sw, sh = 744, 1344
    img = Image.new('RGBA', (sw, sh), (248, 249, 252))
    draw = ImageDraw.Draw(img)
    
    draw.text((50, 24), '09:41', fill=(40, 40, 40), font=get_font(24, 'bold'), anchor='lt')
    draw.text((sw - 50, 24), 'LTE 100%', fill=(40, 40, 40), font=get_font(22, 'medium'), anchor='rt')
    
    draw.text((sw // 2, 90), '좋은글 · 감동 명언', fill=(30, 30, 30), font=get_font(36, 'bold'), anchor='mm')
    
    # 카테고리 칩
    chips = ['🌟 추천글', '🌅 아침인사', '💖 위로·힐링', '📜 인생명언']
    chip_x = 40
    chip_y = 140
    for idx, chip in enumerate(chips):
        is_act = (idx == 0)
        cw = 150
        draw.rounded_rectangle([chip_x, chip_y, chip_x + cw, chip_y + 60], radius=30, fill=(211, 84, 0) if is_act else (255, 255, 255), outline=None if is_act else (220, 225, 230), width=1)
        draw.text((chip_x + cw // 2, chip_y + 30), chip, fill=(255, 255, 255) if is_act else (80, 80, 80), font=get_font(24, 'bold' if is_act else 'medium'), anchor='mm')
        chip_x += cw + 18
        
    # 좋은글 카드 리스트
    cards_data = [
        ("인생에서 가장 큰 행복은", "내가 사랑받고 있다는 확신이며,\n그보다 더 큰 행복은 내가 누군가를\n조건 없이 사랑하는 마음입니다.", "― 빅토르 위고"),
        ("오늘 하루를 선물처럼", "어제는 지나간 역사이고,\n내일은 알 수 없는 미스터리이며,\n오늘은 바로 '선물(Present)'입니다.", "― 엘리너 루스벨트"),
        ("지친 마음을 보듬는 한마디", "잠시 쉬어가도 괜찮습니다.\n꽃은 저마다 피어나는 계절이 다릅니다.", "― 오늘의 힐링편지")
    ]
    
    card_w = 664
    card_x = (sw - card_w) // 2
    cur_y = 230
    
    for title, desc, author in cards_data:
        ch = 260
        draw.rounded_rectangle([card_x, cur_y, card_x + card_w, cur_y + ch], radius=24, fill=(255, 255, 255), outline=(230, 235, 240), width=2)
        draw.text((card_x + 36, cur_y + 40), title, fill=(35, 35, 40), font=get_font(30, 'bold'), anchor='lm')
        draw.text((card_x + card_w - 36, cur_y + 40), '🔖', fill=(211, 84, 0), font=get_font(28, 'regular'), anchor='rm')
        
        dlines = desc.split('\n')
        for di, dl in enumerate(dlines):
            draw.text((card_x + 36, cur_y + 90 + di * 36), dl, fill=(90, 95, 105), font=get_font(24, 'medium'), anchor='lm')
            
        # 카드 제작 바로가기 버튼
        draw.text((card_x + 36, cur_y + ch - 35), author, fill=(150, 155, 165), font=get_font(20, 'regular'), anchor='lm')
        draw.rounded_rectangle([card_x + card_w - 180, cur_y + ch - 55, card_x + card_w - 30, cur_y + ch - 15], radius=20, fill=(255, 243, 235))
        draw.text((card_x + card_w - 105, cur_y + ch - 35), '카드로 만들기 >', fill=(211, 84, 0), font=get_font(20, 'bold'), anchor='mm')
        
        cur_y += ch + 28
        
    draw_bottom_bar(draw, sw, sh, active_idx=1)
    return img

# 4. SCREENSHOT 4: 매일건강 상식
def render_screen_4():
    sw, sh = 744, 1344
    img = Image.new('RGBA', (sw, sh), (246, 252, 248))
    draw = ImageDraw.Draw(img)
    
    draw.text((50, 24), '09:41', fill=(40, 40, 40), font=get_font(24, 'bold'), anchor='lt')
    draw.text((sw - 50, 24), 'LTE 100%', fill=(40, 40, 40), font=get_font(22, 'medium'), anchor='rt')
    
    draw.text((sw // 2, 90), '매일 매일 건강 상식', fill=(30, 30, 30), font=get_font(36, 'bold'), anchor='mm')
    
    # 상단 뱃지 배너
    banner_w = 664
    banner_h = 150
    banner_x = (sw - banner_w) // 2
    banner_y = 140
    draw.rounded_rectangle([banner_x, banner_y, banner_x + banner_w, banner_y + banner_h], radius=24, fill=(225, 245, 235))
    draw.text((banner_x + 36, banner_y + 45), '🌱 100세 시대를 위한 오늘의 건강 비결', fill=(46, 125, 50), font=get_font(28, 'bold'), anchor='lm')
    draw.text((banner_x + 36, banner_y + 95), '매일 아침 전해드리는 알기 쉬운 건강 꿀팁!', fill=(80, 130, 90), font=get_font(22, 'medium'), anchor='lm')
    
    # 건강 정보 리스트
    health_data = [
        ("💧 아침 기상 직후 따뜻한 물 한 잔", "밤새 축적된 노폐물 배출과 혈액 순환을 돕고\n장 운동을 활성화해 소화를 촉진합니다.", "심혈관 건강"),
        ("🍎 하루 사과 반 쪽과 제철 채소", "항산화 성분과 비타민이 풍부하여 면역력을\n높이고 혈관을 맑고 깨끗하게 유지해 줍니다.", "면역력 강화"),
        ("🚶 식후 20분 가벼운 산책 습관", "혈당 스파이크를 예방하고 관절 건강과\n우울감 해소에 탁월한 효과가 있습니다.", "혈당·관절")
    ]
    
    cur_y = banner_y + banner_h + 30
    for title, desc, tag in health_data:
        ch = 240
        draw.rounded_rectangle([banner_x, cur_y, banner_x + banner_w, cur_y + ch], radius=24, fill=(255, 255, 255), outline=(220, 235, 225), width=2)
        
        # 태그
        draw.rounded_rectangle([banner_x + 36, cur_y + 25, banner_x + 160, cur_y + 60], radius=15, fill=(235, 248, 240))
        draw.text((banner_x + 98, cur_y + 42), tag, fill=(46, 125, 50), font=get_font(20, 'bold'), anchor='mm')
        
        draw.text((banner_x + 36, cur_y + 90), title, fill=(30, 40, 35), font=get_font(28, 'bold'), anchor='lm')
        
        dlines = desc.split('\n')
        for di, dl in enumerate(dlines):
            draw.text((banner_x + 36, cur_y + 140 + di * 34), dl, fill=(90, 110, 95), font=get_font(22, 'medium'), anchor='lm')
            
        cur_y += ch + 24
        
    draw_bottom_bar(draw, sw, sh, active_idx=2)
    return img

def build_final_screenshots():
    configs = [
        {
            'filename': 'screenshot_1_morning.png',
            'bg_top': (255, 245, 240),
            'bg_bot': (255, 232, 224),
            'tag': '💌 매일 아침 카톡 인사',
            'tag_bg': (255, 224, 210),
            'tag_fg': (220, 60, 20),
            'title': '소중한 분들께 전하는\n따뜻한 아침 인사 카드',
            'sub': '아름다운 배경과 감동 문구로 마음을 전하세요',
            'renderer': render_screen_1
        },
        {
            'filename': 'screenshot_2_maker.png',
            'bg_top': (255, 250, 240),
            'bg_bot': (255, 238, 210),
            'tag': '⚡ 3초 초간단 제작',
            'tag_bg': (255, 235, 190),
            'tag_fg': (190, 90, 0),
            'title': '터치 한 번으로 완성하는\n나만의 맞춤 카드',
            'sub': '30여 가지 고화질 배경 & 글꼴·문구 자유 편집',
            'renderer': render_screen_2
        },
        {
            'filename': 'screenshot_3_wisdom.png',
            'bg_top': (246, 248, 255),
            'bg_bot': (230, 236, 255),
            'tag': '🌿 마음의 쉼표와 힐링',
            'tag_bg': (220, 228, 255),
            'tag_fg': (60, 80, 190),
            'title': '지친 마음을 위로하는\n감동 명언과 좋은 글',
            'sub': '매일 전해지는 인생 명언, 감동 시, 긍정 확언',
            'renderer': render_screen_3
        },
        {
            'filename': 'screenshot_4_health.png',
            'bg_top': (242, 252, 246),
            'bg_bot': (220, 245, 230),
            'tag': '🌱 100세 시대 필수 꿀팁',
            'tag_bg': (210, 242, 225),
            'tag_fg': (35, 120, 50),
            'title': '활기찬 하루를 위한\n매일 매일 건강 상식',
            'sub': '혈관 건강, 관절 관리, 제철 보약 음식 비결',
            'renderer': render_screen_4
        }
    ]
    
    created_paths = []
    for cfg in configs:
        # 1. 배경 생성
        canvas = create_gradient(WIDTH, HEIGHT, cfg['bg_top'], cfg['bg_bot'])
        draw = ImageDraw.Draw(canvas)
        
        # 2. 상단 헤더 카피
        draw_header(draw, cfg['tag'], cfg['tag_bg'], cfg['tag_fg'], cfg['title'], cfg['sub'])
        
        # 3. 폰 스크린 렌더링
        screen_img = cfg['renderer']()
        phone_mockup = create_phone_frame(screen_img)
        
        # 4. 폰 목업 배치 (상단 헤더 아래에 큼직하게 배치)
        mock_w, mock_h = phone_mockup.size
        mock_x = (WIDTH - mock_w) // 2
        mock_y = 520
        canvas.paste(phone_mockup, (mock_x, mock_y), phone_mockup)
        
        # 5. 데스크톱에 저장
        out_path = os.path.join(DESKTOP, cfg['filename'])
        canvas.convert('RGB').save(out_path, 'PNG', quality=95)
        created_paths.append(out_path)
        print(f"Generated: {out_path}")
        
    return created_paths

if __name__ == '__main__':
    paths = build_final_screenshots()
    print("All screenshots generated successfully.")
