"""Generates brand/theme/board.svg (common in-app theme concept: backgrounds, icons, components).

Usage: python3 gen_theme_board.py   (writes theme_board.svg in the current directory)
"""
import math
RED,DARK,DEEP='#BC002D','#E0334F','#7E0020'
G={
'home':'<path d="M3 11l9-8 9 8M5 10v10h5v-6h4v6h5V10"/>',
'map':'<path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2-6-2zM9 4v14M15 6v14"/>',
'plan':'<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M4 10h16M8 3v4M16 3v4"/>',
'people':'<circle cx="9" cy="9" r="3"/><circle cx="17" cy="10" r="2.5"/><path d="M3 19c0-3 3-5 6-5s6 2 6 5M15 15c3 0 6 1.5 6 4"/>',
'me':'<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6"/>',
'lens':'<rect x="3" y="7" width="18" height="13" rx="3"/><circle cx="12" cy="13.5" r="3.5"/><path d="M9 7l1.5-3h3L15 7"/>',
'search':'<circle cx="11" cy="11" r="6"/><path d="M16 16l5 5"/>',
'bowl':'<path d="M3 12h18c0 5-4 8-9 8s-9-3-9-8zM8 3l5 7M12 2l5 8"/>',
'book':'<path d="M4 5c3-1 5-1 8 1 3-2 5-2 8-1v14c-3-1-5-1-8 1-3-2-5-2-8-1zM12 6v14"/>',
'sakura':''.join(f'<path d="M12 12c-2-3-2-6 0-9 2 3 2 6 0 9z" transform="rotate({a} 12 12)"/>' for a in range(0,360,72)),
'trophy':'<path d="M7 4h10v5a5 5 0 0 1-10 0zM7 6H4v2a3 3 0 0 0 3 3M17 6h3v2a3 3 0 0 1-3 3M12 14v4M8 21h8"/>',
'globe':'<circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3 12h18"/>'}
def defs():
    return f'''<defs><clipPath id="pc"><rect width="480" height="280" rx="18"/></clipPath>
<linearGradient id="hd" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="{DARK}"/><stop offset=".55" stop-color="{RED}"/><stop offset="1" stop-color="{DEEP}"/></linearGradient>
<linearGradient id="night" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2A2F4A"/><stop offset="1" stop-color="#12141F"/></linearGradient>
<linearGradient id="paper" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#F4EEE6"/></linearGradient>
<radialGradient id="disc" cx=".35" cy=".28" r=".95"><stop offset="0" stop-color="#FF6A80"/><stop offset=".5" stop-color="{RED}"/><stop offset="1" stop-color="{DEEP}"/></radialGradient>
<radialGradient id="chip" cx=".35" cy=".28" r=".95"><stop offset="0" stop-color="#FFFFFF"/><stop offset="1" stop-color="#EFE3DD"/></radialGradient>
<linearGradient id="sky" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#F7C6CF"/><stop offset="1" stop-color="#E9A0B0"/></linearGradient>
<filter id="sh" x="-20%" y="-20%" width="140%" height="150%"><feGaussianBlur in="SourceAlpha" stdDeviation="3"/><feOffset dy="3"/><feComponentTransfer><feFuncA type="linear" slope=".3"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<filter id="nz"><feTurbulence type="fractalNoise" baseFrequency=".8" numOctaves="2" seed="3"/><feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 .5 0"/></filter>
</defs>'''
def grid(w,h,cx,cy,r,op,col='#fff'):
    s=''
    for k in (.35,.7,1):
        s+=f'<ellipse cx="{cx}" cy="{cy}" rx="{r*k*.55}" ry="{r*k}" fill="none" stroke="{col}" stroke-opacity="{op}" stroke-width="1.6"/>'
    for y in (-.55,0,.55):
        ww=math.sqrt(1-y*y)*r
        s+=f'<ellipse cx="{cx}" cy="{cy+y*r}" rx="{ww:.1f}" ry="{ww*.13:.1f}" fill="none" stroke="{col}" stroke-opacity="{op}" stroke-width="1.6"/>'
    s+=f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{col}" stroke-opacity="{op*1.4}" stroke-width="2"/>'
    return s
