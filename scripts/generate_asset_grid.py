#!/usr/bin/env python3
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

W=H=2048
X1,X2=896,1664
ROW_H=512
OUT=Path("docs/references/object_sheet_grid_2048.png")
OUT.parent.mkdir(parents=True,exist_ok=True)
img=Image.new("RGB",(W,H),(22,25,32))
d=ImageDraw.Draw(img)
line=(215,220,230);sub=(90,98,112);text=(240,244,248);muted=(175,183,196)
d.rectangle([0,0,X1-1,H-1],fill=(34,43,57));d.rectangle([X1,0,X2-1,H-1],fill=(41,47,61));d.rectangle([X2,0,W-1,H-1],fill=(48,43,57))
d.line([(X1,0),(X1,H)],fill=line,width=4);d.line([(X2,0),(X2,H)],fill=line,width=4)
for y in (512,1024,1536):d.line([(0,y),(W,y)],fill=line,width=4)
d.rectangle([1,1,W-2,H-2],outline=line,width=4)
font_b="/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf";font_r="/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
try:
    big=ImageFont.truetype(font_b,48);small=ImageFont.truetype(font_r,20);med=ImageFont.truetype(font_b,26)
except OSError:
    big=small=med=None

def center(t,l,r,y,f,c):
    box=d.textbbox((0,0),t,font=f);tw=box[2]-box[0];d.text(((l+r-tw)/2,y),t,font=f,fill=c)
center("WORLD",0,X1,24,big,text);center("896 px",0,X1,82,small,muted)
center("SPOT",X1,X2,24,big,text);center("768 px",X1,X2,82,small,muted)
center("ICON",X2,W,24,big,text);center("384 px",X2,W,82,small,muted)
for i in range(4):
    y0=i*ROW_H;top=y0+130;bottom=y0+ROW_H-28;pad=28
    d.rectangle([pad,top,X1-pad,bottom],outline=sub,width=2)
    d.rectangle([X1+pad,top,X2-pad,bottom],outline=sub,width=2)
    d.rectangle([X2+pad,top,W-pad,bottom],outline=sub,width=2)
    d.text((30,y0+470),f"ITEM {i+1:02d} | ROW {i+1}: y={y0}-{y0+ROW_H}",font=small,fill=muted)
footer="FOUNDER SIM OBJECT SHEET | 2048x2048 | 4 ITEMS | WORLD 896 | SPOT 768 | ICON 384"
box=d.textbbox((0,0),footer,font=med);tw=box[2]-box[0]
d.rectangle([(W-tw)//2-16,H-58,(W+tw)//2+16,H-14],fill=(15,17,22));d.text(((W-tw)//2,H-54),footer,font=med,fill=text)
img.save(OUT)
print(OUT)
