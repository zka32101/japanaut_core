"""Showglobe series icon generator.

Usage: python3 gen_icons.py OUT_DIR  ->  OUT_DIR/icon_<cc>.svg (1024px) and OUT_DIR/sheet.svg
See ../README.md for the series rules (frame, globe badge, country-code plate, flag colours).
"""
import math
def defs(i):
    return f'''<defs>
<clipPath id="c{i}"><rect width="512" height="512" rx="112"/></clipPath>
<radialGradient id="bg{i}" cx=".3" cy=".22" r="1.05"><stop offset="0" stop-color="#FF5A5F"/><stop offset=".55" stop-color="#E03442"/><stop offset="1" stop-color="#9E1B2A"/></radialGradient>
<radialGradient id="sph{i}" cx=".38" cy=".3" r=".85"><stop offset="0" stop-color="#fff" stop-opacity=".30"/><stop offset=".6" stop-color="#fff" stop-opacity=".06"/><stop offset="1" stop-color="#000" stop-opacity=".18"/></radialGradient>
<linearGradient id="tor{i}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset=".55" stop-color="#F6E6E3"/><stop offset="1" stop-color="#E4C9C5"/></linearGradient>
<linearGradient id="rim{i}" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset=".45" stop-color="#F2C9CC"/><stop offset=".55" stop-color="#C9707A"/><stop offset="1" stop-color="#FFE9EA"/></linearGradient>
<radialGradient id="bd{i}" cx=".35" cy=".3" r=".9"><stop offset="0" stop-color="#FFFFFF"/><stop offset=".7" stop-color="#F3EAE8"/><stop offset="1" stop-color="#D9C6C3"/></radialGradient>
<linearGradient id="gl{i}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff" stop-opacity=".38"/><stop offset="1" stop-color="#fff" stop-opacity="0"/></linearGradient>
<filter id="sh{i}" x="-20%" y="-20%" width="140%" height="150%"><feGaussianBlur in="SourceAlpha" stdDeviation="7"/><feOffset dy="9"/><feComponentTransfer><feFuncA type="linear" slope=".45"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<filter id="shs{i}" x="-40%" y="-40%" width="180%" height="190%"><feGaussianBlur in="SourceAlpha" stdDeviation="4"/><feOffset dy="5"/><feComponentTransfer><feFuncA type="linear" slope=".5"/></feComponentTransfer><feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>
<filter id="nz{i}"><feTurbulence type="fractalNoise" baseFrequency=".9" numOctaves="2" seed="4"/><feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 .5 0"/></filter>
</defs>'''
def globe(i):
    # large faint sphere behind the torii, with meridians/parallels following the sphere
    s=f'<g transform="translate(256,262)"><circle r="190" fill="url(#sph{i})"/>'
    for rx in (60,125,190):
        s+=f'<ellipse rx="{rx}" ry="190" fill="none" stroke="#fff" stroke-opacity=".16" stroke-width="2.5"/>'
    for y in (-110,-55,0,55,110):
        w=math.sqrt(190**2-y**2)
        s+=f'<ellipse cx="0" cy="{y}" rx="{w:.1f}" ry="{w*0.13:.1f}" fill="none" stroke="#fff" stroke-opacity=".14" stroke-width="2.5"/>'
    return s+'<circle r="190" fill="none" stroke="#fff" stroke-opacity=".22" stroke-width="3"/></g>'
def torii(i):
    return f'''<g filter="url(#sh{i})" fill="url(#tor{i})"><path d="M118,138 Q256,118 394,138 L388,160 Q256,142 124,160 Z"/>
<rect x="150" y="162" width="212" height="22" rx="7"/><rect x="166" y="198" width="180" height="14" rx="5"/>
<rect x="186" y="176" width="24" height="152" rx="5"/><rect x="302" y="176" width="24" height="152" rx="5"/><rect x="244" y="178" width="24" height="30" rx="3"/></g>
<path d="M118,138 Q256,118 394,138" fill="none" stroke="#fff" stroke-width="3" stroke-opacity=".9" stroke-linecap="round"/>'''
def badge(i,x,y):
    g=f'<g transform="translate({x},{y})" filter="url(#shs{i})"><circle r="50" fill="url(#rim{i})"/><circle r="43" fill="url(#bd{i})"/>'
    g+='<g fill="none" stroke="#B3202E" stroke-width="4.5"><circle r="27"/><ellipse rx="11" ry="27"/><line x1="-27" x2="27"/></g>'
    g+='<ellipse cx="-13" cy="-19" rx="17" ry="8" transform="rotate(-30 -13 -19)" fill="#fff" fill-opacity=".75"/></g>'
    return g
