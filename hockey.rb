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
h=1.4
render=->(bx,by,vx,vy,bar1,bar2){
  $><< "\e[1;1H"
  puts "require'base64';require'zlib';eval C=Zlib.inflate Base64.decode64(%(;FIXME"
  codes=Base64.encode64(Zlib.deflate(C)+"\x0"+'#'*C.size).delete("\n").chars
  42.times{|iy|
    puts "\r"+60.times.map{|ix|
      %[ .,':;"!][8-(0..1).sum{|j|
        ((0..3).count{|k|
          x=(ix+k/2*0.5)*0.02/1.2
          y=(2*iy+j+k%2*0.5)*0.02/1.2
          r=(x-bx)**2+(y-by)**2
          (0.08**2<r&&r<0.1**2)||
          (x-bar1)**2+(y-h)**2<0.1**2||
          (x-bar2)**2+y**2<0.1**2
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
  vy=-vy.abs if y>h
  vy=vy.abs if y<0

  [[bar1,h],[bar2,0]].each{|ax,ay|
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
  socket.puts [x,h-y,-vx,vy,bar2,bar1].to_json
  sleep 0.1
}
#END