def glyph(name,x,y,size,color,sw=2):
    return f'<g transform="translate({x},{y}) scale({size/24})" fill="none" stroke="{color}" stroke-width="{sw*24/size*size/24:.2f}" stroke-linecap="round" stroke-linejoin="round">{G[name]}</g>'
def chipicon(name,x,y,r=28):
    return f'<g filter="url(#sh)"><circle cx="{x}" cy="{y}" r="{r}" fill="url(#disc)"/><circle cx="{x}" cy="{y}" r="{r-1}" fill="none" stroke="#fff" stroke-opacity=".55" stroke-width="2"/><ellipse cx="{x-r*.3}" cy="{y-r*.5}" rx="{r*.5}" ry="{r*.22}" fill="#fff" fill-opacity=".35"/></g>'+glyph(name,x-r*.55,y-r*.55,r*1.1,'#fff',1.8)
W,H=1600,1560
s=f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" font-family="Noto Sans CJK JP, IPAGothic, sans-serif">{defs()}<rect width="{W}" height="{H}" fill="#F7F4EF"/>'
s+='<text x="50" y="58" font-size="30" font-weight="700" fill="#222">Showglobe 共通テーマ案（日本版・朱）― 背景／アイコン／部品</text>'
# palette
pal=[('主色 朱','#BC002D'),('濃朱','#7E0020'),('明朱','#E0334F'),('桜','#FFB7C5'),('藍','#3D405B'),('和紙','#F7F4EF'),('墨','#1D1D1D'),('金','#C9A227')]
for i,(n,c) in enumerate(pal):
    x=50+i*190
    s+=f'<rect x="{x}" y="80" width="170" height="64" rx="12" fill="{c}" stroke="#0002"/><text x="{x+10}" y="166" font-size="16" fill="#333">{n}  {c}</text>'
# backgrounds
s+='<text x="50" y="215" font-size="22" font-weight="700" fill="#222">背景</text>'
bx=[50,560,1070]
# A paper
s+=f'<g transform="translate({bx[0]},230)" clip-path="url(#pc)"><rect width="480" height="280" rx="18" fill="url(#paper)" stroke="#0002"/>{grid(480,280,360,160,150,.10,"#BC002D")}<rect width="480" height="280" rx="18" filter="url(#nz)" opacity=".08"/>'
s+=f'<text x="22" y="40" font-size="20" font-weight="700" fill="#1D1D1D">A  和紙＋地球儀グリッド（ライト）</text><text x="22" y="66" font-size="15" fill="#666">通常画面の背景。グリッドは朱の極薄線</text><rect x="22" y="200" width="250" height="60" rx="14" fill="#fff" stroke="#0001"/><text x="40" y="236" font-size="16" fill="#333">カード（白＋細い縁）</text></g>'
# B night
s+=f'<g transform="translate({bx[1]},230)" clip-path="url(#pc)"><rect width="480" height="280" rx="18" fill="url(#night)"/>{grid(480,280,360,160,150,.12)}'
s+=''.join(f'<circle cx="{x}" cy="{y}" r="1.6" fill="#fff" fill-opacity=".7"/>' for x,y in [(40,30),(120,90),(200,50),(300,40),(420,70),(60,170),(240,120),(440,200),(330,250)])
s+='<text x="22" y="40" font-size="20" font-weight="700" fill="#fff">B  夜の地球儀（ダーク）</text><text x="22" y="66" font-size="15" fill="#B8BCD0">ダークモード背景。星は静止</text><rect x="22" y="200" width="250" height="60" rx="14" fill="#fff" fill-opacity=".08" stroke="#fff" stroke-opacity=".25"/><text x="40" y="236" font-size="16" fill="#E6E8F2">カード（半透明）</text></g>'
# C header gradient
s+=f'<g transform="translate({bx[2]},230)" clip-path="url(#pc)"><rect width="480" height="280" rx="18" fill="#F7F4EF"/><path d="M0,18 Q0,0 18,0 H462 Q480,0 480,18 V150 Q240,205 0,150 Z" fill="url(#hd)"/>{grid(480,280,380,70,110,.16)}<rect width="480" height="160" rx="18" filter="url(#nz)" opacity=".10"/>'
s+='<text x="22" y="48" font-size="20" font-weight="700" fill="#fff">C  朱のヘッダー（曲線）</text><text x="22" y="74" font-size="15" fill="#fff" fill-opacity=".85">ホーム等の上部。下端がゆるく湾曲</text><text x="22" y="236" font-size="16" fill="#555">下は和紙。本文はこの上に載る</text></g>'
# icons
s+='<text x="50" y="560" font-size="22" font-weight="700" fill="#222">アイコン（線画・太さ統一）と、ボタン用の立体チップ</text>'
names=['home','map','plan','people','me','lens','search','bowl','book','sakura','trophy','globe']
labels=['ホーム','地図','プラン','コミュニティ','プロフィール','AIレンズ','検索','メニュー','学ぶ','季節','ランキング','世界']
for i,(n,l) in enumerate(zip(names,labels)):
    x=50+i*128
    s+=glyph(n,x+30,590,52,RED,2)+f'<text x="{x+56}" y="668" font-size="14" text-anchor="middle" fill="#444">{l}</text>'
    s+=chipicon(n,x+56,730,30)
