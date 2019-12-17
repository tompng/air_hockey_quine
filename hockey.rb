require'zlib'
$C=File.read(__FILE__).split(/#B[E]GIN/)[1].split(/#E[N]D/)[0].gsub(/^ +/, '')
def hoge
  w=400
  h=560
  a=[200,280,40,-100,200,0,200,0]
  a.each_with_index.map{|v,i|(w+v)*(2*h)**i}.sum
end
if $C[/\d+/]!=hoge.to_s
  puts hoge
  exit
end
#BEGIN
k=885457562454749327098200
require'io/console'
require'socket'
require'json'
w=400
h=560
parse=->k{k.digits(2*h).map{|a|a-w}}
encode=->*a{a.each_with_index.sum{|v,i|(w+v)*(2*h)**i}}
m1=0
m2=0
m=0
r=40
pushlen=40
msg=nil
shape=[0,65504,101936,170792,307620,540738,2097151,540738,278596,139400,73872,37152,20800,10880,6912,3584,1024]
_render=->k{
  bx,by,vx,vy,bar1,push1,bar2,push2=parse[k]
  bary1=h-r*3/2-pushlen*(push1>0?1:0)
  bary2=r*3/2+pushlen*(push2>0?1:0)
  $C[/\d+/]=k.to_s
  codes=[Zlib.deflate($C)].pack(?m).delete("\n=").chars
  codes+=[?(]+codes
  l=42.times.map{|iy|
    60.times.map{|ix|
      %[ .,':;"!][8-(0..1).sum{|j|
        ((0..3).count{|k|
          x=(ix+k/2*0.5)*w/60
          y=(2*iy+j+k%2*0.5)*h/84
          l=(x-bx)**2+(y-by)**2
          l<r**2?0.6*r**2<l:
          (x-bar1)**2+(y-bary1)**2<r**2||
          (x-bar2)**2+(y-bary2)**2<r**2||
          (shape[[2*iy+j-34,0].max].to_i[ix-37]>0)||
          (shape[[49-2*iy-j,0].max].to_i[ix-2]>0)
        }+1)/2*(3-2*j)
      }]||codes.shift
    }.join
  }
  l[-1][-12,12]="))[/[^)]+/]]"
  ["require'zlib';_=->_{eval$C=Zlib.inflate(*_.unpack(?m))};_[%(",l]
}
$><< "\e[2J"
render=->(a){$><< "\e[1;1H"+[_render[a],'# '+msg]*"\r\n"}
player=1
Thread.new{
  STDIN.raw do |f|
    loop do
      c=f.getc
      "\x3\x11\x1C"[c]&&exit
      i='DaCdAwBs '.index(c)
      if i
        m=1<<[i/2,2].min
        m1|=m if player==1||(i<8&&i%2==0)
        m2|=m if player==2&&i%2==1
      end
    end
  end
}
args=*(ARGV*'').split(':')
if args.size==2
  socket=TCPSocket.open(*args)
  socket.puts :x
  Thread.new{loop{socket.puts(m);m=0;sleep 0.05}}
  msg="NETWORK BATTLE WITH: #{args*':'}"
  loop{render[socket.gets.to_i]}
end
if args.size==1
  socket=nil
  msg="NETWORK BATTLE"
  Thread.new{
    server=TCPServer.new(args.first.to_i)
    msg << ": LISTENING ON localhost:#{server.addr[1]}"
    loop{
      s=server.accept
      if "x\n"==a=s.gets
        socket=s
        loop{m2=socket.gets.to_i|m2}rescue 1
      else
        s.puts _render[885457562454749327098200]
        s.close
      end
    }
  }
else
  msg='OFFLINE 2 PLAYER BATTLE: WASD and ARROWS'
  player=2
end
loop{
  bx,by,vx,vy,bar1,push1,bar2,push2=parse[k]
  bar1+=((m1&2)/2-(m1&1))*20
  bar2+=((m2&2)/2-(m2&1))*20
  push1=push1==0&&(m1&4)>0?5:[push1-1,0].max
  push2=push2==0&&(m2&4)>0?5:[push2-1,0].max
  bar1=[2*r,bar1,w-2*r].sort[1]
  bar2=[2*r,bar2,w-2*r].sort[1]
  m1=m2=0
  by1=h-r*3/2-pushlen*(push1>0?1:0)
  by2=r*3/2+pushlen*(push2>0?1:0)
  4.times{
  bx+=vx/50
  by+=vy/50
  vx=vx*99/100
  vy=vy*99/100
  vy+=(vy>0?2:-2)
  vx=vx.abs if bx<r
  vx=-vx.abs if bx>w-r
  bx,by,vx,vy=w/2,h/2,rand(-20..20),2*rand(2)-1 if by>=h+r||by<=-r
  [[bar1,by1],[bar2,by2]].each{|ax,ay|
    dx=bx-ax
    dy=by-ay
    pv=(ay>h/2?-push1: push2)*160
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
    end
  }
  vx=[-w,vx,w].sort[1]
  vy=[-w,vy,w].sort[1]
  bx=[0,bx,w].sort[1]
  by=[-r,by,h+r].sort[1]
  }
  k=encode[bx,by,vx,vy,bar1,push1,bar2,push2]
  render[k]
  socket&.puts encode[bx,h-by,0,0,bar2,push2,bar1,push1] rescue 1
  sleep 0.1
}
#END