def plate(i,code,tc):
    return f'''<g transform="translate(142,378)" filter="url(#shs{i})"><rect x="-58" y="-30" width="116" height="60" rx="22" fill="url(#rim{i})"/><rect x="-52" y="-24" width="104" height="48" rx="18" fill="url(#bd{i})"/>
<text x="0" y="11" font-size="31" font-weight="800" text-anchor="middle" fill="{tc}" letter-spacing="2" font-family="DejaVu Sans, Arial, sans-serif">{code}</text>
<ellipse cx="-20" cy="-14" rx="22" ry="6" fill="#fff" fill-opacity=".7"/></g>'''
def icon(i,code='JP',c0='#FF5A5F',c1='#E03442',c2='#9E1B2A',tc='#B3202E',m='jp',ac='#fff'):
    return defs(i).replace('#FF5A5F',c0).replace('#E03442',c1).replace('#9E1B2A',c2)+f'''<g clip-path="url(#c{i})"><rect width="512" height="512" fill="url(#bg{i})"/>{globe(i)}{OV.get(m,'')}{MOTIFS[m](i)}
<rect width="512" height="512" filter="url(#nz{i})" opacity=".10"/>
<path d="M0,0 H512 V190 Q256,250 0,170 Z" fill="url(#gl{i})"/>
<rect x="11" y="11" width="490" height="490" rx="102" fill="none" stroke="url(#rim{i})" stroke-width="9"/>
<rect x="29" y="29" width="454" height="454" rx="86" fill="none" stroke="{ac}" stroke-opacity=".95" stroke-width="4"/>
<rect x="5" y="5" width="502" height="502" rx="108" fill="none" stroke="#000" stroke-opacity=".25" stroke-width="3"/>
{badge(i,372,376)}{plate(i,code,tc)}</g>'''

F=lambda i:f'filter="url(#sh{i})" fill="url(#tor{i})"'
def kr(i): return f'''<g {F(i)}><path d="M96,170 Q150,168 256,146 Q362,168 416,170 Q402,192 372,190 L140,190 Q110,192 96,170 Z"/><rect x="150" y="196" width="212" height="12" rx="4"/>
<path d="M130,214 Q256,196 382,214 Q372,232 350,230 L162,230 Q140,232 130,214 Z"/><rect x="164" y="236" width="22" height="92" rx="4"/><rect x="326" y="236" width="22" height="92" rx="4"/><rect x="244" y="236" width="24" height="92" rx="4"/></g>'''
def th(i): return f'''<g {F(i)}><path d="M256,104 L266,150 L286,150 L282,176 L304,176 L298,206 L326,206 L316,246 L350,246 L338,290 L368,290 L360,330 L152,330 L144,290 L174,290 L162,246 L196,246 L186,206 L214,206 L208,176 L230,176 L226,150 L246,150 Z"/></g>
<g stroke="#B3202E" stroke-opacity=".0"></g>'''
def fr(i): return f'''<g {F(i)}><path d="M256,100 L276,170 L290,170 L300,236 Q322,290 346,330 L304,330 Q290,300 256,292 Q222,300 208,330 L166,330 Q190,290 212,236 L222,170 L236,170 Z"/></g>
<g fill="none" stroke="#6B5BD2" stroke-opacity=".5" stroke-width="5"><path d="M228,170 H284"/><path d="M214,236 H298"/><path d="M232,200 L276,236 M280,200 L236,236"/></g>'''
def it(i): 
    arches=''.join(f'<path d="M{x},{y+34} v-22 a15,15 0 0 1 30,0 v22 Z"/>' for y in (170,224,278) for x in (136,176,216,256,296,336) if True)
    return f'''<g {F(i)}><path d="M112,158 Q256,132 400,158 L400,330 L112,330 Z"/></g><g fill="#1F6B3E" fill-opacity=".55">{arches}</g>'''
def eg(i): return f'''<g {F(i)}><path d="M60,330 L210,150 L330,330 Z"/><path d="M250,330 L350,196 L452,330 Z"/><path d="M200,330 L270,244 L330,330 Z" opacity=".8"/></g><circle cx="388" cy="140" r="22" fill="#fff" fill-opacity=".85"/>'''
def au(i): return f'''<g {F(i)}><path d="M96,330 Q100,200 232,150 Q226,250 214,330 Z"/><path d="M200,330 Q216,220 330,164 Q330,260 316,330 Z"/><path d="M300,330 Q330,240 416,206 Q410,280 396,330 Z"/></g>'''
def gb(i): return f'''<g {F(i)}><rect x="208" y="178" width="96" height="152" rx="6"/><path d="M200,178 L256,98 L312,178 Z"/><rect x="190" y="326" width="132" height="14" rx="4"/></g><circle cx="256" cy="214" r="27" fill="#2A3F6E" fill-opacity=".75"/><circle cx="256" cy="214" r="21" fill="#fff"/><path d="M256,214 V200 M256,214 L267,220" stroke="#2A3F6E" stroke-width="4" stroke-linecap="round"/>'''
def inn(i): return f'''<g {F(i)}><path d="M256,112 Q300,170 304,220 Q304,246 256,250 Q208,246 208,220 Q212,170 256,112 Z"/><rect x="176" y="250" width="160" height="80" rx="4"/><rect x="110" y="170" width="22" height="160" rx="6"/><rect x="380" y="170" width="22" height="160" rx="6"/><circle cx="121" cy="162" r="14"/><circle cx="391" cy="162" r="14"/></g><path d="M256,262 v68" stroke="#E0702F" stroke-opacity=".5" stroke-width="6"/>'''

