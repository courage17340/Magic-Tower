{$APPTYPE GUI}
{Line247}
uses
  graph,wincrt,gameunit,dos;
type
  rec_map=array[0..12,0..12] of longint;
  rec_i=record n,k:longint;end;
  rec_a=record x,y:longint;end;
  rec_p=record z,x,y,i:longint;end;
  rec_m=record v,o,d,g,n:longint;s:string;end;
  rec_s=record v,o,d:longint;end;
  rec_sp=record
           K:longint;
           area:rec_a;
           Switch:boolean;
           Req_n:longint;
           Req:array[1..25] of rec_p;
           Act_n:longint;
           Act:array[1..25] of rec_p;
           Cost:longint;
           Get_n:longint;
           Get:array[1..5] of rec_i;
           Msg1_n,Msg2_n:longint;
           Msg1,Msg2:array[1..10] of string;
           x,y,z,x1,y1:longint;
           kind:longint;
           dx,dy:longint;
           move:boolean;
           num:longint;
           d1,d2:longint;
        end;
  rec_st=record
           n:longint;
           s:array[1..10] of string;
         end;
var
  pic:array[-4..98,1..32,1..32] of longint;
  tmp:rec_map;
  passmode,difficulty,j:longint;
  g:file of char;
  num:array[1..15] of string;
  it:longint;
  step,laststep:longint;
  name:array[1..15] of string;
  next:array[1..4] of longint=(3,4,2,1);
  mode:longint;
  stand:array[0..100,1..2] of rec_p;
  b:array[1..4] of rec_a;
  a:array[0..100] of rec_map;//仇夕
  m:array[1..3,1..100] of rec_m;//講麗方象
  item:array[1..15] of longint;//祇醤
  wea,shi:array[1..3,1..5] of longint;//廾姥
  RB:array[1..3,0..100,1..4] of longint;//碕清
  f:text;
  gd,gm:smallint;
  s,map,map1:string;
  minx,miny,dx,dy:longint;
  z,x,y,vit,off,def,gold,weapon,shield,direction,key1,key2,key3,score:longint;//啾平方象
  Floor,minf,Mon:longint;
  shopmode,shopnum:longint;
  sk:array[0..5] of longint;
  sa:array[1..3,0..100] of rec_s;
  special:array[0..100] of longint;
  sp:array[0..100,1..10] of rec_sp;
  hide:array[0..100] of boolean;
  MonsterFirst:boolean;
  rec:array[0..100] of rec_st;
  yes_f:array[0..100] of boolean;
function ff(x:longint):longint;
begin
  case x of
    45:exit(200);
    48..57:exit(x-47);
    ord(' '):exit(192);
    ord('A')..ord('Z'):exit(x+100);
    ord('a')..ord('z'):exit(x+104);
    ord('='):exit(198);
  end;
  exit(x);
end;

function gg(x:longint):longint;
begin
  case x of
    1..10:exit(x+47);
    192:exit(ord(' '));
    165..190:exit(x-100);
    201..226:exit(x-104);
    198:exit(ord('='));
    200:exit(45);
  end;
  exit(x);
end;


function f1(s:char):char;
begin
  f1:=chr(ff(ord(s)));
end;


function f2(s:char):char;
begin
  f2:=chr(gg(ord(s)));
end;

function items(x,k:longint):string;
var
  s:string;
begin
  str(x,s);
  if k=1 then s:='['+s+']';
  case length(s) of
    1:items:='  '+s+'  ';
    2:items:=' '+s+'  ';
    3:items:=' '+s+' ';
    4:items:=s+' ';
  end;
end;

function yes_check(z,x,y,i:longint):boolean;
begin
  if a[z,x,y]=i then exit(true);
  if (i=0)and(a[z,x,y]=-1) then exit(true);
  exit(false);
end;

function price:longint;
var i:longint;
begin
  price:=0;
  for i:=0 to shopmode do price:=price*shopnum+sk[i];
end;

function workx(x:longint):longint;
begin
  exit(143+32*(x-1)+minx);
end;

function worky(y:longint):longint;
begin
  exit(23+32*(y-1)+miny);
end;

function works(x:longint):string;
var
  s:string;
begin
  if x=-1 then
    case direction of
      1:exit('data\w.txt');
      2:exit('data\s.txt');
      3:exit('data\a.txt');
      4:exit('data\d.txt');
    end;
  if x<-1 then
    begin
      str(x,s);
      s:='data\'+s+'.txt';
      exit(s);
    end;
  str(x,s);
  while length(s)<3 do s:='0'+s;
  s:='data\'+s+'.txt';
  exit(s);
end;

function worki(k:longint):rec_a;{item}
var
  x,y:longint;
begin
  y:=(k-1) div 3+1;
  x:=k mod 3;
  if x=0 then x:=3;
  worki.x:=minx+(x-1)*32+13;
  worki.y:=miny+(y-1)*32+190;
end;

function workc(mo:rec_a):rec_a;{click}
var
  p:longint;
begin
  workc.x:=0;
  workc.y:=0;
  for p:=1 to 11 do if (workx(p)<=mo.x)and(mo.x<=workx(p)+31) then workc.x:=p;
  for p:=1 to 11 do if (worky(p)<=mo.y)and(mo.y<=worky(p)+31) then workc.y:=p;
end;

function workm(k:longint):longint;
var
  i:longint;
begin
  for i:=1 to Mon do if m[passmode,i].n=k then exit(i);
  exit(0);
end;

function yes_yes(m:rec_a):boolean;
begin
  if (minx+120<=m.x)and(miny+450<=m.y)and(m.x<=minx+240)and(m.y<=miny+480) then exit(true);
  exit(false);
end;

function yes_no(m:rec_a):boolean;
begin
  if (minx+400<=m.x)and(miny+450<=m.y)and(m.x<=minx+520)and(m.y<=miny+480) then exit(true);
  exit(false);
end;

function yes_menu(m:rec_a):boolean;
begin
  if (minx+260<=m.x)and(miny+450<=m.y)and(m.x<=minx+380)and(m.y<=miny+480) then exit(true);
  exit(false);
end;

function damage(k:longint):longint;
var
  o,d,n:longint;
begin
  o:=off;
  if (item[4]>0)and(m[passmode,k].n in [55,59,71]) then o:=o*2;
  if (item[11]>0)and(m[passmode,k].n=85) then o:=o*2;
  d:=def;
  if o<=m[passmode,k].d then exit(maxlongint);
  if d>=m[passmode,k].o then exit(0);
  n:=m[passmode,k].v div (o-m[passmode,k].d);
  if m[passmode,k].v mod (o-m[passmode,k].d)=0 then dec(n);
  if MonsterFirst then inc(n);
  damage:=n*(m[passmode,k].o-d);
end;

procedure pick(var s:string;ch:char);
begin
  while s='' do readln(f,s);
  delete(s,1,pos(ch,s));
end;

procedure draw(s:string;draw_x,draw_y:longint);//鮫夕
var
  f:text;
  i,j,len,wid,p:longint;
begin
  assign(f,s);
  reset(f);
  readln(f,len,wid);
  for i:=draw_x to draw_x+len-1 do
    begin
      for j:=draw_y to draw_y+wid-1 do
        begin
          read(f,p);
          putpixel(i,j,p);
        end;
      readln(f);
    end;
  close(f);
end;

procedure renewkey1;
var
  s:string;
begin
  bar(minx+557,miny+147,minx+591,miny+160);
  str(key1,s);
  outtextxy(minx+557,miny+151,s);
end;

procedure renewkey2;
var
  s:string;
begin
  bar(minx+557,miny+169,minx+591,miny+182);
  str(key2,s);
  outtextxy(minx+557,miny+173,s);
end;

procedure renewkey3;
var
  s:string;
begin
  bar(minx+557,miny+191,minx+591,miny+204);
  str(key3,s);
  outtextxy(minx+557,miny+195,s);
end;

procedure renewweapon;
var
  s:string;
begin
  str(weapon,s);
  s:='data\w'+s+'.txt';
  draw(s,minx+523,miny+44);
end;

procedure renewshield;
var
  s:string;
begin
  str(shield,s);
  s:='data\s'+s+'.txt';
  draw(s,minx+523,miny+92);
end;

procedure renewvit;
var
  s:string;
begin
  str(vit,s);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+40,miny+80,minx+110,miny+94);
  outtextxy(minx+48,miny+84,s);
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

procedure renewoff;
var
  s:string;
begin
  str(off,s);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+40,miny+104,minx+110,miny+118);
  outtextxy(minx+48,miny+108,s);
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

procedure renewdef;
var
  s:string;
begin
  str(def,s);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+40,miny+128,minx+110,miny+142);
  outtextxy(minx+48,miny+132,s);
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

procedure renewgold;
var
  s:string;
begin
  str(gold,s);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+40,miny+152,minx+110,miny+166);
  outtextxy(minx+48,miny+156,s);
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

procedure renewitem(k:longint);
var
  s:string;
begin
  bar(worki(k).x,worki(k).y,worki(k).x+31,worki(k).y+31);
  if item[k]=0 then exit;
  str(k,s);
  if length(s)=1 then s:='0'+s;
  s:='data\i'+s+'.txt';
  draw(s,worki(k).x,worki(k).y);
end;

procedure renewl;
var
  s:string;
begin
  str(z,s);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+77,miny+48,minx+110,miny+65);
  outtextxy(minx+84,miny+53,s);
  setfillstyle(1,getpixel(minx+613,miny+63));
end;


procedure renewcommand;
begin
  if mode=2 then
    begin
      setfillstyle(1,getpixel(minx-10,miny-10));
      bar(minx+120,miny+450,minx+520,miny+480);
      setfillstyle(1,getpixel(minx+613,miny+63));
      exit;
    end;
  setfillstyle(1,4);
  bar(minx+120,miny+450,minx+240,miny+480);
  bar(minx+260,miny+450,minx+380,miny+480);
  bar(minx+400,miny+450,minx+520,miny+480);
  outtextxy(minx+170,miny+460,'YES');
  outtextxy(minx+310,miny+460,'MENU');
  outtextxy(minx+450,miny+460,'NO');
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

procedure showchoice;
var
  s:string;
  i:longint;
begin
  if mode=2 then
    begin
      setfillstyle(1,getpixel(minx-10,miny-10));
      bar(minx+16,miny-33,minx+640,miny-1);
      setfillstyle(1,getpixel(minx+613,miny+63));
      exit;
    end;
  setfillstyle(1,4);
  for i:=0 to 9 do
    begin
      bar(minx+16+64*i,miny-33,minx+48+64*i,miny-1);
      str(i,s);
      outtextxy(minx+27+64*i,miny-20,s);
    end;
  setfillstyle(1,getpixel(minx+613,miny+63));
