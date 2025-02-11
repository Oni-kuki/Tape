import mmap
import os
import argparse

parser = argparse.ArgumentParser(description="Replace strings in a binary file.")
parser.add_argument("file", help="Path to the binary file to modify.")


args = parser.parse_args()
print(args.file)

def replace_strings_in_binary(file_path, replacements):
    file_path = args.file
    if not os.path.isfile(file_path):
        print(f"Error : file {file_path} not find.")
        return

    for original, replacement in replacements.items():
        if len(original) != len(replacement):
            print(f"Error : sizes are different '{original}' / '{replacement}'.")
            return

    try:
        with open(file_path, "r+b") as f:
            with mmap.mmap(f.fileno(), 0) as mm:
                for original, replacement in replacements.items():
                    original_bytes = original.encode("utf-8")
                    replacement_bytes = replacement.encode("utf-8")
                    offset = 0
                    count = 0

                    while True:
                        offset = mm.find(original_bytes, offset)
                        if offset == -1:
                            break
                        print(f"find to {hex(offset)} : {original}")
                        mm[offset:offset + len(original_bytes)] = replacement_bytes
                        count += 1
                        offset += len(original_bytes)

                    if count > 0:
                        print(f"{count} occurrence of '{original}' was replaced by '{replacement}'.")
                    else:
                        print(f"no one occurrence of '{original}' was found.")

                mm.flush()
        print("Modifications successfull.")

    except Exception as e:
        print(f"Treatment error : {e}")


if __name__ == "__main__":
    file_path = args.file

    replacements = {
        ".RequestResend": ".RetryyFailedd",
        ".GetPrivInfoo": ".FetchUserKey",
        "InvokeSpawnDllReq": "LaunchDllExecingg",
        "NetstatReq": "ConnChecke",
        "HTTPSessionInit": "HTTPConnSetup  ",
        "ScreenshotReq": "CaptureScreen",
        "RegistryReadReq": "RegFetchKeys   ",
        "sliv": "vils",
        ":dnuo": ":enuo", #Warning this part is link with the dns listener so if you use dns listener and change this part, we will break the binary
        ">httpu": ">hpptu", #Warning this part is link with the http listener so if you use http listener and change this part, we will break the binary
        "9httpu": "9htppu",#Warning this part is link with the http listener so if you use http listener and change this part, we will break the binary
        ":http": ":hppo",#Warning this part is link with the http listener so if you use http listener and change this part, we will break the binary
        "8http": "8hppt",
#       "f.:dn.": "f.:en.",
#       "9mtls": "6mtls" #Warning this part is link with the mtls listener so if you use mtls listener and change this part, we will break the binary
#        "B/Z-github.com/bishopfox/sliver/protobuf/sliverpbb": "P/A-gathvb.cim/bissopzox/sliuer/profobuf/sliuerpbb",
#        "github.com/bishopfox/sliver/": "gathvb.cim/bissopzox/sliuer/",
#        "/sliver/": "/sliuer/",
#        "sliverpb": "sliuerpb"
    }

replace_strings_in_binary(file_path, replacements)