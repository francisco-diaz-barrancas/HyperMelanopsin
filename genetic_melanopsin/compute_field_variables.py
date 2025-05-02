
import numpy as np

# Caché de máscaras circulares: clave = (alto, ancho, radio)
_mask_cache = {}

def compute_field_variables(section_phot, dfdiam_px):
    """
    section_phot: 2D array con la imagen filtrada
    dfdiam_px:    diámetro del parche en píxeles
    """
    H, W = section_phot.shape
    radius = dfdiam_px / 2
    key = (H, W, radius)

    # Obtener o crear la máscara ponderada
    mask = _mask_cache.get(key)
    if mask is None:
        # Coordenadas relativas al centro
        ys = np.arange(H)[:, None]  # (H,1)
        xs = np.arange(W)[None, :]  # (1,W)
        cy, cx = H/2, W/2

        distances = np.sqrt((xs - cx)**2 + (ys - cy)**2)
        inside = distances <= radius

        # Ventana de coseno
        a = np.zeros_like(distances)
        a[inside] = np.cos(np.pi / radius * distances[inside]) + 1

        total = a[inside].sum()
        w = a / total  # normalizado

        mask = w
        _mask_cache[key] = mask

    # Cálculo de excitación y contraste
    weighted = mask * section_phot
    local_exc = weighted.sum()

    if local_exc == 0:
        local_contrast = 0.0
    else:
        diff = (section_phot - local_exc) / local_exc
        local_contrast = np.sqrt((mask * diff**2).sum())

    return {
        'localExc': local_exc,
        'localContrast': local_contrast,
        'patchxy': mask > 0
    }
