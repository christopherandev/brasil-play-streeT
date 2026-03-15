import sqlite3
import math
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
os.chdir("../scriptfiles")

INPUT_FILE = "removebuilds.txt"
DB_FILE = "allbuildings.db"

MARGIN = 0.250
EPS = 0.001  # tolerância para comparar floats

# ----------------------------
# ler objetos a remover
# ----------------------------

remove_points = []

with open(INPUT_FILE) as f:
    for line in f:
        model, x, y, z = line.strip().split(",")
        remove_points.append((int(model), float(x), float(y), float(z)))

# ----------------------------
# calcular centro médio
# ----------------------------

cx = sum(p[1] for p in remove_points) / len(remove_points)
cy = sum(p[2] for p in remove_points) / len(remove_points)
cz = sum(p[3] for p in remove_points) / len(remove_points)

# ----------------------------
# calcular raio máximo
# ----------------------------

radius = 0

for _, x, y, z in remove_points:
    d = math.hypot(x - cx, y - cy)
    if d > radius:
        radius = d

radius += MARGIN

print("/* REMOVE ORIGINAL MAP OBJECTS */")
print(f"RemoveBuildingForPlayer(playerid, -1, {cx:.3f}, {cy:.3f}, {cz:.3f}, {radius:.3f});")
print()

# ----------------------------
# preparar conjunto de remoção
# ----------------------------

def same_pos(a, b):
    return (
        abs(a[0] - b[0]) < EPS and
        abs(a[1] - b[1]) < EPS and
        abs(a[2] - b[2]) < EPS
    )

remove_positions = [(p[1], p[2], p[3]) for p in remove_points]


# ----------------------------
# conectar banco
# ----------------------------

conn = sqlite3.connect(DB_FILE)
cur = conn.cursor()

cur.execute("""
SELECT Model, LODModel, X, Y, Z, RX, RY, RZ
FROM buildings
WHERE X BETWEEN ? AND ?
AND Y BETWEEN ? AND ?
""", (cx - radius, cx + radius, cy - radius, cy + radius))

rows = cur.fetchall()

print("/* RECREATE VALID OBJECTS */")

for model, lod, x, y, z, rx, ry, rz in rows:

    # verificar se está dentro do círculo
    d = math.hypot(x - cx, y - cy)
    if d > radius:
        continue

    # ignorar LOD objects
    if lod == 65535:
        continue

    # verificar se estava na lista de remoção
    removed = False
    for rp in remove_positions:
        if same_pos((x, y, z), rp):
            removed = True
            break

    if removed:
        continue

    print(
        f"CreateDynamicObject({model}, {x:.3f}, {y:.3f}, {z:.3f}, "
        f"{rx:.3f}, {ry:.3f}, {rz:.3f});"
    )


conn.close()