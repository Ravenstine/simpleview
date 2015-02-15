module Keyboard
  @@keycodes = {
    8 => "0xff08", #backspace
    9 => "0xff09", #tab
    13 => "0xff0d", #enter
    16 => "0xffe1", #shift (only supports lshift)
    17 => "0xffe3", #ctrl (only supports lctrl)
    18 => "0xffe9", #alt (only supports lalt)
    19 => "0xff13", #pause/break
    20 => "0xffe5", #caps_lock
    27 => "0xff1b", #escape
    32 => "0x0020", #space
    33 => "0xff9a", #page up
    34 => "0xff9b", #page down
    35 => "0xff9c", #end
    36 => "0xff95", #home
    37 => "0x08fb", #left arrow
    38 => "0x08fc", #up arrow
    39 => "0x08fd", #right arrow
    40 => "0x08fe", #down arrow
    45 => "0xff63", #insert
    46 => "0xff9f", #delete
    48 => "0x0030", #0
    49 => "0x0031", #1
    50 => "0x0032", #2
    51 => "0x0033", #3
    52 => "0x0034", #4
    53 => "0x0035", #5
    54 => "0x0036", #6
    55 => "0x0037", #7
    56 => "0x0038", #8
    57 => "0x0039", #9
    91 => "0xffeb", #left super
    92 => "0xffec", #right super
    65 => "0x0061",
    66 => "0x0062",
    67 => "0x0063",
    68 => "0x0064",
    69 => "0x0065",
    70 => "0x0066",
    71 => "0x0067",
    72 => "0x0068",
    73 => "0x0069",
    74 => "0x006a",
    75 => "0x006b",
    76 => "0x006c",
    77 => "0x006d",
    78 => "0x006e",
    79 => "0x006f",
    80 => "0x0070",
    81 => "0x0071",
    82 => "0x0072",
    83 => "0x0073",
    84 => "0x0074",
    85 => "0x0075",
    86 => "0x0076",
    87 => "0x0077",
    88 => "0x0078",
    89 => "0x0079",
    90 => "0x007a",
    93 => "0xff60", #select
    96 => "0x0030",
    97 => "0x0031",
    98 => "0x0032",
    99 => "0x0033",
    100 => "0x0034",
    101 => "0x0035",
    102 => "0x0036",
    103 => "0x0037",
    104 => "0x0038",
    105 => "0x0039",
    106 => "0x002a", #asterisk
    107 => "0x002b", #plus
    109 => "0x002d", #minus
    110 => "0xffae", #decimal
    111 => "0xffaf", #divide
    112 => "0xffbe", #function keys
    113 => "0xffbf", 
    114 => "0xffc0", 
    115 => "0xffc1", 
    116 => "0xffc2", 
    117 => "0xffc3", 
    118 => "0xffc4", 
    119 => "0xffc5", 
    120 => "0xffc6", 
    121 => "0xffc7", 
    122 => "0xffc8", 
    123 => "0xffc9",
    144 => "0xff7f", #num lock
    145 => "0xff14", #scroll lock
    186 => "0x003b", #semicolon
    187 => "0x003d", #equals sign
    188 => "0x002c", #comma
    189 => "0x002d", #hyphen
    190 => "0x002e", #period (full stop)
    191 => "0x002f", #foward slash
    192 => "0x0060", #grave accent
    219 => "0x005b", #open bracket
    220 => "0x005c", #back slash
    221 => "0x005d", #close bracket
    222 => "0x0027", #single quote

  }
  def self.keydown code
    send_key :keydown, code
  end
  def self.keyup code
    send_key :keyup, code
  end
  private
  def self.send_key command, code
    POSIX::Spawn.send(:`, "xte '#{command} #{@@keycodes[code]}'")
  end
end