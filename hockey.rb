require 'base64'
require'zlib'
C=File.read(__FILE__).split(/#B[E]GIN/)[1].split(/#E[N]D/)[0].gsub(/^ +/, '')

#BEGIN
require 'io/console'
require 'socket'
require'json'
m1=0
m2=0
m=0
r=0.1
h=1.4
pushlen=0.1
render=->(bx,by,vx,vy,bar1,bary1,bar2,bary2){
  $><< "\e[1;1H"
  puts "require'base64';require'zlib';eval C=Zlib.inflate Base64.decode64(%(;FIXME"
  codes=Base64.encode64(Zlib.deflate(C)+"\x0"+'#'*C.size).delete("\n").chars
  42.times{|iy|
    puts "\r"+60.times.map{|ix|
      %[ .,':;"!][8-(0..1).sum{|j|
        ((0..3).count{|k|
          x=(ix+k/2*0.5)*0.02/1.2
          y=(2*iy+j+k%2*0.5)*0.02/1.2
          l=(x-bx)**2+(y-by)**2
          (0.08**2<l&&l<r**2)||
          (x-bar1)**2+(y-bary1)**2<r**2||
          (x-bar2)**2+(y-bary2)**2<r**2
        }+1)/2*(3-2*j)
      }]||codes.shift
    }.join
  }
  puts %[\r).delete(%[ .,':;"!])]
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
  Thread.new{loop{socket.puts(m);m=0;sleep 0.05}}
  loop{render[*JSON.parse(socket.gets)]}
end
if args.size==1
  socket=nil
  Thread.new{
    server=TCPServer.new(args.first.to_i)
    loop{
      socket=server.accept
      loop{m2=socket.gets.to_i|m2}rescue 1
    }
  }
else
  player=2
end
bar1=0.5
push1=0
bar2=0.5
push2=0
x,y,vx,vy=0.5,0.5,0,1
loop{
  bar1+=((m1&2)/2-(m1&1))*0.05
  bar2+=((m2&2)/2-(m2&1))*0.05
  push1=push1==0&&(m1&4)>0?1:[push1-0.2,0].max
  push2=push2==0&&(m2&4)>0?1:[push2-0.2,0].max
  bar1=[2*r,bar1,1-2*r].sort[1]
  bar2=[2*r,bar2,1-2*r].sort[1]
  m1=m2=0
  by1=h-1.5*r-pushlen*(push1>0?1:0)
  by2=1.5*r+pushlen*(push2>0?1:0)
  4.times{
  x+=vx*0.02
  y+=vy*0.02
  vx*=0.99
  vy*=0.99
  vy+=(vy>0?1:-1)*0.005
  vx=vx.abs if x<r
  vx=-vx.abs if x>1-r
  x,y,vx,vy=0.5,h/2,*(0..1).map{0.05*rand(-1..1)} if y>h+r||y<-r
  [[bar1,by1],[bar2,by2]].each{|ax,ay|
    dx=x-ax
    dy=y-ay
    pv=(ay>h/2?-push1: push2)*0.4
    dr=(dx**2+dy**2)**0.5
    if dr<2*r
      x+=dx/dr*(2*r-dr)
      y+=dy/dr*(2*r-dr)
      x=[r,x,1-r].sort[1]
      vx+=dx*(2*r-dr)
      vy+=dy*(2*r-dr)
      dot=vx*dx+(vy-pv)*dy
      if dot<0
        vx-=1.5*dot*dx/dr/dr
        vy-=1.5*dot*dy/dr/dr-pv*1.5
      end
    end
  }
  }
  render[x,y,vx,vy,bar1,by1,bar2,by2]
  socket&.puts [x,h-y,-vx,vy,bar2,h-by2,bar1,h-by1].to_json rescue 1
  sleep 0.1
}
#END
