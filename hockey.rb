# C=%[
require 'base64'
C=File.read(__FILE__).split(/#B[E]GIN/)[1].split(/#E[N]D/)[0]
#BEGIN
require 'io/console'
require 'socket'
require'json'
m1=0
m2=0
m=0
render=->(bx,by,vx,vy,bar1,bar2){
  $><< "\e[1;1H"
  puts "require'base64';eval C=Base64.decode64(%("
  codes=Base64.encode64(C+"\x0"+C).delete("\n").chars
  50.times{|iy|
    puts "\r"+50.times.map{|ix|
      x=ix*0.02
      y=iy*0.02
      (
        (x-bx)**2+(y-by)**2<0.1**2||
        (x-bar1)**2+(y-1)**2<0.1**2||
        (x-bar2)**2+y**2<0.1**2
      ) ? ' ' : codes.shift||'#'
    }.join
  }
  puts "\r))"
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
if ARGV[0]
  socket=TCPSocket.open(*(ARGV*'').split(':'))
  Thread.new{loop{socket.puts(m);m=0;sleep 0.05}}
  loop{render[*JSON.parse(socket.gets)]}
end
server=TCPServer.new(0)
p server
socket=server.accept
Thread.new{loop{m2=socket.gets.to_i|m2}}
bar1=0.5
bar2=0.5
x,y,vx,vy=0.5,0.5,0,1
loop{
  4.times{
  bar1+=((m1&2)/2-(m1&1))*0.05
  bar2+=((m2&2)/2-(m2&1))*0.05
  m1=m2=0
  bar1=[0,bar1,1].sort[1]
  bar2=[0,bar2,1].sort[1]
  x+=vx*0.02
  y+=vy*0.02
  vx=vx.abs if x<0
  vx=-vx.abs if x>1
  vy=-vy.abs if y>1
  vy=vy.abs if y<0

  [[bar1,1],[bar2,0]].each{|ax,ay|
    dx=x-ax
    dy=y-ay
    dr=(dx**2+dy**2)**0.5
    dot=vx*dx+vy*dy
    if dr<0.2&&dot<0
      vx-=2*dot*dx/dr/dr
      vy-=2*dot*dy/dr/dr
    end
  }
  }
  render[x,y,vx,vy,bar1,bar2]
  socket.puts [x,1-y,-vx,vy,bar2,bar1].to_json
  sleep 0.1
}
#END
# ].gsub(/^ +/, '')