end;

function workn(m:rec_a):longint;
var
  i:longint;
begin
  for i:=0 to 9 do
    if (minx+16+64*i<=m.x)and(m.x<=minx+48+64*i)and(miny-33<=m.y)and(m.y<=miny-1)
      then exit(i);
  if yes_no(m) then exit(10);
  exit(-1);
end;

procedure showmessage(a:rec_st);
var
  i:longint;
begin
  bar(minx+1,miny-134,minx+641,miny-34);
  for i:=1 to a.n do
    outtextxy(minx+320-textwidth(a.s[i]) shr 1,miny-134+(i-1)*10,a.s[i]);
end;

procedure hello;
var
  m1:rec_st;
begin
  m1.n:=5;
  m1.s[1]:='Magic Tower(made by courage)';
  m1.s[2]:='Version:1.7d';
  case mode of
    1:m1.s[3]:='Mode:mouse';
    2:m1.s[3]:='Mode:keyboard';
  end;
  m1.s[4]:='Round:'+chr(48+passmode);
  case difficulty of
    1:m1.s[5]:='Difficulty:normal';
    2:m1.s[5]:='Difficulty:hard';
  end;
  showmessage(m1);
end;

procedure renewm(k:longint);
var
  s:string;
  m1:rec_st;
  p:longint;
begin
  bar(minx+553,miny+226,minx+599,miny+263);
  setfillstyle(1,getpixel(minx+13,miny+49));
  bar(minx+526,miny+270,minx+623,miny+285);
  bar(minx+560,miny+291,minx+623,miny+304);
  bar(minx+560,miny+311,minx+623,miny+324);
  bar(minx+560,miny+331,minx+623,miny+344);
  setfillstyle(1,getpixel(minx+613,miny+63));
  draw(works(m[passmode,k].n),minx+559,miny+229);
  str(m[passmode,k].v,s);outtextxy(minx+562,miny+294,s);
  str(m[passmode,k].o,s);outtextxy(minx+562,miny+314,s);
  str(m[passmode,k].d,s);outtextxy(minx+562,miny+334,s);
  outtextxy(minx+539,miny+274,m[passmode,k].s);
  m1.n:=2;
  str(damage(k),s);
  m1.s[1]:='Expected damage:'+s;
  p:=m[passmode,k].g;
  if item[15]>0 then p:=p*2;
  str(p,s);
  m1.s[2]:='Expected gold:'+s;
  if damage(k)=maxlongint then m1.s[1]:='Can''t be hit by you!';
  showmessage(m1);
end;

procedure change(zz,x,y,i:longint);
var
  p:longint;
  m1:rec_st;
begin
  if not(x in [1..11]) then exit;
  if not(y in [1..11]) then exit;
  if (a[zz,x,y]=-1)and(workm(i)>0) then
    begin
      MonsterFirst:=true;
      vit:=vit-damage(workm(i));
      renewvit;
      p:=m[passmode,workm(i)].g;
      if item[15]>0 then p:=p*2;
      gold:=gold+p;
      renewgold;
      m1.n:=2;
      m1.s[1]:='You''ve beat '+m[passmode,workm(i)].s+'.';
      str(p,m1.s[2]);
      m1.s[2]:='Received '+m1.s[2]+' Gold.';
      showmessage(m1);
      MonsterFirst:=false;
      exit;
    end;
  a[zz,x,y]:=i;
  if zz=z then begin draw(works(i),workx(y),worky(x));tmp[x,y]:=i;end;
end;

procedure WaitForYes;
var
  m:rec_a;
  sta:longint;
  ch:char;
begin
  if mode=1 then
    begin
      GetMouseState(m.x,m.y,sta);
      while sta<>0 do GetMouseState(m.x,m.y,sta);
      while sta=0 do GetMouseState(m.x,m.y,sta);
      while not yes_yes(m) do
        begin
          while sta<>0 do GetMouseState(m.x,m.y,sta);
          while sta=0 do GetMouseState(m.x,m.y,sta);
        end;
      exit;
    end;
  ch:=readkey;
  ch:=upcase(ch);
  while not(ord(ch) in [ord('Y'),13]) do
    begin
      ch:=readkey;
      ch:=upcase(ch);
    end;
end;

procedure renewall;
var
  i:longint;
begin
  renewkey1;
  renewkey2;
  renewkey3;
  renewweapon;
  renewshield;
  renewvit;
  renewoff;
  renewdef;
  renewgold;
  for i:=1 to 15 do renewitem(i);
  renewl;
  if mode=1 then renewcommand;
  if mode=1 then showchoice;
  hello;
end;

procedure WaitForChoice(var mm:rec_a);
var
  sta:longint;
  ch:char;
begin
  if mode=2 then
    begin
      ch:=readkey;
      while not (ch in ['n','N','0'..'9']) do ch:=readkey;
      case ch of
        'n','N':begin mm.x:=minx+460;mm.y:=miny+465;end;
        '0'..'9':begin mm.x:=minx+64*(ord(ch)-48)+32;mm.y:=miny-16;end;
      end;
      exit;
    end;
  sta:=0;
  while sta=0 do GetMouseState(mm.x,mm.y,sta);
  while not(workn(mm) in [0..10]) do
    begin
      while sta<>0 do GetMouseState(mm.x,mm.y,sta);
      while sta=0 do GetMouseState(mm.x,mm.y,sta);
    end;
end;

procedure init;
var
  s,s1,s2:string;
  i,j,k:longint;
begin
  fillchar(tmp,sizeof(tmp),1);
  for i:=-4 to 98 do
    if i<>-1 then
    begin
      assign(f,works(i));
      reset(f);
      readln(f,j,k);
      for j:=1 to 32 do
        for k:=1 to 32 do
          read(f,pic[i,j,k]);
      close(f);
    end;
  laststep:=9;
  Vit:=0;
  Off:=0;
  Def:=0;
  Gold:=0;
  passmode:=1;
  it:=1;
  for i:=1 to 15 do num[i]:=items(i,0);
  for z:=0 to 100 do
    for x:=0 to 12 do
      for y:=0 to 12 do
        a[z,x,y]:=1;
  shopnum:=1;
  gd:=0;
  initmouse;
  initgraph(gd,gm,'');
  assign(f,'main.ini');
  reset(f);
  readln(f,s);
  pick(s,'=');
  s1:=copy(s,1,pos(' ',s)-1);
  delete(s,1,pos(' ',s));
  s2:=s;
  val(s1,dx);
  val(s2,dy);
  readln(f,s);
  pick(s,'=');
  map:=s+'1';
  map1:=s;
  map:='map\'+map+'.map';
  map1:='map\'+map1+'.map';
  readln(f,mode);
  readln(f,difficulty);
  close(f);
  minx:=(Getmaxx-dx) div 2;
  miny:=(getmaxy-dy) div 3*2;
  draw('data\main.txt',minx,miny);
  setfillstyle(1,getpixel(minx+622,miny+206));
  wea[1,1]:=10;wea[1,2]:=20;wea[1,3]:=40;wea[1,4]:=50;wea[1,5]:=100;
  shi[1,1]:=10;shi[1,2]:=20;shi[1,3]:=40;shi[1,4]:=50;shi[1,5]:=100;
  for i:=2 to 3 do
    for j:=1 to 5 do
      begin
        wea[i,j]:=44*wea[i-1,j];
        shi[i,j]:=44*shi[i-1,j];
      end;
  fillchar(item,sizeof(item),0);
  fillchar(RB,sizeof(RB),0);
  fillchar(sa,sizeof(sa),0);
  fillchar(special,sizeof(special),0);
  fillchar(sp,sizeof(sp),0);
  fillchar(hide,sizeof(hide),0);
  fillchar(stand,sizeof(stand),0);
  fillchar(yes_f,sizeof(yes_f),false);
  direction:=1;
  key1:=0;
  key2:=0;
  key3:=0;
  b[1].x:=-1;b[1].y:=0;
  b[2].x:=1;b[2].y:=0;
  b[3].x:=0;b[3].y:=-1;
  b[4].x:=0;b[4].y:=1;
  MonsterFirst:=false;
  for i:=0 to 100 do rec[i].n:=1;
  for i:=0 to 100 do rec[i].s[1]:='You haven''t got messages on this floor.';
  name[1]:='Orb of Hero';
  name[2]:='Orb of Wisdom';
  name[3]:='Orb of Flying';
  name[4]:='Cross';
  name[5]:='Magic Elixir';
  name[6]:='Magic Mattock';
  name[7]:='Destructible Ball';
  name[8]:='Warp Staff';
  name[9]:='Wing to Fly up';
  name[10]:='Wing to Fly down';
  name[11]:='Dragon Slayer';
  name[12]:='Snow Crystal';
  name[13]:='Magic Key';
  name[14]:='Super Magic Mattock';
  name[15]:='Lucky Gold';
  step:=0;
end;

procedure loadmap;
var
  i,j,p,q,t,pp:longint;
  s1:string;
  ch:char;
begin
  map:=map+'a';
  assign(f,map);
  assign(g,map1);
  reset(g);
  rewrite(f);
  while not eof(g) do
    begin
      read(g,ch);
      if ord(ch)<>199 then write(f,f2(ch)) else writeln(f);
    end;          
