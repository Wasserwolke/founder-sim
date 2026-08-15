#!/usr/bin/env python3
from __future__ import annotations
import argparse,json
from pathlib import Path
import numpy as np
from PIL import Image

def detect_lines(im,n_cols=3,n_rows=4):
 gray=np.array(im.convert("L"),dtype=float);vg=np.abs(np.diff(gray,axis=1)).mean(axis=0);hg=np.abs(np.diff(gray,axis=0)).mean(axis=1)
 def pick(scores,count,length,min_sep):
  chosen=[]
  for idx in np.argsort(scores)[::-1]:
   pos=int(idx+1)
   if pos<length*.03 or pos>length*.97:continue
   if all(abs(pos-c)>=length*min_sep for c in chosen):chosen.append(pos)
   if len(chosen)==count:break
  return sorted(chosen)
 return [0]+pick(vg,n_cols-1,im.width,.15)+[im.width],[0]+pick(hg,n_rows-1,im.height,.10)+[im.height]

def remove_bg(im,tol=32):
 a=np.array(im.convert("RGBA"));samples=np.concatenate([a[:8,:8,:3].reshape(-1,3),a[:8,-8:,:3].reshape(-1,3),a[-8:,:8,:3].reshape(-1,3),a[-8:,-8:,:3].reshape(-1,3)]);bg=np.median(samples,axis=0);dist=np.max(np.abs(a[:,:,:3].astype(int)-bg.astype(int)),axis=2);a[:,:,3]=np.clip((dist-tol)*10,0,255).astype(np.uint8);return Image.fromarray(a,"RGBA")

def normalize(cell,size,transparent):
 cell=cell.convert("RGBA")
 if transparent:
  cell=remove_bg(cell);bbox=cell.getchannel("A").getbbox()
  if bbox:cell=cell.crop(bbox)
 maxw,maxh=size[0]-20,size[1]-20;scale=min(1,maxw/cell.width,maxh/cell.height)
 if scale<1:cell=cell.resize((round(cell.width*scale),round(cell.height*scale)),Image.Resampling.NEAREST)
 out=Image.new("RGBA",size,(0,0,0,0));out.alpha_composite(cell,((size[0]-cell.width)//2,(size[1]-cell.height)//2));return out

def main():
 p=argparse.ArgumentParser();p.add_argument("--sheet",required=True,type=Path);p.add_argument("--spec",type=Path);p.add_argument("--out",type=Path,default=Path("app/web/assets"));args=p.parse_args();spec_path=args.spec or args.sheet.with_suffix(".json");spec=json.loads(spec_path.read_text());im=Image.open(args.sheet).convert("RGBA");grid=spec.get("grid");cols=grid["columns"] if grid else detect_lines(im)[0];rows=grid["rows"] if grid else detect_lines(im)[1];outdir=args.out/spec["category"];outdir.mkdir(parents=True,exist_ok=True)
 for entry in spec["rows"]:
  r=entry["row"]-1;aid=entry["asset_id"]
  for c,kind in enumerate(("world","spot","icon")):
   x0,x1=cols[c],cols[c+1];y0,y1=rows[r],rows[r+1];cell=im.crop((x0+8,y0+8,x1-8,y1-8));size={"world":(512,384),"spot":(512,384),"icon":(256,256)}[kind];out=normalize(cell,size,transparent=kind!="world");out.save(outdir/f"{aid}_{kind}.png",optimize=True);print(outdir/f"{aid}_{kind}.png")
if __name__=="__main__":main()
