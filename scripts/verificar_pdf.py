#!/usr/bin/env python3
"""Verificación de los PDF exportados.

Comprueba: tamaño A4, número de páginas, que el texto sea seleccionable
(extracción real), y señala líneas excesivamente largas que sugieran
contenido cortado por el margen.

Uso:  python scripts/verificar_pdf.py ruta/al/archivo.pdf [...]
      python scripts/verificar_pdf.py            # verifica pdf/*.pdf
"""
import sys
from pathlib import Path

try:
    import pdfplumber
except ImportError:  # pragma: no cover
    print("Falta pdfplumber:  python -m pip install pdfplumber")
    sys.exit(2)

A4_W, A4_H = 595.28, 841.89  # puntos
TOL = 6.0                    # tolerancia en puntos


def revisar(ruta: Path) -> bool:
    ok = True
    with pdfplumber.open(ruta) as pdf:
        n = len(pdf.pages)
        texto_total = []
        problemas = []
        for i, page in enumerate(pdf.pages, 1):
            w, h = page.width or 0, page.height or 0
            if abs(w - A4_W) > TOL or abs(h - A4_H) > TOL:
                problemas.append(
                    f"  pág {i}: tamaño {w:.1f}x{h:.1f} pt (A4 = {A4_W}x{A4_H})"
                )
            words = page.extract_words() or []
            texto_total.append(page.extract_text() or "")
            if not words:
                problemas.append(f"  pág {i}: sin texto extraíble (¿imagen?)")
                continue
            # palabras que se salen del área útil de la página
            fuera = [w_ for w_ in words if w_["x1"] > w - 8 or w_["x0"] < 8]
            if fuera:
                muestras = ", ".join(f"'{f['text'][:28]}'" for f in fuera[:4])
                problemas.append(
                    f"  pág {i}: {len(fuera)} palabra(s) en el margen -> {muestras}"
                )

        texto = "\n".join(texto_total)
        caracteres = len(texto.strip())
        if caracteres < 400:
            problemas.append(
                f"  poco texto extraíble ({caracteres} caracteres)"
            )
            ok = False

        print(f"\n=== {ruta.name}")
        print(f"  páginas ........ {n}")
        print(f"  tamaño ......... {page.width:.1f} x {page.height:.1f} pt"
              f" ({'A4' if abs((page.width or 0)-A4_W) <= TOL else 'NO A4'})")
        print(f"  texto ......... {caracteres} caracteres extraíbles")
        print(f"  estado ......... {'OK' if ok and not problemas else 'REVISAR'}")
        for p in problemas:
            print(p)
            if "sin texto" in p or "poco texto" in p:
                ok = False
    return ok


def main() -> int:
    if len(sys.argv) > 1:
        rutas = [Path(a) for a in sys.argv[1:]]
    else:
        rutas = sorted(Path(__file__).resolve().parent.parent.joinpath("pdf").glob("*.pdf"))

    if not rutas:
        print("No se encontraron PDF para revisar.")
        return 1

    todo_ok = True
    for r in rutas:
        if not r.exists():
            print(f"\n=== {r.name}\n  NO EXISTE")
            todo_ok = False
            continue
        todo_ok &= revisar(r)

    print("\n--------------------------------------------------")
    print("Resultado global:", "TODO OK" if todo_ok else "HAY PENDIENTES")
    return 0 if todo_ok else 1


if __name__ == "__main__":
    sys.exit(main())
