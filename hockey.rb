require'zlib'

def show s
  puts s.delete("|").lines.map{|a|'0b'+a.delete("\n").tr(' ','0').tr('#','1').to_i(2).to_s(2)+','}
end
show %[|    #########    |
|   ##  # #  ##   |
|  # # #   # # #  |
| #   #     #   # |
|#################|
| #   #     #   # |
|  #  #     #  #  |
|   #  #   #  #   |
|    # #   # #    |
|     # # # #     |
|      ## ##      |
|       ###       |
|        #        |
]


show %[
|   #     ###  ####
|  # #     #   #   #
|  # #     #   #   #
| #   #    #   #   #
| #####    #   ####
| #   #    #   #  #
|#     #   #   #  #
|#     #   #   #   #
|#     #  ###  #   #
]


show %[
|#   #   ###    ###   #   #  #####  #   #
|#   #  #   #  #   #  #   #  #      #   #
|#   #  #   #  #   #  #  #   #       # #
|#   #  #   #  #      # #    #       # #
|#####  #   #  #      ##     #####    #
|#   #  #   #  #      # #    #        #
|#   #  #   #  #   #  #  #   #        #
|#   #  #   #  #   #  #   #  #        #
|#   #   ###    ###   #   #  #####    #
]

$C=File.read(__FILE__).split(/#B[E]GIN/)[1].split(/#E[N]D/)[0].gsub(/^ +/, '')
def initial_k
  w=400
  h=560
  a=[200,280,40,-100,200,0,200,0]
  a.each_with_index.map{|v,i|(w+v)*(2*h)**i}.sum
end
if $C[/\d+/]!=initial_k.to_s
  puts initial_k
  exit
end
#BEGIN
k=885457562454749327098200
require'io/console'
require'socket'
require'json'
w=400
h=560
dec=->k{k.digits(2*h).map{|a|a-w}}
enc=->*a{a.each_with_index.sum{|v,i|(w+v)*(2*h)**i}}
m1=0
m2=0
m=0
r=40
pl=40
msg=nil
shp=[0,0b1111111110000,
0b11001010011000,
0b101010001010100,
0b1000100000100010,
0b11111111111111111,
0b1000100000100010,
0b100100000100100,
0b10010001001000,
0b1010001010000,
0b101010100000,
0b11011000000,
0b1110000000,
0b100000000]
shpa=[0,
0b111100111000001000,
0b1000100010000010100,
0b1000100010000010100,
0b1000100010000100010,
0b111100010000111110,
0b100100010000100010,
0b100100010001000001,
0b1000100010001000001,
0b1000100111001000001]

shpb=[0,
0b1000100111110010001000111000011100010001,
0b1000100000010010001001000100100010010001,
0b101000000010001001001000100100010010001,
0b101000000010000101000000100100010010001,
0b10000111110000011000000100100010011111,
0b10000000010000101000000100100010010001,
0b10000000010001001001000100100010010001,
0b10000000010010001001000100100010010001,
0b10000111110010001000111000011100010001]

rndr=->k{
  bx,by,vx,vy,b1,p1,b2,p2=dec[k]
  by1=h-r*3/2-pl*(p1>0?1:0)
  by2=r*3/2+pl*(p2>0?1:0)
  $C[/\d+/]=k.to_s
  cs=[Zlib.deflate($C)].pack(?m).delete("\n=").chars
  cs+=[?(]+cs
  l=(0...44).map{|iy|
    (0...64).map{|ix|
      %[ .,':;"!][8-(0..1).sum{|j|
        yj=2*iy+j
        ((0..3).count{|k|
          x=(ix+k/2*0.5)*w/64
          y=(yj+k%2*0.5)*h/44/2
          l=(x-bx)**2+(y-by)**2
          l<r**2?0.6*r**2<l:
          (x-b1)**2+(y-by1)**2<r**2||
          (x-b2)**2+(y-by2)**2<r**2||
          (shpa[[yj-25,0].max].to_i[ix-22]>0)||
          (shpb[[yj-52,0].max].to_i[ix-12]>0)||
          (shp[[yj-35,0].max].to_i[ix-45]>0)||
          (shp[[48-yj,0].max].to_i[ix-2]>0)
        }+1)/2*(3-2*j)
      }]||cs.shift
    }.join
  }
  (cs*'')[?(]&&raise(cs.index(?().to_s)
  l[-1][-12,12]="))[/[^)]+/]]"
  ["require'zlib';_=->_{eval$C=Zlib.inflate(*_.unpack(?m))};_[%(",l]
}
show=->(a){$><< "\e[1;1H"+[rndr[a],'# '+msg]*"\r\n"}
pn=1
Thread.new{
  STDIN.raw{|f|
    loop{
      c=f.getc
      "\x3\x11\x1C"[c]&&exit
      i='DaCdAwBs '.index(c)
      if i
        m=1<<[i/2,2].min
        m1|=m if pn==1||(i<8&&i%2==0)
        m2|=m if pn==2&&i%2==1
      end
    }
  }
}
args=(ARGV*?:).split(?:)
$><< "\e[2J"
if args.size==2
  sck=TCPSocket.open(*args)
  sck.puts :x
  Thread.new{loop{sck.puts((m&4)|m%2*2|m%4/2);m=0;sleep 0.05}}
  msg="NETWORK BATTLE WITH: #{args*':'}"
  loop{show[sck.gets.to_i]}
end
if args.size==1
  sck=nil
  msg="NETWORK BATTLE"
  server=TCPServer.new(args.first.to_i)
  Thread.new{
    msg << ": LISTENING ON localhost:#{server.addr[1]}"
    loop{
      s=server.accept
      if "x\n"==a=s.gets
        sck=s
        loop{m2=sck.gets.to_i|m2}rescue 1
      else
        s.puts rndr[885457562454749327098200]
        s.close
      end
    }
  }
else
  msg='OFFLINE 2 PLAYER BATTLE: WASD and ARROWS'
  pn=2
end
loop{
  bx,by,vx,vy,b1,p1,b2,p2=dec[k]
  b1+=((m1&2)/2-(m1&1))*20
  b2+=((m2&2)/2-(m2&1))*20
  p1=p1==0&&(m1&4)>0?5:[p1-1,0].max
  p2=p2==0&&(m2&4)>0?5:[p2-1,0].max
  b1=[2*r,b1,w-2*r].sort[1]
  b2=[2*r,b2,w-2*r].sort[1]
  m1=m2=0
  by1=h-r*3/2-pl*(p1>0?1:0)
  by2=r*3/2+pl*(p2>0?1:0)
  4.times{
  bx+=vx/50
  by+=vy/50
  vx=vx*99/100
  vy=vy*99/100
  vy+=vy>0?2:-2
  vx=vx.abs if bx<r
  vx=-vx.abs if bx>w-r
  bx,by,vx,vy=w/2,h/2,rand(-20..20),2*rand(2)-1 if by>=h+r||by<=-r
  [[b1,by1],[b2,by2]].each{|ax,ay|
    dx=bx-ax
    dy=by-ay
    pv=(ay>h/2?-p1: p2)*160
    dr=(dx**2+dy**2)**0.5
    if dr<2*r
      bx+=(dx/dr*(2*r-dr)).round
      by+=(dy/dr*(2*r-dr)).round
      bx=[r,bx,w-r].sort[1]
      dot=vx*dx+(vy-pv)*dy
      if dot<0
        vx-=(1.5*dot*dx/dr/dr).round
        vy-=(1.5*dot*dy/dr/dr-pv*1.5).round
      end
      vx+=(50*dx/dr).round
      vy+=(50*dy/dr).round
    end
  }
  vx=[-w,vx,w].sort[1]
  vy=[-w,vy,w].sort[1]
  bx=[0,bx,w].sort[1]
  by=[-r,by,h+r].sort[1]
  }
  k=enc[bx,by,vx,vy,b1,p1,b2,p2]
  show[k]
  sck&.puts enc[w-bx,h-by,-vx,-vy,w-b2,p2,w-b1,p1] rescue 1
  sleep 0.05
}
#END
