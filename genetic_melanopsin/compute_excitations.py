import numpy as np
from scipy.io import loadmat
from scipy.stats import skew, kurtosis
import pandas as pd
from scipy.interpolate import interp1d

def compute_excitations(scene):
    delt_nm = 5
    Y, X, S = scene.shape

    # Original y destino de longitudes de onda
    wl_orig   = np.arange(400, 400 + 10 * S, 10)
    wl_target = np.arange(400, 705, delt_nm)

    # 1) Interpolación espectral vectorizada
    flat = scene.reshape(-1, S)  # (Y*X, S)
    interp_func = interp1d(wl_orig, flat, kind='linear',
                           bounds_error=False, fill_value='extrapolate', axis=1)
    flat5 = interp_func(wl_target)           # (Y*X, len(wl_target))
    scene5nm = flat5.reshape(Y, X, -1)       # (Y, X, len(wl_target))

    # 2) Estadísticas de radiancia (si las necesitas)
    statsRad = np.vstack([
        flat5.mean(axis=0),
        flat5.std(axis=0),
        skew(flat5, axis=0),
        kurtosis(flat5, axis=0)
    ]).T

    # 3) Carga de curvas SMLRG y reinterpolación a wl_target
    smlrg = loadmat('smlrg_CIE.mat')['smlrg_CIE']  # columnas: wl, S, M, L, R, Mel
    wls_smlrg = smlrg[:, 0]
    smlrg_interp = np.zeros((len(wl_target), 5))
    for i in range(5):
        f = interp1d(wls_smlrg, smlrg[:, i + 1],
                     bounds_error=False, fill_value='extrapolate')
        smlrg_interp[:, i] = f(wl_target)

    # 4) Carga de tabla CIE de luminancia y reinterpolación
    A = pd.read_csv('xyz10e_5.csv', header=None)
    f_lum = interp1d(A[0], A[2], bounds_error=False, fill_value='extrapolate')
    vlambda = f_lum(wl_target)
    Km = 683

    # 5) Cálculo vectorizado de excitaciones
    #    (*delt_nm para escalar correctamente)
    SMLRG = np.tensordot(scene5nm, smlrg_interp * delt_nm,
                         axes=([2], [0]))    # → (Y, X, 5)
    Lum10 = Km * np.tensordot(scene5nm, vlambda * delt_nm,
                              axes=([2], [0])) # → (Y, X)

    # 6) Empaquetado de resultados
    evar = {
        'SMLRG':  SMLRG,
        'Lum10':  Lum10[:, :, np.newaxis]
    }

    # Estadísticas por canal
    SML_flat = SMLRG.reshape(-1, 5)
    for idx, name in enumerate(['S', 'M', 'L', 'R', 'Mel']):
        arr = SML_flat[:, idx]
        evar[f'stats{name}'] = [arr.mean(), arr.std(),
                                skew(arr), kurtosis(arr)]
    vLum = Lum10.ravel()
    evar['statsLum10'] = [vLum.mean(), vLum.std(),
                          skew(vLum), kurtosis(vLum)]

    # 7) Chromaticidades con protección
    denom = SMLRG[:, :, 2] + SMLRG[:, :, 1]  # L + M
    eps = 1e-10
    denom_safe = np.where(denom == 0, eps, denom)

    lsrg = np.empty((Y, X, 4))
    lsrg[:, :, 0] =  SMLRG[:, :, 2] / denom_safe  # L/(L+M)
    lsrg[:, :, 1] =  SMLRG[:, :, 0] / denom_safe  # S/(L+M)
    lsrg[:, :, 2] =  SMLRG[:, :, 3] / denom_safe  # R/(L+M)
    lsrg[:, :, 3] =  SMLRG[:, :, 4] / denom_safe  # G/(L+M)
    evar['lsrg'] = lsrg

    return evar