# phone mock
px,py=50,800
s+=f'<g transform="translate({px},{py})"><rect width="330" height="700" rx="34" fill="#111"/><clipPath id="scr"><rect x="8" y="8" width="314" height="684" rx="28"/></clipPath><g clip-path="url(#scr)"><rect x="8" y="8" width="314" height="684" fill="url(#paper)"/>{grid(314,684,260,520,170,.07,"#BC002D")}'
s+=f'<path d="M8,8 H322 V150 Q165,196 8,150 Z" fill="url(#hd)"/>{grid(314,200,270,70,90,.18)}'
s+='<text x="28" y="56" font-size="12" fill="#fff" fill-opacity=".85">こんにちは、Aさん</text><text x="28" y="84" font-size="22" font-weight="700" fill="#fff">日本を発見しよう</text>'
s+='<rect x="22" y="112" width="286" height="46" rx="23" fill="#fff" filter="url(#sh)"/>'+glyph('search',38,124,22,'#888',2)+'<text x="70" y="141" font-size="14" fill="#888">スポット・食べ物・文化を検索</text>'
items=[('lens','AIレンズ'),('bowl','メニュー'),('book','学ぶ'),('sakura','季節'),('map','地図'),('plan','プラン'),('trophy','ランク'),('globe','世界')]
for i,(n,l) in enumerate(items):
    cx=48+(i%4)*76; cy=215+(i//4)*84
    s+=chipicon(n,cx+18,cy,24)+f'<text x="{cx+18}" y="{cy+44}" font-size="11" text-anchor="middle" fill="#333">{l}</text>'
s+='<rect x="22" y="392" width="286" height="150" rx="18" fill="#fff" filter="url(#sh)"/><rect x="30" y="400" width="270" height="86" rx="12" fill="url(#sky)"/><path d="M30,470 Q90,430 150,462 T300,450 V486 H30 Z" fill="#fff" fill-opacity=".35"/>'
s+='<text x="36" y="512" font-size="14" font-weight="700" fill="#1D1D1D">伏見稲荷大社</text><text x="36" y="532" font-size="11" fill="#777">京都・神社　★ 4.8</text>'
# tab bar
s+='<rect x="8" y="630" width="314" height="62" fill="#fff" filter="url(#sh)"/>'
tabs=[('home','ホーム',1),('map','地図',0),('plan','プラン',0),('people','広場',0),('me','自分',0)]
for i,(n,l,a) in enumerate(tabs):
    cx=8+31+i*62.4
    col=RED if a else '#8A8A8A'
    if a: s+=f'<rect x="{cx-24}" y="636" width="48" height="26" rx="13" fill="{RED}" fill-opacity=".12"/>'
    s+=glyph(n,cx-10,640,20,col,2)+f'<text x="{cx}" y="682" font-size="10" text-anchor="middle" fill="{col}">{l}</text>'
s+='</g></g>'
# components
cx0=450
s+=f'<text x="{cx0}" y="830" font-size="22" font-weight="700" fill="#222">部品（ボタン・チップ・バッジ）</text>'
s+=f'<rect x="{cx0}" y="850" width="220" height="52" rx="26" fill="url(#disc)" filter="url(#sh)"/><text x="{cx0+110}" y="884" font-size="17" font-weight="700" fill="#fff" text-anchor="middle">プランを作る</text>'
s+=f'<rect x="{cx0+240}" y="850" width="220" height="52" rx="26" fill="#fff" stroke="{RED}" stroke-width="2"/><text x="{cx0+350}" y="884" font-size="17" font-weight="700" fill="{RED}" text-anchor="middle">あとで</text>'
for i,(t,a) in enumerate([('すべて',1),('神社',0),('食べ物',0),('自然',0),('祭り',0)]):
    x=cx0+i*92
    s+=f'<rect x="{x}" y="930" width="82" height="36" rx="18" fill="{RED if a else "#fff"}" stroke="{RED if a else "#0002"}"/><text x="{x+41}" y="954" font-size="14" text-anchor="middle" fill="{"#fff" if a else "#444"}">{t}</text>'
# streak/badge
s+=f'<g transform="translate({cx0},1000)" filter="url(#sh)"><rect width="200" height="70" rx="18" fill="#fff"/><circle cx="38" cy="35" r="22" fill="url(#disc)"/>'+glyph('trophy',26,23,24,'#fff',1.8)+'<text x="72" y="30" font-size="15" font-weight="700" fill="#222">Lv.3 旅人</text><text x="72" y="52" font-size="12" fill="#777">次まで 120 XP</text></g>'
s+=f'<g transform="translate({cx0+230},1000)" filter="url(#sh)"><rect width="230" height="70" rx="18" fill="#fff"/><circle cx="38" cy="35" r="22" fill="#FFE9D0"/><text x="38" y="43" font-size="24" text-anchor="middle">🔥</text><text x="72" y="30" font-size="15" font-weight="700" fill="#222">7日連続</text><text x="72" y="52" font-size="12" fill="#777">今日のチャレンジで継続</text></g>'
# empty state
s+=f'<g transform="translate({cx0},1110)"><rect width="460" height="300" rx="20" fill="#fff" stroke="#0001"/>{grid(460,300,230,120,80,.12,"#BC002D")}<circle cx="230" cy="110" r="58" fill="url(#disc)" filter="url(#sh)"/>'+glyph('map',200,80,60,'#fff',1.6)+'<text x="230" y="214" font-size="19" font-weight="700" text-anchor="middle" fill="#222">まだプランがありません</text><text x="230" y="242" font-size="14" text-anchor="middle" fill="#777">地図からスポットを選んで、最初の旅を作ろう</text><rect x="150" y="256" width="160" height="34" rx="17" fill="'+RED+'"/><text x="230" y="279" font-size="14" font-weight="700" text-anchor="middle" fill="#fff">スポットを探す</text></g>'
s+=f'<g transform="translate(940,830)"><text x="0" y="0" font-size="22" font-weight="700" fill="#222">ルール</text>'
rules=['・背景: 和紙の地に、朱の極薄グリッド。ダークは藍の夜空','・ヘッダー: 朱グラデ＋グリッド、下端を曲線に','・アイコン: 線画（太さ2・角丸）／強調は立体チップ','・影はやわらかく1段だけ。縁は白の細線','・文字最小サイズは12px（今の11px以下は引き上げ）','・各国版は 主色・副色・モチーフ だけ差し替え']
for i,r in enumerate(rules): s+=f'<text x="0" y="{38+i*34}" font-size="16" fill="#333">{r}</text>'
s+='</g></svg>'
open('theme_board.svg','w',encoding='utf-8').write(s)