close(f);close(g);

  assign(f,map);
  reset(f);
  readln(f,weapon,shield);
  readln(f,key1,key2,key3);
  readln(f,s);pick(s,'=');if Vit=0 then val(s,Vit);
  readln(f,s);pick(s,'=');if Off=0 then val(s,Off);
  readln(f,s);pick(s,'=');if Def=0 then val(s,Def);
  readln(f,s);pick(s,'=');val(s,Gold);
  readln(f,s);pick(s,'=');val(s,Floor);
  readln(f,s);pick(s,'=');val(s,minf);
  readln(f,s);pick(s,'=');
    s1:=copy(s,1,pos(' ',s)-1);val(s1,z);pick(s,' ');
    s1:=copy(s,1,pos(' ',s)-1);val(s1,x);pick(s,' ');
    val(s,y);
  readln(f,s);pick(s,'=');val(s,Mon);
  for i:=1 to Mon do
    begin
      readln(f,s);pick(s,'=');val(s,m[1,i].n);m[2,i].n:=m[1,i].n;m[3,i].n:=m[2,i].n;
      readln(f,s);pick(s,'=');m[1,i].s:=s;m[2,i].s:=m[1,i].s;m[3,i].s:=m[2,i].s;
      readln(f,s);pick(s,'=');val(s,m[1,i].v);m[2,i].v:=44*m[1,i].v;m[3,i].v:=44*m[2,i].v;
      readln(f,s);pick(s,'=');val(s,m[1,i].o);m[2,i].o:=44*m[1,i].o;m[3,i].o:=44*m[2,i].o;
      readln(f,s);pick(s,'=');val(s,m[1,i].d);m[2,i].d:=44*m[1,i].d;m[3,i].d:=44*m[2,i].d;
      readln(f,s);pick(s,'=');val(s,m[1,i].g);m[2,i].g:=m[1,i].g;m[3,i].g:=m[2,i].g;
    end;
{！！！！！！！！！！！！Shop！！！！！！！！！！！！}
  readln(f,s);pick(s,'=');val(s,shopmode);
  readln(f,s);pick(s,'=');s:=s+' ';
    for i:=0 to shopmode do
      begin
        s1:=copy(s,1,pos(' ',s)-1);
        pick(s,' ');
        val(s1,sk[i]);
      end;
{！！！！！！！！！！！！Hide！！！！！！！！！！！！}
  readln(f,s);pick(s,'=');val(s,t);
  for i:=1 to t do begin read(f,pp);Hide[pp]:=true;end;readln(f);
{！！！！！！！！！！！！Floors！！！！！！！！！！！！}
  for i:=minf to Floor+minf-1 do
    begin
      readln(f,s);
      pick(s,'=');
      for p:=1 to 11 do
        begin
          for q:=1 to 11 do read(f,a[i,p,q]);
          readln(f);
        end;
      readln(f,stand[i,1].x,stand[i,1].y,stand[i,1].i,stand[i,2].x,stand[i,2].y,stand[i,2].i);
      readln(f,s);pick(s,'=');val(s,t);
      if t=1 then
        for j:=1 to 4 do
          begin
            readln(f,s);pick(s,'=');val(s,RB[1,i,j]);
            RB[2,i,j]:=44*RB[1,i,j];RB[3,i,j]:=44*RB[2,i,j];
          end;
      readln(f,s);pick(s,'=');val(s,t);
      if t=1 then
        begin
          readln(f,s);pick(s,'=');val(s,sa[1,i].v);sa[2,i].v:=44*sa[1,i].v;sa[3,i].v:=44*sa[2,i].v;
          readln(f,s);pick(s,'=');val(s,sa[1,i].o);sa[2,i].o:=44*sa[1,i].o;sa[3,i].o:=44*sa[2,i].o;
          readln(f,s);pick(s,'=');val(s,sa[1,i].d);sa[2,i].d:=44*sa[1,i].d;sa[3,i].d:=44*sa[2,i].d;
        end;
      readln(f,s);pick(s,'=');val(s,special[i]);
      for j:=1 to special[i] do
        begin
          readln(f,s);pick(s,'=');val(s,t);
          sp[i,j].Switch:=true;
          sp[i,j].K:=t;
          case t of
            0:begin
                readln(f,s);pick(s,'=');val(s,sp[i,j].Req_n);
                for p:=1 to sp[i,j].Req_n do
                  begin
                    readln(f,s);pick(s,'=');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Req[p].x);pick(s,' ');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Req[p].y);pick(s,' ');
                    val(s,sp[i,j].Req[p].i);
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Act_n);
                for p:=1 to sp[i,j].Act_n do
                  begin
                    readln(f,s);pick(s,'=');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Act[p].x);pick(s,' ');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Act[p].y);pick(s,' ');
                    val(s,sp[i,j].Act[p].i);
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);
                    pick(s,'=');
                    sp[i,j].Msg1[p]:=s;
                  end;
              end;
            1,2:begin
                readln(f,s);pick(s,'=');
                  s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].area.x);
                  pick(s,' ');val(s,sp[i,j].area.y);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Cost);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Get_n);
                for p:=1 to sp[i,j].Get_n do
                  begin
                    readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                      val(s1,sp[i,j].Get[p].n);pick(s,' ');val(s,sp[i,j].Get[p].k);
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg1[p]:=s;
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg2_n);
                for p:=1 to sp[i,j].Msg2_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg2[p]:=s;
                  end;
              end;{1,2}
            3:begin
                 readln(f,s);pick(s,'=');
                  s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].area.x);
                  pick(s,' ');val(s,sp[i,j].area.y);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg1[p]:=s;
                  end;
              end;{3}
            4:begin
                readln(f,s);pick(s,'=');
                  s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].area.x);
                  pick(s,' ');val(s,sp[i,j].area.y);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Act_n);
                for p:=1 to sp[i,j].Act_n do
                  begin
                    readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                      val(s1,sp[i,j].Act[p].z);pick(s,' ');s1:=copy(s,1,pos(' ',s)-1);
                      val(s1,sp[i,j].Act[p].x);pick(s,' ');s1:=copy(s,1,pos(' ',s)-1);
                      val(s1,sp[i,j].Act[p].y);pick(s,' ');val(s,sp[i,j].Act[p].i);
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg1[p]:=s;
                  end;
              end;{4}
            5:begin
                readln(f,s);pick(s,'=');
                  s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].area.x);
                  pick(s,' ');val(s,sp[i,j].area.y);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg1[p]:=s;
                  end;
              end;{5}
            6:begin
                readln(f,s);pick(s,'=');val(s,sp[i,j].kind);
                if sp[i,j].kind=1 then
                  begin
                    readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                      val(s1,sp[i,j].x);pick(s,' ');val(s,sp[i,j].y);
                    readln(f,s);pick(s,'=');val(s,sp[i,j].d1);
                  end else
                    begin
                      readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                        val(s1,sp[i,j].x);pick(s,' ');val(s,sp[i,j].y);
                      readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                        val(s1,sp[i,j].x1);pick(s,' ');val(s,sp[i,j].y1);
                      readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                        val(s1,sp[i,j].d1);pick(s,' ');val(s,sp[i,j].d2);
                    end;
                 readln(f,s);pick(s,'=');
                 sp[i,j].move:=(s='1');
                 if s='1' then
                   begin
                     readln(f,s);pick(s,'=');val(s,sp[i,j].dx);
                     readln(f,s);pick(s,'=');val(s,sp[i,j].dy);
                   end;
              end;{6}
            7:begin
                readln(f,s);pick(s,'=');s1:=copy(s,1,pos(' ',s)-1);
                  val(s1,sp[i,j].area.x);pick(s,' ');val(s,sp[i,j].area.y);
                readln(f,s);pick(s,'=');val(s,sp[i,j].Req_n);
                for p:=1 to sp[i,j].Req_n do
                  begin
                    readln(f,s);pick(s,'=');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Req[p].x);pick(s,' ');
                    s1:=copy(s,1,pos(' ',s)-1);val(s1,sp[i,j].Req[p].y);pick(s,' ');
                    val(s,sp[i,j].Req[p].i);
                  end;
                readln(f,s);pick(s,'=');val(s,sp[i,j].Msg1_n);
                for p:=1 to sp[i,j].Msg1_n do
                  begin
                    readln(f,s);pick(s,'=');sp[i,j].Msg1[p]:=s;
                  end;
              end;{7}
          end;{case}
        end;{for_special}
    end;{for_Floor}
  close(f);
  if passmode=3 then sp[50,8].Act[2].i:=97 else sp[50,8].Act[2].i:=0;
  assign(f,map);
  erase(f);
  if difficulty=2 then
    begin
      m[3,mon].v:=12000000;
      m[3,mon].o:=3200000;
      m[3,mon].d:=400000;
    end;
end;{loadmap}

procedure paint_current;
var
  i,j,p,q:longint;
begin
  renewl;
  for i:=1 to 11 do
    for j:=1 to 11 do
      if a[z,i,j]<>tmp[i,j] then
        if a[z,i,j]=-1 then draw(works(-1),workx(j),worky(i)) else
        for p:=workx(j) to workx(j)+31 do
          for q:=worky(i) to worky(i)+31 do
            putpixel(p,q,pic[a[z,i,j],p-workx(j)+1,q-worky(i)+1]);
  for i:=1 to 11 do
    for j:=1 to 11 do
      tmp[i,j]:=a[z,i,j];
end;

procedure save(t:longint);
var
  i,j,k:longint;
  s,s1:string;
  f:text;
  g:file of char;
  ch:char;
begin
  str(t,s);
  if length(s)=1 then s:='0'+s;
  s1:=s;
  s:='a'+s;
  s:='save\'+s+'.txt';
  s1:='save\'+s1+'.dat';
  assign(f,s);
  rewrite(f);
  writeln(f,passmode);
  writeln(f,shopnum);
  writeln(f,vit);
  writeln(f,off);
  writeln(f,def);
  writeln(f,gold);
  writeln(f,z,' ',x,' ',y);
  writeln(f,direction);
  writeln(f,weapon);
  writeln(f,shield);
  writeln(f,key1,' ',key2,' ',key3);
  for i:=1 to 15 do writeln(f,item[i]);
  for i:=minf to minf+Floor-1 do
    begin
      for j:=1 to 11 do
        begin
          for k:=1 to 11 do write(f,a[i,j,k],' ');
          writeln(f);
        end;
      writeln(f);
    end;
  for i:=minf to minf+Floor-1 do
    begin
      for j:=1 to special[i] do write(f,ord(sp[i,j].Switch),' ');
      writeln(f);
    end;
  for i:=minf to minf+Floor-1 do writeln(f,ord(yes_f[i]));
  for i:=minf to minf+Floor-1 do
    if rec[i].s[1]='You haven''t got messages on this floor.'
      then writeln(f,0)
      else
        begin
          write(f,1,' ');
          for j:=1 to special[i] do
            if sp[i,j].Msg2_n>2 then
              begin
                writeln(f,j);
                break;
              end;
        end;
  writeln(f,it);
  close(f);
  assign(f,s);
  reset(f);
  assign(g,s1);
  rewrite(g);
  while not eof(f) do
    begin
      while not eoln(f) do
        begin
          read(f,ch);
          write(g,f1(ch));
        end;
      readln(f);
      write(g,chr(199));
    end;
  close(f);
  close(g);
  assign(f,s);
  erase(f);
end;

procedure load(t:longint);
var
  i,j,k,p:longint;
  s,s1:string;
  f:text;
  g:file of char;
  ch:char;
