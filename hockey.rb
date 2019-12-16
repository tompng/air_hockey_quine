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
render=->(bx,by,vx,vy,bar1,push1,bar2,push2){
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
          (x-bar1)**2+(y-h+pushlen*push1)**2<r**2||
          (x-bar2)**2+(y-pushlen*push2)**2<r**2
        }+1)/2*(3-2*j)
      }]||codes.shift
    }.join
  }
  puts %[\r).delete(%[ .,':;"!])]
}
Thread.new{
  STDIN.raw do |f|
    loop do
      c=f.getc
      "\x3\x11\x1C"[c]&&exit
      i='DaCdAwBs '.index(c)
      i&&m1|=m=1<<[i/2,2].min
    end
  end
}
args=*(ARGV*'').split(':')
if args.size==2
  socket=TCPSocket.open(*args)
  Thread.new{loop{socket.puts(m);m=0;sleep 0.05}}
  loop{render[*JSON.parse(socket.gets)]}
end
server=TCPServer.new(args.first.to_i)
p server
socket=nil
Thread.new{
  loop{
    socket=server.accept
    loop{m2=socket.gets.to_i|m2}rescue 1
  }
}
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
  bar1=[0,bar1,1].sort[1]
  bar2=[0,bar2,1].sort[1]
  pv1=push1>0?1:0
  pv2=push2>0?1:0
  m1=m2=0
  4.times{
  x+=vx*0.02
  y+=vy*0.02
  vx*=0.99
  vy*=0.99
  vy+=(vy>0?1:-1)*0.005
  vx=vx.abs if x<r
  vx=-vx.abs if x>1-r
  vy=-vy.abs if y>h
  vy=vy.abs if y<0

  [[bar1,h-pushlen*pv1],[bar2,pushlen*pv2]].each{|ax,ay|
    dx=x-ax
    dy=y-ay
    pv=(ay>h/2?-push1: push2)*0.4
    dr=(dx**2+dy**2)**0.5
    dot=vx*dx+(vy-pv)*dy
    if dr<2*r&&dot<0
      vx-=1.5*dot*dx/dr/dr
      vy-=1.5*dot*dy/dr/dr-pv*1.5
    end
  }
  }
  render[x,y,vx,vy,bar1,pv1,bar2,pv2]
  socket&.puts [x,h-y,-vx,vy,bar2,pv2,bar1,pv1].to_json rescue 1
  sleep 0.1
}
#END
