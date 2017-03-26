sysinfo
======

Sysinfo was created to fill a gap in the ability to easily locate specific system related information. I was looking for one tool that would present items similar to what might be found in macOS' "About This Mac" menu item.


Installing sysinfo
-----------------

From the command prompt, type:

     cp ./sysinfo /usr/local/bin/sysinfo
     chmod +x /usr/local/bin/sysinfo


Using sysinfo
-----------------

From the command prompt, type:

     sudo sysinfo

Or to output to a file:

     sysinfo >~/filename
     
Requirements
-----------------

Script expects sudo access, and relies on the following bash command:

    dmidecode

sysinfo also expects a file describing the linux release located at:

    /etc/*release
    
Output
------------------
          Computer Model: Manufacturer & Model Name/Number 
           Serial Number: Serial
        Operating System: Fedora 25 (Workstation Edition)
             Project URL: URL for associated project
                    BIOS: Bios Manufacturer & Firmware Version
             Logic Board: Logic Board 
      Logic Board Serial: Serial
               Processor: CPU Manufacturer and Model
        Memory Installed: Installed RAM
          Maximum Memory: Max Installable RAM