begin
  str(t,s);
  if length(s)=1 then s:='0'+s;
  s1:=s;
  s:='b'+s;
  s:='save\'+s+'.txt';
  s1:='save\'+s1+'.dat';
  assign(g,s1);
  reset(g);
  assign(f,s);
  rewrite(f);
  while not eof(g) do
    begin
      read(g,ch);
      if ord(ch)<>199 then write(f,f2(ch)) else writeln(f);
    end;
  close(f);
  close(g);
  assign(f,s);
  reset(f);
  read(f,passmode);
  read(f,shopnum);
  read(f,vit);
  read(f,off);
  read(f,def);
  read(f,gold);
  read(f,z,x,y);
  read(f,direction);
  read(f,weapon);
  read(f,shield);
  read(f,key1,key2,key3);
  for i:=1 to 15 do read(f,item[i]);
  for i:=minf to minf+Floor-1 do
    for j:=1 to 11 do
      for k:=1 to 11 do read(f,a[i,j,k]);
  for i:=minf to minf+Floor-1 do
    begin
      for j:=1 to special[i] do
        begin
          read(f,k);
          if ord(true)=k then sp[i,j].Switch:=true;
          if ord(false)=k then sp[i,j].Switch:=false;
        end;
    end;
  for i:=minf to minf+Floor-1 do
    begin
      read(f,k);
      if ord(true)=k then yes_f[i]:=true;
      if ord(false)=k then yes_f[i]:=false;
    end;
  for i:=minf to minf+Floor-1 do
    begin
      read(f,k);
      if k=1 then
        begin
          read(f,p);
          rec[i].n:=sp[i,p].Msg2_n-2;
          for j:=2 to rec[i].n+1 do
            rec[i].s[j-1]:=sp[i,p].Msg2[j];
        end;
    end;
  read(f,it);
  close(f);
  paint_current;
  renewall;
  assign(f,s);
  erase(f);
  if passmode=3 then sp[50,8].Act[2].i:=97 else sp[50,8].Act[2].i:=0;
end;

procedure fail;
var
  m1:rec_st;
begin
  m1.n:=2;
  m1.s[1]:='You''ve failed the game';
  m1.s[2]:='Click on the YES button to quit';
  showmessage(m1);
  WaitForYes;
  closegraph;
  donemouse;
  halt;
end;

procedure WaitForCommand(var mm:rec_a;i:longint);
var
  m1:rec_st;
  sta:longint;
  ch:char;
