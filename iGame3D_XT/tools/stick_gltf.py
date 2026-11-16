#!/usr/bin/env python3
"""stick_gltf.py: our stick figure as a glTF 2.0 file, for engines other than Vibecode3D.

    python3 -I stick_gltf.py

Writes ../Data/Models/stick_figure.gltf: the civilian figure of Tools/v3d_figures (1.8 m,
standing, facing -z, y up as glTF has it), as LINES with the buffer inside the file (base64),
one node named "civilian_001". Scripts keep role names (civilian_001, soldier_001 ...); this
file is the shape they all share.
"""
import base64, json, math, os, struct

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(HERE), "Data", "Models", "stick_figure.gltf")

# the same joints and bones as Fig.Make(civilian, stand), in metres, y up
LINES = [((-0.12, 0, 0), (-0.1, 0.5, 0)), ((-0.1, 0.5, 0), (-0.1, 0.95, 0)),
         ((0.12, 0, 0), (0.1, 0.5, 0)), ((0.1, 0.5, 0), (0.1, 0.95, 0)),
         ((-0.1, 0.95, 0), (0.1, 0.95, 0)), ((0, 0.95, 0), (0, 1.5, 0)),
         ((-0.22, 1.42, 0), (0.22, 1.42, 0)),
         ((-0.22, 1.42, 0), (-0.28, 1.12, 0)), ((-0.28, 1.12, 0), (-0.28, 0.85, 0)),
         ((0.22, 1.42, 0), (0.28, 1.12, 0)), ((0.28, 1.12, 0), (0.28, 0.85, 0))]
for axis in ("z", "x"):                       # the head: two rings of 10
    for k in range(10):
        a, b = 2 * math.pi * k / 10, 2 * math.pi * (k + 1) / 10
        if axis == "z":
            p = (0.12 * math.cos(a), 1.62 + 0.12 * math.sin(a), 0)
            q = (0.12 * math.cos(b), 1.62 + 0.12 * math.sin(b), 0)
        else:
            p = (0, 1.62 + 0.12 * math.cos(a), 0.12 * math.sin(a))
            q = (0, 1.62 + 0.12 * math.cos(b), 0.12 * math.sin(b))
        LINES.append((p, q))

verts, index, idx = [], {}, []
for p, q in LINES:
    for v in (p, q):
        key = tuple(round(c, 4) for c in v)
        if key not in index:
            index[key] = len(verts)
            verts.append(key)
        idx.append(index[key])
vbytes = b"".join(struct.pack("<3f", *v) for v in verts)
ibytes = b"".join(struct.pack("<H", i) for i in idx)
pad = (4 - len(vbytes) % 4) % 4
buf = vbytes + b"\0" * pad + ibytes
lo = [min(v[i] for v in verts) for i in range(3)]
hi = [max(v[i] for v in verts) for i in range(3)]
gltf = {
    "asset": {"version": "2.0", "generator": "iGame3D XT stick_gltf.py"},
    "scene": 0, "scenes": [{"nodes": [0]}],
    "nodes": [{"name": "civilian_001", "mesh": 0}],
    "meshes": [{"name": "stick_figure", "primitives": [{"attributes": {"POSITION": 0}, "indices": 1, "mode": 1}]}],
    "buffers": [{"byteLength": len(buf), "uri": "data:application/octet-stream;base64," + base64.b64encode(buf).decode()}],
    "bufferViews": [{"buffer": 0, "byteOffset": 0, "byteLength": len(vbytes), "target": 34962},
                    {"buffer": 0, "byteOffset": len(vbytes) + pad, "byteLength": len(ibytes), "target": 34963}],
    "accessors": [{"bufferView": 0, "componentType": 5126, "count": len(verts), "type": "VEC3", "min": lo, "max": hi},
                  {"bufferView": 1, "componentType": 5123, "count": len(idx), "type": "SCALAR"}],
}
os.makedirs(os.path.dirname(OUT), exist_ok=True)
with open(OUT, "w") as f:
    json.dump(gltf, f, indent=1)
print(f"wrote {OUT}: {len(verts)} vertices, {len(idx) // 2} lines, {os.path.getsize(OUT)} bytes")
