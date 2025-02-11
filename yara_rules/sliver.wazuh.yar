rule sliver_client : c2 implant
{
    meta:
        description = "Sliver C2 Implant"
        author = "Wazuh team"
        url = "https://github.com/BishopFox/sliver"

    strings:
        $s1 = "sliverpb"
        $s2 = "/sliver/"
        $s3 = "github.com/bishopfox/sliver/"
        $p1 = {66 81 ?? 77 67}
        $p2 = { 81 ?? 68 74 74 70 [2-32] 80 ?? 04 73 }
        $p3 = { 66 81 ?? 64 6E [2-20] 80 ?? 02 73 }
        $p4 = {  81 ?? 6D 74 6C 73  }

    condition:
        2 of ($p*) or any of ($s1,$s2,$s3) and filesize < 50MB
}