begin
  if mode=2 then
    begin
      m1.n:=3;
      m1.s[1]:=name[i];
      m1.s[2]:='Are you sure to use it?';
      m1.s[3]:='(Press Y/N)';
      showmessage(m1);
      ch:=readkey;ch:=upcase(ch);
      while not(ch in [chr(13),'Y','N',#0]) do
        begin
          ch:=readkey;ch:=upcase(ch);
        end;
      if ch in [#0,'N'] then begin if ch=#0 then ch:=readkey;mm.x:=minx+460;mm.y:=miny+465;exit;end;
      if ch in [chr(13),'Y'] then begin mm.x:=minx+180;mm.y:=miny+465;end;
      exit;
    end;
  m1.n:=3;
  m1.s[1]:=name[i];
  m1.s[2]:='Are you sure to use it?';
  m1.s[3]:='(Click on the YES/NO button)';
  showmessage(m1);
  GetMouseState(mm.x,mm.y,sta);
  while sta<>0 do GetMouseState(mm.x,mm.y,sta);
  while sta=0 do GetMouseState(mm.x,mm.y,sta);
  while not (yes_yes(mm) or yes_no(mm)) do
    begin
      while sta<>0 do GetMouseState(mm.x,mm.y,sta);
      while sta=0 do GetMouseState(mm.x,mm.y,sta);
    end;
end;

procedure WaitForCommand1(var mm:rec_a);
var
  sta:longint;
  ch:char;
begin
  if mode=2 then
    begin
      ch:=readkey;ch:=upcase(ch);
      while not(ch in [chr(13),'Y','N',#0]) do
        begin
          ch:=readkey;ch:=upcase(ch);
        end;
      if ch in [#0,'N'] then begin if ch=#0 then ch:=readkey;mm.x:=minx+460;mm.y:=miny+465;exit;end;
      if ch in [chr(13),'Y'] then begin mm.x:=minx+180;mm.y:=miny+465;end;
      exit;
    end;
  GetMouseState(mm.x,mm.y,sta);
  while sta<>0 do GetMouseState(mm.x,mm.y,sta);
  while sta=0 do GetMouseState(mm.x,mm.y,sta);
  while not (yes_yes(mm) or yes_no(mm)) do
    begin
      while sta<>0 do GetMouseState(mm.x,mm.y,sta);
      while sta=0 do GetMouseState(mm.x,mm.y,sta);
    end;
end;

procedure work(kk:longint);
var
  xx,yy,zz,tt,temp,i,j,p,qq:longint;
  m1:rec_st;
  mm:rec_a;
  flag:boolean;
begin
  if not hide[z] then yes_f[z]:=true;
  hello;
  direction:=kk;
  xx:=x+b[kk].x;
  yy:=y+b[kk].y;
  tt:=a[z,xx,yy];
  case tt of
    -4:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[13]);renewitem(13);
         m1.n:=1;
         m1.s[1]:='Got the magic key!';
         showmessage(m1);
       end;
    -3:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[2]);renewitem(2);
         m1.n:=1;
         m1.s[1]:='You''ve found the orb of wisdom.';
         showmessage(m1);
       end;
    -2:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[11]);renewitem(11);
         m1.n:=2;
         m1.s[1]:='You recieved The Dragon Slayer!';
         m1.s[2]:='Your offensive power against the Dragon has doubled!';
         showmessage(m1);
       end;
    0:begin
        change(z,x,y,0);
        change(z,xx,yy,-1);
        x:=xx;y:=yy;
        step:=0;
      end;
    1..3,7..8,23,45,78..84,86:
      begin
        change(z,x,y,-1);
        exit;
      end;
    4:if key1>0 then
        begin
          dec(key1);renewkey1;
          change(z,xx,yy,0);
          change(z,x,y,-1);
          exit;
        end else
          begin
            change(z,x,y,-1);
            m1.n:=1;
            m1.s[1]:='You don''t have a yellow key!';
            showmessage(m1);
            exit;
          end;
    5:if key2>0 then
        begin
          dec(key2);renewkey2;
          change(z,xx,yy,0);
          change(z,x,y,-1);
          exit;
        end else
          begin
            change(z,x,y,-1);
            m1.n:=1;
            m1.s[1]:='You don''t have a blue key!';
            showmessage(m1);
            exit;
          end;
    6:if key3>0 then
        begin
          dec(key3);renewkey3;
          change(z,xx,yy,0);
          change(z,x,y,-1);
          exit;
        end else
          begin
            change(z,x,y,-1);
            m1.n:=1;
            m1.s[1]:='You don''t have a red key!';
            showmessage(m1);
            exit;
          end;
    9:if step<3 then begin
        a[z,x,y]:=0;inc(z);x:=stand[z,1].x;y:=stand[z,1].y;a[z,x,y]:=-1;
        if hide[z] then begin a[z,x,y]:=0;inc(z);x:=stand[z,1].x;y:=stand[z,1].y;a[z,x,y]:=-1;end;
        if not hide[z] then yes_f[z]:=true;
        if stand[z,1].i>0 then direction:=stand[z,1].i;paint_current;renewl;
        if laststep=10 then inc(step) else dec(step);
        if step<0 then step:=0;
        laststep:=9;
      end;
    10:if step<3 then begin
         a[z,x,y]:=0;dec(z);x:=stand[z,2].x;y:=stand[z,2].y;a[z,x,y]:=-1;
         if hide[z] then begin a[z,x,y]:=0;dec(z);x:=stand[z,2].x;y:=stand[z,2].y;a[z,x,y]:=-1;end;
         if stand[z,2].i>0 then direction:=stand[z,2].i;paint_current;renewl;
         if laststep=9 then inc(step) else dec(step);
         if step<0 then step:=0;
         laststep:=10;
       end;
    11:begin
         if price>gold then
           begin
             str(price,m1.s[1]);
             m1.n:=2;
             m1.s[1]:=m1.s[1]+' gold is needed.';
             m1.s[2]:='You don''t have enough money';
             showmessage(m1);
             exit;
           end;
         m1.n:=7;
         m1.s[1]:='Welcome to the altar!';
         str(price,m1.s[2]);m1.s[2]:=m1.s[2]+' gold is needed.';
         m1.s[3]:='Please click on the number button or the NO button';
         str(sa[passmode,z].v*shopnum,m1.s[4]);m1.s[4]:='1----Your vital power is '+m1.s[4]+' points up.';
         str(sa[passmode,z].o,m1.s[5]);m1.s[5]:='2----Your offensive power is '+m1.s[5]+' points up.';
         str(sa[passmode,z].d,m1.s[6]);m1.s[6]:='3----Your defensive power is '+m1.s[6]+' points up.';
         m1.s[7]:='NO----Cancel';
         showmessage(m1);
         WaitForChoice(mm);
         case workn(mm) of
           10:begin
                hello;exit;
              end;
           1:begin
               gold:=gold-price;renewgold;
               vit:=vit+sa[passmode,z].v*shopnum;renewvit;
               m1.n:=1;m1.s[1]:=m1.s[4];
               inc(shopnum);
               showmessage(m1);exit;
             end;
           2:begin
               gold:=gold-price;renewgold;
               off:=off+sa[passmode,z].o;renewoff;
               m1.n:=1;m1.s[1]:=m1.s[5];
               inc(shopnum);
               showmessage(m1);exit;
             end;
           3:begin
               gold:=gold-price;renewgold;
               def:=def+sa[passmode,z].d;renewdef;
               m1.n:=1;m1.s[1]:=m1.s[6];
               inc(shopnum);
               showmessage(m1);exit;
             end;
           -1,0,4..9:begin hello;exit;end;
         end;
       end;
    12:begin
         change(z,xx,yy,0);
         change(z,x,y,-1);
         m1.n:=1;
         m1.s[1]:='The wall collapsed!';
         showmessage(m1);
       end;
    13:begin
         change(z,xx,yy,1);
         change(z,x,y,-1);
       end;
    14:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(key1);renewkey1;
         m1.n:=1;
         m1.s[1]:='You''ve got a yellow key!';
         showmessage(m1);
       end;
    15:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(key2);renewkey2;
         m1.n:=1;
         m1.s[1]:='You''ve got a blue key!';
         showmessage(m1);
       end;
    16:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(key3);renewkey3;
         m1.n:=1;
         m1.s[1]:='You''ve got a red key!';
         showmessage(m1);
       end;
    17:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(off,RB[passmode,z,3]);renewoff;
         m1.n:=2;
         m1.s[1]:='You''ve got a red crystal!';
         str(RB[passmode,z,3],m1.s[2]);
         m1.s[2]:='Your offensive power is '+m1.s[2]+' point(s) up!';
         showmessage(m1);
       end;
    18:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(def,RB[passmode,z,4]);renewdef;
         m1.n:=2;
         m1.s[1]:='You''ve got a blue crystal!';
         str(RB[passmode,z,4],m1.s[2]);
         m1.s[2]:='Your defensive power is '+m1.s[2]+' point(s) up!';
         showmessage(m1);
       end;
    19:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(vit,RB[passmode,z,1]);renewvit;
         m1.n:=2;
         m1.s[1]:='You''ve got a red elixir!';
         str(RB[passmode,z,1],m1.s[2]);
         m1.s[2]:='Your vital power is '+m1.s[2]+' point(s) up!';
         showmessage(m1);
       end;
    20:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(vit,RB[passmode,z,2]);renewvit;
         m1.n:=2;
         m1.s[1]:='You''ve got a blue elixir!';
         str(RB[passmode,z,2],m1.s[2]);
         m1.s[2]:='Your vital power is '+m1.s[2]+' point(s) up!';
         showmessage(m1);
       end;
    21:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[3]);renewitem(3);
         m1.n:=2;
         m1.s[1]:='You''ve found the orb of flying';
         m1.s[2]:='It can only be used near the stairs!';
         showmessage(m1);
       end;
    22:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[12]);renewitem(12);
         m1.n:=2;
         m1.s[1]:='You''ve got the Snow Crystal!';
         m1.s[2]:='It can only be used near the lava!';
         showmessage(m1);
       end;
    24:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[9]);renewitem(9);
         m1.n:=2;
         m1.s[1]:='You''ve got the Wing to fly up!';
         m1.s[2]:='It can only be used once!';
         showmessage(m1);
       end;
    25:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[10]);renewitem(10);
         m1.n:=2;
         m1.s[1]:='You''ve got the Wing to fly down!';
         m1.s[2]:='It can only be used once!';
         showmessage(m1);
       end;
    26:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[8],3);renewitem(8);
         m1.n:=2;
         m1.s[1]:='You recieved the Warp Staff!';
         m1.s[2]:='It can only be used three times!';
         showmessage(m1);
       end;
    27:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[15]);renewitem(15);
         m1.n:=2;
         m1.s[1]:='Got the Luck Gold!';
         m1.s[2]:='You now get twice the normal amount of gold!';
         showmessage(m1);
       end;
    28:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[4]);renewitem(4);
         m1.n:=2;
         m1.s[1]:='Got a Cross!Your offensive power against Vampires';
         m1.s[2]:='and Zombies has doubled!';
         showmessage(m1);
       end;
    29..33:begin
             change(z,x,y,0);
             change(z,xx,yy,-1);
             x:=xx;y:=yy;
             inc(off,wea[passmode,tt-28]);if weapon<tt-28 then weapon:=tt-28;
             renewweapon;renewoff;
             m1.n:=2;
             m1.s[1]:='You''ve got a new weapon!';
             str(wea[passmode,tt-28],m1.s[2]);
             m1.s[2]:='Your offensive power is '+m1.s[2]+' points up!';
             showmessage(m1);
           end;
    34..38:begin
             change(z,x,y,0);
             change(z,xx,yy,-1);
             x:=xx;y:=yy;
             inc(def,shi[passmode,tt-33]);if shield<tt-33 then shield:=tt-33;
             renewshield;renewdef;
             m1.n:=2;
             m1.s[1]:='You''ve got a new shield!';
             str(shi[passmode,tt-33],m1.s[2]);
             m1.s[2]:='Your defensive power is '+m1.s[2]+' points up!';
             showmessage(m1);
           end;
    39:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[6]);renewitem(6);
         m1.n:=3;
         m1.s[1]:='You''ve got the Magic Mattock!';
         m1.s[2]:='Click on the icon to use it';
         m1.s[3]:='It can only be used once!';
         showmessage(m1);
       end;
    40:begin
         change(z,x,y,0);
         change(z,xx,yy,-1);
         x:=xx;y:=yy;
         inc(item[7]);renewitem(7);
         m1.n:=3;
         m1.s[1]:='You''ve got the Destructible Ball!';
         m1.s[2]:='Click on the icon to use it';
         m1.s[3]:='It can only be used once!';
         showmessage(m1);
       end;
    41,42:begin
         for p:=1 to special[z] do
           if (sp[z,p].area.x=xx)and(sp[z,p].area.y=yy) then
             begin
               m1.n:=sp[z,p].Msg1_n;
               for i:=1 to m1.n do m1.s[i]:=sp[z,p].Msg1[i];
               showmessage(m1);
               WaitForCommand1(mm);
               if yes_yes(mm)and(gold>=sp[z,p].Cost) then
                 begin
                   gold:=gold-sp[z,p].Cost;renewgold;
                   for i:=1 to sp[z,p].get_n do
                     case sp[z,p].Get[i].n of
                       1..15:begin
                               inc(item[sp[z,p].Get[i].n],sp[z,p].Get[i].k);
                               renewitem(sp[z,p].Get[i].n);
                             end;
                       16:begin
                            inc(key1,sp[z,p].Get[i].k);
                            renewkey1;
                          end;
                       17:begin
                            inc(key2,sp[z,p].Get[i].k);
                            renewkey2;
                          end;
                       18:begin
                            inc(key3,sp[z,p].Get[i].k);
                            renewkey3;
                          end;
                       19:begin
                            off:=off+trunc(0.03*off);renewoff;
                            def:=def+trunc(0.03*def);renewdef;
                          end;
                       20:begin
                            vit:=vit+RB[passmode,z,1]*sp[z,p].Get[i].k;renewvit;
                          end;
                     end;
                   m1.n:=sp[z,p].Msg2_n;
                   for i:=1 to m1.n do m1.s[i]:=sp[z,p].Msg2[i];
                   if m1.n>0 then
                     begin
                       showmessage(m1);
                       WaitForYes;
                     end;
                   if m1.n>2 then
                     begin
                       for i:=2 to m1.n-1 do rec[z].s[i-1]:=m1.s[i];
                       rec[z].n:=m1.n-2;
                     end;
                   if sp[z,p].K=1 then change(z,xx,yy,0);
                   hello;
                 end;
               hello;
               break;
             end;
       end;
    43,73:begin
         for p:=1 to special[z] do
           if (sp[z,p].area.x=xx)and(sp[z,p].area.y=yy) then
             begin
               m1.n:=sp[z,p].Msg1_n;
               for i:=1 to m1.n do m1.s[i]:=sp[z,p].Msg1[i];
               showmessage(m1);
               WaitForYes;
               for i:=1 to sp[z,p].Act_n do
                 change(sp[z,p].Act[i].z,sp[z,p].Act[i].x,sp[z,p].Act[i].y,sp[z,p].Act[i].i);
               hello;
               break;
             end;
       end;
    98:begin
         for p:=1 to special[z] do
           if (sp[z,p].area.x=xx)and(sp[z,p].area.y=yy) then
             begin
               m1.n:=sp[z,p].Msg1_n;
               for i:=1 to m1.n do m1.s[i]:=sp[z,p].Msg1[i];
               showmessage(m1);
               WaitForYes;
               for i:=1 to 2 do
                 change(sp[z,p].Act[i].z,sp[z,p].Act[i].x,sp[z,p].Act[i].y,sp[z,p].Act[i].i);
               x:=sp[z,p].Act[2].x;
               y:=sp[z,p].Act[2].y;
               z:=sp[z,p].Act[2].z;
               renewl;
               paint_current;
             end;
       end;
    46..72,74..77,85,87..97:
       begin
         zz:=damage(workm(tt));
         if vit>zz then
           begin
             vit:=vit-zz;renewvit;
             temp:=m[passmode,workm(tt)].g;
             if item[15]>0 then temp:=temp*2;
             inc(gold,temp);
             renewgold;
             a[z,xx,yy]:=-1;a[z,x,y]:=0;
             draw(works(a[z,x,y]),workx(y),worky(x));
             tmp[x,y]:=a[z,x,y];
             x:=xx;y:=yy;
             draw(works(a[z,x,y]),workx(y),worky(x));
             tmp[x,y]:=a[z,x,y];
             m1.n:=2;
             m1.s[1]:='You''ve beat '+m[passmode,workm(tt)].s+'.';
             str(temp,m1.s[2]);
             m1.s[2]:='Received '+m1.s[2]+' Gold.';
             showmessage(m1);
           end
           else
             begin
               draw(works(a[z,x,y]),workx(y),worky(x));
               tmp[x,y]:=a[z,x,y];
               m1.n:=1;
               m1.s[1]:='Can''t be hit by you!';
               showmessage(m1);
               exit;
             end;
       end;
    else begin draw(works(a[z,x,y]),workx(y),worky(x));tmp[x,y]:=a[z,x,y];exit;end;
  end;
  for j:=1 to special[z] do
    if sp[z,j].Switch then
      case sp[z,j].K of{1,2,4崔噐寄case椎戦侃尖}
        0:begin
            flag:=true;
            for p:=1 to sp[z,j].Req_n do
              if not yes_check(z,sp[z,j].Req[p].x,sp[z,j].Req[p].y,sp[z,j].Req[p].i) then flag:=false;
            if not flag then continue;
            m1.n:=sp[z,j].Msg1_n;
            for i:=1 to m1.n do m1.s[i]:=sp[z,j].Msg1[i];
            if m1.n>0 then
              begin
                showmessage(m1);
                WaitForYes;
                hello;
              end;
            for p:=1 to sp[z,j].Act_n do
              change(z,sp[z,j].Act[p].x,sp[z,j].Act[p].y,sp[z,j].Act[p].i);
            sp[z,j].Switch:=false;
          end;
        3:if (x=sp[z,j].area.x)and(y=sp[z,j].area.y) then
          begin
            sp[z,j].Switch:=false;
            change(z,x-2,y,44);
            m1.n:=sp[z,j].Msg1_n;
            for p:=1 to m1.n do
              m1.s[p]:=sp[z,j].Msg1[p];
            showmessage(m1);
            WaitForYes;
            change(z,x-1,y,89);
            change(z,x+1,y,89);
            change(z,x,y-1,89);
            change(z,x,y+1,89);
            m1.n:=2;
            m1.s[1]:='You are hit!';
            m1.s[2]:='Click on the YES button';
            showmessage(m1);
            WaitForYes;
            change(z,x-2,y,0);
            change(z,x-1,y,0);
            change(z,x+1,y,0);
            change(z,x,y-1,0);
            change(z,x,y+1,0);
            change(z,x,y,0);
            change(2,8,3,-1);
            z:=2;x:=8;y:=3;weapon:=0;shield:=0;
            if passmode=1 then begin vit:=400;off:=10;def:=10;end;
            paint_current;
            renewvit;renewoff;renewdef;renewweapon;renewshield;
            hello;
            break;
          end;
        5:if (x=sp[z,j].area.x)and(y=sp[z,j].area.y) then
          begin
            m1.n:=sp[z,j].Msg1_n;
            for p:=1 to m1.n do m1.s[p]:=sp[z,j].Msg1[p];
            showmessage(m1);
            WaitForYes;
            change(z,x-2,y,97);
            sp[z,j].Switch:=false;
          end;
        6:begin
            flag:=false;
            case sp[z,j].kind of
              1:if (abs(x-sp[z,j].x)+abs(y-sp[z,j].y)=1)and(a[z,sp[z,j].x,sp[z,j].y] in [88..90]) 
                  then
                    begin
                      if shield<5 then
                        case passmode of
                          1:vit:=vit-sp[z,j].d1;
                          2:vit:=vit-sp[z,j].d1*44;
                          3:vit:=vit-sp[z,j].d1*44*44;
                        end;
                      flag:=true;
                    end;
              2:if (x*2=sp[z,j].x+sp[z,j].x1)and(y*2=sp[z,j].y+sp[z,j].y1) then
                 if yes_check(z,sp[z,j].x,sp[z,j].y,89)and yes_check(z,sp[z,j].x1,sp[z,j].y1,89) then
                  begin
                    if shield<5 then vit:=vit*sp[z,j].d1 div sp[z,j].d2;
                    flag:=true;
                  end;
            end;
            if not flag then continue;
            if (x=sp[z,j].x+sp[z,j].dx)and(y=sp[z,j].y+sp[z,j].dy) then
              begin
                sp[z,j].dx:=-sp[z,j].dx;
                sp[z,j].dy:=-sp[z,j].dy;
              end;
            if sp[z,j].move and (a[z,sp[z,j].x+sp[z,j].dx,sp[z,j].y+sp[z,j].dy]=0) then
             if a[z,sp[z,j].x-sp[z,j].dx,sp[z,j].y-sp[z,j].dy]=-1 then
              begin
                qq:=a[z,sp[z,j].x,sp[z,j].y];
                change(z,sp[z,j].x,sp[z,j].y,0);
                sp[z,j].x:=sp[z,j].x+sp[z,j].dx;
                sp[z,j].y:=sp[z,j].y+sp[z,j].dy;
                change(z,sp[z,j].x,sp[z,j].y,qq);
              end;
            renewvit;
            if flag and (shield<5) then
              begin
                m1.n:=1;
                m1.s[1]:='You are hit by the Magician!';
                showmessage(m1);
              end;
          end;
        7:if (x=sp[z,j].area.x)and(y=sp[z,j].area.y) then
          begin
            flag:=true;
            for p:=1 to sp[z,j].Req_n do
              if not yes_check(z,sp[z,j].Req[p].x,sp[z,j].Req[p].y,sp[z,j].Req[p].i) then flag:=false;
            if not flag then continue;
            m1.n:=sp[z,j].Msg1_n;
            for p:=1 to m1.n do m1.s[p]:=sp[z,j].Msg1[p];
            score:=10*vit+500*def+1000*off+gold+100*key1+200*key2+500*key3;
            str(score,s);
            m1.s[2]:=m1.s[2]+' '+s+' points.';
            while textwidth(m1.s[2])<textwidth(m1.s[1]) do m1.s[2]:=m1.s[2]+' ';
            showmessage(m1);
            WaitForYes;
            if passmode<3 then
              begin
                inc(passmode);
                loadmap;
                fillchar(yes_f,sizeof(yes_f),0);
                fillchar(item,sizeof(item),0);
                paint_current;
                renewall;
                shopnum:=1;
              end
                else
                  begin
                    donemouse;closegraph;halt;
                  end;
          end;
      end;
