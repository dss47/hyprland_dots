#!/bin/bash
# Fast, instant JSON listing of removable USB drives & partitions
lsblk -J -o NAME,SIZE,TYPE,MOUNTPOINTS,LABEL,MODEL,RM,HOTPLUG 2>/dev/null | python3 -c '
import sys, json

try:
    data = json.load(sys.stdin)
    devices = []
    for dev in data.get("blockdevices", []):
        is_removable = dev.get("rm", False) or dev.get("hotplug", False)
        # Check disk itself or children partitions
        if is_removable:
            model = dev.get("model") or dev.get("label") or dev.get("name")
            size = dev.get("size", "")
            children = dev.get("children", [dev])
            for part in children:
                mounts = [m for m in part.get("mountpoints", []) if m]
                devices.append({
                    "name": part.get("name", ""),
                    "devPath": "/dev/" + part.get("name", ""),
                    "label": part.get("label") or model or part.get("name", ""),
                    "size": part.get("size") or size,
                    "mounted": len(mounts) > 0,
                    "mountpoint": mounts[0] if len(mounts) > 0 else ""
                })
    print(json.dumps(devices))
except Exception as e:
    print("[]")
'
