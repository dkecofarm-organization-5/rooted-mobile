from pathlib import Path
from PIL import Image, ImageOps
import json, shutil

ROOT = Path(__file__).resolve().parents[1]
DROP = Path(__file__).resolve().parent
TARGET = (1920, 1080)

SCENE_FILES = {
    "bridge-who-we-are": ["EV2_BRIDGE_WHO_WE_ARE_GREENHOUSE_FIELD_WORK.jpg"],
    "j2-01": ["EV2_J2_01_UZBEKISTAN_FIELD_SITE_UNIQUE.jpg"],
    "j2-05": ["EV2_J2_05_UZBEKISTAN_LOCAL_KNOWLEDGE_UNIQUE.jpg"],
    "j4-01": ["EV2_J4_01_REAL_SENSOR_CONTROL_INSTALLATION.jpg"],
    "j5-06": ["EV2_J5_06_REAL_CONTROLLER_OR_FARMTOS_OPERATION.jpg"],
    "proof-real-environments": ["EV2_PROOF_REAL_ENVIRONMENTS_TOMATO_GREENHOUSE.jpg"],
}

def fit_16x9(src, dst):
    im = Image.open(src).convert("RGB")
    # deterministic crop only; no generative alteration
    out = ImageOps.fit(im, TARGET, method=Image.Resampling.LANCZOS, centering=(0.5, 0.5))
    out.save(dst, quality=94, subsampling=0)

for lang in ("KR","EN","RU"):
    rdir = ROOT / "runtime" / lang
    data_path = rdir / "data.json"
    data = json.loads(data_path.read_text(encoding="utf-8"))
    assets = rdir / "assets" / "evergreen_v2"
    assets.mkdir(parents=True, exist_ok=True)

    for scene in data["scenes"]:
        sid = scene["id"]
        if sid in SCENE_FILES:
            src = DROP / SCENE_FILES[sid][0]
            if src.exists():
                dst = assets / f"{sid}.jpg"
                fit_16x9(src, dst)
                scene["image"] = f"assets/evergreen_v2/{sid}.jpg"
                scene["imageSide"] = "left"
                scene["kind"] = "split"
                scene.setdefault("visualQA", {})["status"] = "VERIFIED_ORIGINAL_APPLIED"

    data_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    (rdir / "data.js").write_text(
        "window.ROOTED_LANDSCAPE=" + json.dumps(data, ensure_ascii=False, separators=(",",":")) + ";",
        encoding="utf-8"
    )

print("Applied available single-photo verified sources. Multi-photo scenes require editorial composition.")