end;{work}

procedure work1;
var
  i,j,pp,qq,k,num1,num2,p:longint;
  ch:char;
  mo,mm:rec_a;
  sta:longint;
  m1:rec_st;
  flag:boolean;
begin
  paint_current;
  renewall;
  while true do
    begin
      if vit<=0 then fail;
      if keypressed then
        begin
          ch:=readkey;
          if ch=#0 then
            begin
              ch:=readkey;
              case ch of
                #72:work(1);
                #80:work(2);
                #75:work(3);
                #77:work(4);
              end;
              continue;
            end;
          ch:=upcase(ch);
          case ch of
            'M':begin
                  mode:=3-mode;
                  hello;
                  renewcommand;
                  showchoice;
                end;
            'Z':begin
                  direction:=next[direction];
                  change(z,x,y,-1);
                  step:=0;
                end;
          end;
          if mode=1 then continue;
          case ch of
            'S':begin
                  m1.n:=2;
                  m1.s[1]:='Input the first number:';
                  m1.s[2]:='Press N or arrow keys to cancel';
                  showmessage(m1);
                  ch:=readkey;
                  ch:=upcase(ch);
                  while not(ch in ['0'..'9',#0,'N']) do
                    begin
                      ch:=readkey;
                      ch:=upcase(ch);
                    end;
                  if (ch=#0) or (ch='N') then begin hello;continue;end;
                  m1.n:=2;
                  m1.s[1]:='The first number is '+ch+',please input the second number:';
                  m1.s[2]:='Press N or arrow keys to cancel';
                  showmessage(m1);
                  num1:=ord(ch)-ord('0');
                  ch:=' ';
                  while not(ch in ['0'..'9',#0,'N']) do
                    begin
                      ch:=readkey;
                      ch:=upcase(ch);
                    end;
                  if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                  num2:=ord(ch)-ord('0');
                  save(num1*10+num2);
                  m1.n:=1;
                  m1.s[1]:='Saved successfully!';
                  showmessage(m1);
                end;{S}
            'L':begin
                  m1.n:=2;
                  m1.s[1]:='Input the first number:';
                  m1.s[2]:='Press N or arrow keys to cancel';
                  showmessage(m1);
                  ch:=readkey;
                  ch:=upcase(ch);
                  while not(ch in ['0'..'9',#0,'N']) do
                    begin
                      ch:=readkey;
                      ch:=upcase(ch);
                    end;
                  if (ch=#0) or (ch='N') then begin hello;continue;end;
                  m1.n:=2;
                  m1.s[1]:='The first number is '+ch+',please input the second number:';
                  m1.s[2]:='Press N or arrow keys to cancel';
                  showmessage(m1);
                  num1:=ord(ch)-ord('0');
                  ch:=' ';
                  while not(ch in ['0'..'9',#0,'N']) do
                    begin
                      ch:=readkey;
                      ch:=upcase(ch);
                    end;
                  if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                  num2:=ord(ch)-ord('0');
                  load(num1*10+num2);
                  m1.n:=1;
                  m1.s[1]:='Loaded successfully!';
                  showmessage(m1);
                end;
            'Q':begin
                  m1.n:=2;
                  m1.s[1]:='Are you sure to quit?';
                  m1.s[2]:='Press Y/N';
                  showmessage(m1);
                  WaitForCommand1(mm);
                  if yes_yes(mm) then
                    begin
                      donemouse;
                      closegraph;
                      halt;
                    end;
                  if yes_no(mm) then hello;
                end;
            'X':begin
                  m1.n:=7;
                  m1.s[1]:=name[it];
                  m1.s[2]:='Arrows:Choose,Y:Use,N:quit';
                  num[it]:=items(it,1);
                  for i:=3 to 7 do m1.s[i]:='';
                  for i:=1 to 15 do
                    m1.s[(i-1) div 3+3]:=m1.s[(i-1) div 3+3]+num[i];
                  showmessage(m1);
                  num[it]:=items(it,0);
                  ch:=readkey;
                  while not (ch in [#0,chr(13),'y','n','Y','N']) do ch:=readkey;
                  while ch=#0 do
                    begin
                      ch:=readkey;
                      case ch of
                        #72:if it>3 then it:=it-3;
                        #80:if it<13 then it:=it+3;
                        #75:if it mod 3<>1 then dec(it); 
                        #77:if it mod 3<>0 then inc(it);
                      end;
                      num[it]:=items(it,1);
                      m1.s[1]:=name[it];
                      for i:=3 to 7 do m1.s[i]:='';
                      for i:=1 to 15 do
                        m1.s[(i-1) div 3+3]:=m1.s[(i-1) div 3+3]+num[i];
                      showmessage(m1);
                      num[it]:=items(it,0);
                      ch:=readkey;while not (ch in [#0,chr(13),'y','n','Y','N']) do ch:=readkey;
                    end;
                  case ch of
                    'n','N':hello;
                    chr(13),'y','Y':if item[it]>0 then
                       begin
                         case it of
                           1:begin
                               m1.n:=2;
                               m1.s[1]:=name[1];
                               m1.s[2]:='Click on the monster to use it';
                               showmessage(m1);
                             end;
                           2:begin
                               m1.n:=2;
                               m1.s[1]:='Input the first number:';
                               m1.s[2]:='Press N or arrow keys to cancel';
                               showmessage(m1);
                               ch:=readkey;
                               ch:=upcase(ch);
                               while not(ch in ['0'..'9',#0,'N']) do
                                 begin
                                   ch:=readkey;
                                   ch:=upcase(ch);
                                 end;
                               if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                               m1.n:=2;
                               m1.s[1]:='The first number is '+ch+',please input the second number:';
                               m1.s[2]:='Press N or arrow keys to cancel';
                               showmessage(m1);
                               num1:=ord(ch)-ord('0');
                               ch:=' ';
                               while not(ch in ['0'..'9',#0,'N']) do
                                 begin
                                   ch:=readkey;
                                   ch:=upcase(ch);
                                 end;
                               if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                               num2:=ord(ch)-ord('0');
                               showmessage(rec[num1*10+num2]);
                             end;{2}
                           3:for i:=1 to 4 do if a[z,x+b[i].x,y+b[i].y] in [9,10] then
                             begin
                               m1.n:=2;
                               m1.s[1]:='Input the first number:';
                               m1.s[2]:='Press N or arrow keys to cancel';
                               showmessage(m1);
                               ch:=readkey;
                               ch:=upcase(ch);
                               while not(ch in ['0'..'9',#0,'N']) do
                                 begin
                                   ch:=readkey;
                                   ch:=upcase(ch);
                                 end;
                               if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                               m1.n:=2;
                               m1.s[1]:='The first number is '+ch+',please input the second number:';
                               m1.s[2]:='Press N or arrow keys to cancel';
                               showmessage(m1);
                               num1:=ord(ch)-ord('0');
                               ch:=' ';
                               while not(ch in ['0'..'9',#0,'N']) do
                                 begin
                                   ch:=readkey;
                                   ch:=upcase(ch);
                                 end;
                               if (ch=#0) or (ch='N') then begin if ch=#0 then ch:=readkey;hello;continue;end;
                               num2:=ord(ch)-ord('0');
                               qq:=num1*10+num2;
                               if yes_f[qq] then
                                 begin
                                   if z=qq then begin hello;break;end;
                                   if z<qq then pp:=1;
                                   if z>qq then pp:=2;
                                   change(z,x,y,0);
                                   z:=qq;
                                   x:=stand[z,pp].x;
                                   y:=stand[z,pp].y;
                                   direction:=stand[z,pp].i;
                                   change(z,x,y,-1);
                                   paint_current;
                                   hello;
                                 end else hello;
                               break;
                             end;{3}
                           4:begin
                               m1.n:=1;
                               m1.s[1]:=name[4];
                               showmessage(m1);
                             end;{4}
                           5:begin
                               WaitForCommand(mm,5);
                               if yes_yes(mm) then
                                 begin
                                   qq:=10*off+5*def;
                                   vit:=vit+qq;
                                   renewvit;
                                   m1.n:=1;
                                   str(qq,m1.s[1]);
                                   m1.s[1]:='Your vital power is '+m1.s[1]+' points up!';
                                   showmessage(m1);
                                   dec(item[5]);renewitem(5);
                                 end
                                   else hello;
                             end;{5}
                           6:begin
                               WaitForCommand(mm,6);
                               if yes_yes(mm) then
                                 begin
                                   for i:=1 to 4 do if a[z,x+b[i].x,y+b[i].y]=1 then change(z,x+b[i].x,y+b[i].y,0);
                                   dec(item[6]);renewitem(6);
                                   m1.n:=1;
                                   m1.s[1]:='You used the Magic Mattock!The walls fell down!';
                                   showmessage(m1);
                                 end
                                   else hello;
                             end;{6}
                           7:begin
                               WaitForCommand(mm,7);
                               if yes_yes(mm) then
                                 begin
                                   pp:=0;
                                   for p:=1 to 4 do
                                   if a[z,x+b[p].x,y+b[p].y] in [46..61,71,74..77,87..94] then
                                     begin
                                       qq:=a[z,x+b[p].x,y+b[p].y];
                                       qq:=m[passmode,workm(qq)].g;
                                       pp:=pp+qq;
                                       change(z,x+b[p].x,y+b[p].y,0);
                                     end;
                                   dec(item[7]);renewitem(7);
                                   m1.n:=2;
                                   m1.s[1]:='You used the Destructible Ball!Enemies on all sides died!';
                                   str(pp,m1.s[2]);m1.s[2]:='Received '+m1.s[2]+' gold.';
                                   showmessage(m1);
                                   gold:=gold+pp;renewgold;
                                 end
                                   else hello;
                             end;{7}
                           8:begin
                               WaitForCommand(mm,8);
                               if yes_yes(mm) then
                                 if yes_check(z,12-x,12-y,0) then
                                   begin
                                     change(z,x,y,0);
                                     change(z,12-x,12-y,-1);
                                     x:=12-x;y:=12-y;
                                     m1.n:=1;
                                     m1.s[1]:='You''ve warped!';
                                     showmessage(m1);
                                     dec(item[8]);renewitem(8);
                                   end
                                     else
                                       begin
                                         m1.n:=1;
                                         m1.s[1]:='You cannot warp(There''s an object in the way).';
                                         showmessage(m1);
                                       end;
                               if yes_no(mm) then hello;
                             end;{8}
                           9:begin
                               WaitForCommand(mm,9);
                               if yes_yes(mm) then
                                 if yes_check(z+1,x,y,0) then
                                   begin
                                     change(z,x,y,0);
                                     inc(z);renewl;paint_current;
                                     change(z,x,y,-1);
                                     dec(item[9]);renewitem(9);
                                     m1.n:=1;
                                     m1.s[1]:='You''ve used the wing to fly up!';
                                     showmessage(m1);
                                   end
                                     else
                                       begin
                                         m1.n:=1;
                                         m1.s[1]:='Can''t go upstairs(it''s blocked)!';
                                         showmessage(m1);
                                       end;
                               if yes_no(mm) then hello;
                             end;{9}
                          10:begin
                               WaitForCommand(mm,10);
                               if yes_yes(mm) then
                                 if yes_check(z-1,x,y,0) then
                                   begin
                                     change(z,x,y,0);
                                     dec(z);renewl;paint_current;
                                     change(z,x,y,-1);
                                     dec(item[10]);renewitem(10);
                                     m1.n:=1;
                                     m1.s[1]:='You''ve used the wing to fly down!';
                                     showmessage(m1);
                                   end
                                     else
                                       begin
                                         m1.n:=1;
                                         m1.s[1]:='Can''t go downstairs(it''s blocked)!';
                                         showmessage(m1);
                                       end;
                               if yes_no(mm) then hello;
                             end;{10}
                          11:begin
                               m1.n:=1;
                               m1.s[1]:=name[11];
                               showmessage(m1);
                             end;{11}
                          12:begin
                               for p:=1 to 4 do if yes_check(z,x+b[p].x,y+b[p].y,23) then
                               change(z,x+b[p].x,y+b[p].y,0);
                               m1.n:=1;
                               m1.s[1]:='You''ve used the snow crystal!';
                               showmessage(m1);
                             end;{12}
                          13:begin
                               WaitForCommand(mm,13);
                               if yes_yes(mm) then
                                 begin
                                   for i:=1 to 11 do
                                     for j:=1 to 11 do
                                       if a[z,i,j]=4 then change(z,i,j,0);
                                   dec(item[13]);renewitem(13);
                                   m1.n:=2;
                                   m1.s[1]:='Your''ve used the magic key!';
                                   m1.s[2]:='All these doors opened on this floor.';
                                   showmessage(m1);
                                 end
                                   else hello;
                             end;{13}
                          14:begin
                               WaitForCommand(mm,14);
                               if yes_yes(mm) then
                                 begin
                                   for i:=1 to 11 do
                                     for j:=1 to 11 do
                                       if a[z,i,j]=1 then change(z,i,j,0);
                                   dec(item[14]);renewitem(14);
                                   m1.n:=2;
                                   m1.s[1]:='Your''ve used a Super Magic Mattock!';
                                   m1.s[2]:='All the walls fell down on this floor!';
                                   showmessage(m1);
                                 end
                                   else hello;
                             end;{14}
                          15:begin
                               m1.n:=1;
                               m1.s[1]:=name[11];
                               showmessage(m1);
                             end;{15}
                         end;{case}
                       end
                         else begin
                                m1.n:=1;m1.s[1]:='Unable';showmessage(m1);
                              end;
                  end;
                end;
          end;
          continue;
        end;
   if mode=1 then begin
      GetMouseState(mo.x,mo.y,sta);
      if sta<>0 then
        begin
          if yes_menu(mo) then
            begin
              m1.n:=4;
              m1.s[1]:='1----Save game';
              m1.s[2]:='2----Load game';
              m1.s[3]:='3----Quit game';
              m1.s[4]:='NO---Cancel';
              showmessage(m1);
              mm:=mo;
              while not(workn(mm) in [1..3,10]) do
                 begin
                   while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                 end;
             case workn(mm) of
               10:begin
                    hello;
                    continue;
                  end;
               1:begin
                   m1.n:=2;
                   m1.s[1]:='Click on the number buttons to choose the first number:';
                   m1.s[2]:='Click on NO to cancel';
                   showmessage(m1);
                   while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                   while workn(mm)=-1 do
                     begin
                       while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                       while sta=0 do GetMouseState(mm.x,mm.y,sta);
                     end;
                   if workn(mm)=10 then
                     begin
                       while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                       hello;
                       continue;
                     end;
                   num1:=workn(mm);
                   str(num1,m1.s[1]);
                   m1.s[1]:='The First number is '+m1.s[1]+'.';
                   m1.s[2]:='Please choose the second number:';
                   m1.s[3]:='Click on NO to cancel';
                   m1.n:=3;showmessage(m1);
                   while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                   while workn(mm)=-1 do
                     begin
                       while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                       while sta=0 do GetMouseState(mm.x,mm.y,sta);
                     end;
                   if workn(mm)=10 then
                     begin
                       while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                       hello;
                       continue;
                     end;
                   num2:=workn(mm);
                   save(num1*10+num2);
                   m1.n:=1;
                   m1.s[1]:='Saved successfully!';
                   showmessage(m1);
                end;
               2:begin
                   m1.n:=2;
                   m1.s[1]:='Click on the number buttons to choose the first number:';
                   m1.s[2]:='Click on NO to cancel';
                   showmessage(m1);
                   while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                   while workn(mm)=-1 do
                     begin
                       while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                       while sta=0 do GetMouseState(mm.x,mm.y,sta);
                     end;
                   if workn(mm)=10 then
                     begin
                       while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                       hello;
                       continue;
                     end;
                   num1:=workn(mm);
                   str(num1,m1.s[1]);
                   m1.s[1]:='The First number is '+m1.s[1]+'.';
                   m1.s[2]:='Please choose the second number:';
                   m1.s[3]:='Click on NO to cancel';
                   m1.n:=3;showmessage(m1);
                   while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                   while workn(mm)=-1 do
                     begin
                       while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                       while sta=0 do GetMouseState(mm.x,mm.y,sta);
                     end;
                   if workn(mm)=10 then
                     begin
                       while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                       hello;
                       continue;
                     end;
                   num2:=workn(mm);
                   load(num1*10+num2);
                   m1.n:=1;
                   m1.s[1]:='Loaded successfully!';
                   showmessage(m1);
                end;
               3:begin
                   m1.n:=2;
                   m1.s[1]:='Are you sure to quit this game?';
                   m1.s[2]:='Click on the YES/NO button to continue/quit';
                   showmessage(m1);
                   while sta=0 do GetMouseState(mm.x,mm.y,sta);
                   while not(yes_yes(mm)or yes_no(mm)) do
                     begin
                       while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                       while sta=0 do GetMouseState(mm.x,mm.y,sta);
                     end;
                   if yes_no(mm) then
                     begin
                       hello;
                       continue;
                     end;
                   if yes_yes(mm) then
                     begin
                       closegraph;
                       donemouse;
                       halt;
                     end;
                 end;
              end;
            end;           
          if (minx+44<=mo.x)and(mo.x<=minx+495)and(miny+25<=mo.y)and(mo.y<=miny+375)and(item[1]>0) then
            begin
              pp:=a[z,workc(mo).y,workc(mo).x];
              if pp in [46..72,74..77,85,87..97] then renewm(workm(pp));
            end;
          if (worki(1).x<=mo.x)and(mo.x<=worki(3).x+31)and(worki(1).y<=mo.y)and(mo.y<=worki(15).y+31) then
            begin
              for k:=1 to 15 do
                if (worki(k).x<=mo.x)and(mo.x<=worki(k).x+31)and(worki(k).y<=mo.y)and(mo.y<=worki(k).y+31) then break;
              if item[k]>0 then
              case k of
                1:begin
                    m1.n:=2;
                    m1.s[1]:=name[1];
                    m1.s[2]:='Click on the monster to use it';
                    showmessage(m1);
                  end;
                2:begin
                    m1.n:=3;
                    m1.s[1]:=name[2];
                    m1.s[2]:='Click on the number buttons to choose the first number:';
                    m1.s[3]:='Click on NO to cancel';
                    showmessage(m1);
                    while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                    while sta=0 do GetMouseState(mm.x,mm.y,sta);
                    while workn(mm)=-1 do
                      begin
                        while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                        while sta=0 do GetMouseState(mm.x,mm.y,sta);
                      end;
                    if workn(mm)=10 then
                      begin
                        while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                        hello;
                        continue;
                      end;
                    num1:=workn(mm);
                    str(num1,m1.s[1]);
                    m1.s[1]:='The First number is '+m1.s[1]+'.';
                    m1.s[2]:='Please choose the second number:';
                    m1.s[3]:='Click on NO to cancel';
                    m1.n:=3;showmessage(m1);
                    while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                    while sta=0 do GetMouseState(mm.x,mm.y,sta);
                    while workn(mm)=-1 do
                      begin
                        while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                        while sta=0 do GetMouseState(mm.x,mm.y,sta);
                      end;
                    if workn(mm)=10 then
                      begin
                        while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                        hello;
                        continue;
                      end;
                    num2:=workn(mm);
                    showmessage(rec[num1*10+num2]);
                  end;{2--message recorder}
                3:begin
                    flag:=false;
                    for p:=1 to 4 do if a[z,x+b[p].x,y+b[p].y] in [9..10] then
                      begin
                        m1.n:=3;
                        m1.s[1]:=name[3];
                        m1.s[2]:='Click on the number buttons to choose the first number:';
                        m1.s[3]:='Click on NO to cancel';
                        showmessage(m1);
                        while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                        while sta=0 do GetMouseState(mm.x,mm.y,sta);
                        while workn(mm)=-1 do
                          begin
                            while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                            while sta=0 do GetMouseState(mm.x,mm.y,sta);
                          end;
                        if workn(mm)=10 then
                          begin
                            while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                            hello;
                            continue;
                          end;
                        num1:=workn(mm);
                        str(num1,m1.s[1]);
                        m1.s[1]:='The First number is '+m1.s[1]+'.';
                        m1.s[2]:='Please choose the second number:';
                        m1.s[3]:='Click on NO to cancel';
                        m1.n:=3;showmessage(m1);
                        while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                        while sta=0 do GetMouseState(mm.x,mm.y,sta);
                        while workn(mm)=-1 do
                          begin
                            while sta<>0 do GetMouseState(mm.x,mm.y,sta);
                            while sta=0 do GetMouseState(mm.x,mm.y,sta);
                          end;
                        if workn(mm)=10 then
                          begin
                            while sta<>0 do GetMouseState(mo.x,mo.y,sta);
                            hello;
                            continue;
                          end;
                        num2:=workn(mm);
                        qq:=num1*10+num2;
                        if yes_f[qq] then
                          begin
                            if z=qq then begin hello;break;end;
                            if z<qq then pp:=1;
                            if z>qq then pp:=2;
                            change(z,x,y,0);
                            z:=qq;
                            x:=stand[z,pp].x;
                            y:=stand[z,pp].y;
                            direction:=stand[z,pp].i;
                            change(z,x,y,-1);
                            paint_current;
                            flag:=true;
                          end;
                        break;
                      end;
                    if not flag then
                      begin
                        m1.n:=1;
                        m1.s[1]:='Unable!';
                        showmessage(m1);
                      end;
                    if flag then
                      begin
                        m1.n:=1;
                        m1.s[1]:='You are flew by the orb of flying!';
                        showmessage(m1);
                      end;
                  end;{3}
                4:begin
                    m1.n:=1;
                    m1.s[1]:=name[4];
                    showmessage(m1);
                  end;
                5:begin
                    WaitForCommand(mm,5);
                    if yes_yes(mm) then
                      begin
                        qq:=10*off+5*def;
                        vit:=vit+qq;
                        renewvit;
                        m1.n:=1;
                        str(qq,m1.s[1]);
                        m1.s[1]:='Your vital power is '+m1.s[1]+' points up!';
                        showmessage(m1);
                        dec(item[5]);renewitem(5);
                      end
                        else hello;
                  end;
                6:begin
                    WaitForCommand(mm,6);
                    if yes_yes(mm) then
                      begin
                        for p:=1 to 4 do
                          if a[z,x+b[p].x,y+b[p].y]=1 then change(z,x+b[p].x,y+b[p].y,0);
                        dec(item[6]);renewitem(6);
                        m1.n:=1;
                        m1.s[1]:='You used the Magic Mattock!The walls fell down!';
                        showmessage(m1);
                      end
                        else hello;
                  end;{6}
                7:begin
                    WaitForCommand(mm,7);
                    if yes_yes(mm) then
                      begin
                        pp:=0;
                        for p:=1 to 4 do
                          if a[z,x+b[p].x,y+b[p].y] in [46..61,71,74..77,87..94] then
                            begin
                              qq:=a[z,x+b[p].x,y+b[p].y];
                              qq:=m[passmode,workm(qq)].g;
                              pp:=pp+qq;
                              change(z,x+b[p].x,y+b[p].y,0);
                            end;
                        dec(item[7]);renewitem(7);
                        m1.n:=2;
                        m1.s[1]:='You used the Destructible Ball!Enemies on all sides died!';
                        str(pp,m1.s[2]);m1.s[2]:='Received '+m1.s[2]+' gold.';
                        showmessage(m1);
                        gold:=gold+pp;renewgold;
                      end
                      else hello;
                  end;{7}
                8:begin
                    WaitForCommand(mm,8);
                    if yes_yes(mm) then
                      if yes_check(z,12-x,12-y,0) then
                        begin
                          change(z,x,y,0);
                          change(z,12-x,12-y,-1);
                          x:=12-x;y:=12-y;
                          m1.n:=1;
                          m1.s[1]:='You''ve warped!';
                          showmessage(m1);
                          dec(item[8]);renewitem(8);
                        end
                          else
                            begin
                              m1.n:=1;
                              m1.s[1]:='You cannot warp(There''s an object in the way).';
                              showmessage(m1);
                            end;
                    if yes_no(mm) then hello;
                  end;{8}
                9:begin
                    WaitForCommand(mm,9);
                    if yes_yes(mm) then
                      if yes_check(z+1,x,y,0) then
                        begin
                          change(z,x,y,0);
                          inc(z);renewl;paint_current;
                          change(z,x,y,-1);
                          dec(item[9]);renewitem(9);
                          m1.n:=1;
                          m1.s[1]:='You''ve used the wing to fly up!';
                          showmessage(m1);
                        end
                          else
                            begin
                              m1.n:=1;
                              m1.s[1]:='Can''t go upstairs(it''s blocked)!';
                              showmessage(m1);
                            end;
                    if yes_no(mm) then hello;
                  end;{9}
                10:begin
                     WaitForCommand(mm,10);
                     if yes_yes(mm) then
                       if yes_check(z-1,x,y,0) then
                         begin
                           change(z,x,y,0);
                           dec(z);renewl;paint_current;
                           change(z,x,y,-1);
                           dec(item[10]);renewitem(10);
                           m1.n:=1;
                           m1.s[1]:='You''ve used the wing to fly down!';
                           showmessage(m1);
                         end
                           else
                             begin
                               m1.n:=1;
                               m1.s[1]:='Can''t go downstairs(it''s blocked)!';
                               showmessage(m1);
                             end;
                     if yes_no(mm) then hello;
                   end;
                11:begin
                     m1.n:=1;
                     m1.s[1]:=name[11];
                     showmessage(m1);
                   end;
                12:begin
                     for p:=1 to 4 do if yes_check(z,x+b[p].x,y+b[p].y,23) then
                       change(z,x+b[p].x,y+b[p].y,0);
                     m1.n:=1;
                     m1.s[1]:='You''ve used the snow crystal!';
                     showmessage(m1);
                   end;
                13:begin
                     WaitForCommand(mm,13);
                     if yes_yes(mm) then
                       begin
                         for i:=1 to 11 do
                           for j:=1 to 11 do
                             if a[z,i,j]=4 then change(z,i,j,0);
                         dec(item[13]);renewitem(13);
                         m1.n:=2;
                         m1.s[1]:='Your''ve used the magic key!';
                         m1.s[2]:='All these doors opened on this floor.';
                         showmessage(m1);
                       end
                         else hello;
                   end;
                14:begin
                     WaitForCommand(mm,14);
                     if yes_yes(mm) then
                       begin
                         for i:=1 to 11 do
                           for j:=1 to 11 do
                             if a[z,i,j]=1 then change(z,i,j,0);
                         dec(item[14]);renewitem(14);
                         m1.n:=2;
                         m1.s[1]:='Your''ve used a Super Magic Mattock!';
                         m1.s[2]:='All the walls fell down on this floor!';
                         showmessage(m1);
                       end
                         else hello;
                   end;
                15:begin
                     m1.n:=1;
                     m1.s[1]:=name[11];
                     showmessage(m1);
                   end;
              end;
            end;
          while sta<>0 do GetMouseState(mo.x,mo.y,sta);
        end;
     end;
      if mode=2 then
        begin
          GetMouseState(mo.x,mo.y,sta);
          if sta=0 then continue;
          if (minx+44<=mo.x)and(mo.x<=minx+495)and(miny+25<=mo.y)and(mo.y<=miny+375)and(item[1]>0) then
            begin
              pp:=a[z,workc(mo).y,workc(mo).x];
              if pp in [46..72,74..77,85,87..97] then renewm(workm(pp));
            end;
          while sta<>0 do GetMouseState(mo.x,mo.y,sta);
        end;
    end;
  closegraph;
  donemouse;
end;{work1}

begin
  init;
  loadmap;
  work1;
end.