def star(x,y,r): 
    import math
    pts=[]
    for k in range(10):
        rr=r if k%2==0 else r*0.42
        a=math.radians(-90+k*36); pts.append(f"{x+rr*math.cos(a):.1f},{y+rr*math.sin(a):.1f}")
    return f'<polygon points="{" ".join(pts)}" fill="#fff" fill-opacity=".85"/>'
OV={'gb':'<g opacity=".9"><path d="M0,0 L512,512 M512,0 L0,512" stroke="#fff" stroke-opacity=".20" stroke-width="40"/><path d="M0,0 L512,512 M512,0 L0,512" stroke="#C8102E" stroke-opacity=".34" stroke-width="12"/><path d="M256,0 V512 M0,256 H512" stroke="#fff" stroke-opacity=".22" stroke-width="64"/><path d="M256,0 V512 M0,256 H512" stroke="#C8102E" stroke-opacity=".40" stroke-width="30"/></g>',
'au':'<g>'+star(110,92,17)+star(200,70,13)+star(170,138,13)+star(300,100,13)+star(250,150,10)+star(400,118,22)+'</g>'}
MOTIFS={'jp':torii,'kr':kr,'th':th,'fr':fr,'it':it,'eg':eg,'au':au,'gb':gb,'in':inn}
SET=[('JP','日本 ― 赤い鳥居（日の丸の赤）','jp','#E0334F','#BC002D','#7E0020','#BC002D','#FFFFFF'),
('KR','韓国 ― 韓屋の門（太極旗の青・赤）','kr','#2A5FB0','#003478','#001A44','#003478','#CD2E3A'),
('TH','タイ ― 寺院の尖塔（国旗の紺・赤）','th','#4A4670','#2D2A4A','#17152B','#2D2A4A','#A51931'),
('FR','フランス ― エッフェル塔（青・白・赤）','fr','#3F86D4','#0055A4','#002F6C','#0055A4','#EF4135'),
('IT','イタリア ― コロッセオ（緑・白・赤）','it','#35BB72','#009246','#005A2B','#007A3A','#CE2B37'),
('EG','エジプト ― ピラミッド（赤・白・黒）','eg','#E8465A','#CE1126','#7C0A17','#9B0D1D','#1A1A1A'),
('AU','豪州 ― オペラハウス（紺・赤＋南十字星）','au','#2D4FA3','#012169','#000F3A','#012169','#C8102E'),
('GB','英国 ― ビッグ・ベン（紺・赤＋ユニオンジャック）','gb','#3250A0','#012169','#000F3A','#012169','#C8102E'),
('IN','インド ― 白亜の廟（サフラン・緑）','in','#FFB866','#FF9933','#D9700A','#000080','#138808')]

def finish(code,ic):
    ic=ic
    return ic
def render(i,row):
    code,label,m,c0,c1,c2,tc,ac=row
    ic=icon(i,code,c0,c1,c2,tc,m,ac).replace('stroke="#B3202E" stroke-width="4.5"',f'stroke="{tc}" stroke-width="4.5"')
    if code!='JP': ic=ic.replace('#F2C9CC','#E9E9EE').replace('#C9707A','#9A9AA8').replace('#FFE9EA','#F6F6FA')
    return ic
if __name__=='__main__':
    import os,sys
    out=sys.argv[1] if len(sys.argv)>1 else 'out'
    os.makedirs(out,exist_ok=True)
    for k,row in enumerate(SET):
        code=row[0].lower()
        open(f'{out}/icon_{code}.svg','w',encoding='utf-8').write(f'<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 512 512" font-family="DejaVu Sans, Arial, sans-serif">{render("i",row)}</svg>')
    W,H=1600,1420
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" font-family="Noto Sans CJK JP, IPAGothic, sans-serif"><rect width="{W}" height="{H}" fill="#F7F4EF"/>'
    for k,row in enumerate(SET):
        x=60+(k%3)*510; y=90+(k//3)*440
        svg+=f'<g transform="translate({x},{y}) scale(.74)">{render("k"+str(k),row)}</g><text x="{x+190}" y="{y+410}" font-size="22" text-anchor="middle" fill="#333">{row[1]}</text>'
    open(f'{out}/sheet.svg','w',encoding='utf-8').write(svg+'</svg>')
