require 'base64'
require'zlib'
C=File.read(__FILE__).split(/#B[E]GIN/)[1].split(/#E[N]D/)[0].gsub(/^ +/, '')
w=400
a=[200,280,40,-100,200,0,200,0]
k=a.each_with_index.map{|v,i|(w+v)*(2*w)**i}.sum
#BEGIN
require 'io/console'
require 'socket'
require'json'
w=400
bx,by,vx,vy,bar1,push1,bar2,push2=k.digits(2*w).map{|a|a-w}
m1=0
m2=0
m=0
r=40
h=560
rendered=nil
pushlen=40
msg=nil
shape=[0,65504,101936,170792,307620,540738,2097151,540738,278596,139400,73872,37152,20800,10880,6912,3584,1024]
_render=->(bx,by,vx,vy,bar1,bary1,bar2,bary2){
  s=["k=#{[bx,by,vx,vy,bar1,push1,bar2,push2].each_with_index.sum{|v,i|(w+v)*(2*w)**i}}",
    "require'base64';require'zlib';eval C=Zlib.inflate Base64.decode64(%(;FIXME"]

  codes=Base64.encode64(Zlib.deflate(C)+"\x0"+'#'*C.size).delete("\n").chars
  s+42.times.map{|iy|
    60.times.map{|ix|
      %[ .,':;"!][8-(0..1).sum{|j|
        ((0..3).count{|k|
          x=(ix+k/2*0.5)*w/60
          y=(2*iy+j+k%2*0.5)*h/84
          l=(x-bx)**2+(y-by)**2
          l<r**2?0.6*r**2<l:
          (x-bar1)**2+(y-bary1)**2<r**2||
          (x-bar2)**2+(y-bary2)**2<r**2||
          (shape[[2*iy+j-34,0].max].to_i[ix-35]>0)||
          (shape[[49-2*iy-j,0].max].to_i[ix-5]>0)
        }+1)/2*(3-2*j)
      }]||codes.shift
    }.join
  }+[%[).delete(%[ .,':;"!])],"AIR HOCKEY #{msg}"]
}
render=->(*a){
  rendered=a
  $><< "\e[2J]\e[1;1H"+_render[*a]*"\r\n"
}
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
  loop{render[*JSON.parse(socket.gets)]}
end
if args.size==1
  socket=nil
  Thread.new{
    server=TCPServer.new(port=args.first.to_i)
    msg="NETWORK BATTLE: LISTENING ON localhost:#{port}"
    loop{
      s=server.accept
      if "x\n"==a=s.gets
        socket=s
        loop{m2=socket.gets.to_i|m2}rescue 1
      else
        s.write _render[*rendered]*"\n"
        s.close
      end
    }
  }
else
  msg="2 PLAYER BATTLE: WASD and ARROWS"
  player=2
end
loop{
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
  render[bx,by,vx,vy,bar1,by1,bar2,by2]
  socket&.puts [bx,h-by,-vx,vy,bar2,h-by2,bar1,h-by1].to_json rescue 1
  sleep 0.1
}
#END
