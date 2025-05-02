import numpy as np
from scipy.io import loadmat
from scipy.stats import skew, kurtosis
import pandas as pd
from scipy.interpolate import interp1d
from multiprocessing.dummy import Pool  # Thread-based pool
from multiprocessing import cpu_count

# Pre-carga de datos espectrales
_smlrg_data = loadmat('smlrg_CIE.mat')['smlrg_CIE']
_wls_smlrg  = _smlrg_data[:, 0]

_xyz_df = pd.read_csv('xyz10e_5.csv', header=None)
_f_lum  = interp1d(_xyz_df[0], _xyz_df[2],
                   bounds_error=False, fill_value='extrapolate')

def compute_excitations(scene):
    delt_nm = 5
    Y, X, S = scene.shape

    wl_orig   = np.arange(400, 400 + 10 * S, 10)
    wl_target = np.arange(400, 705, delt_nm)

    flat      = scene.reshape(-1, S)
    interp_sp = interp1d(wl_orig, flat,
                         kind='linear',
                         bounds_error=False,
                         fill_value='extrapolate',
                         axis=1)
    flat5     = interp_sp(wl_target)
    scene5nm  = flat5.reshape(Y, X, -1)

    smlrg_interp = np.stack([
        interp1d(_wls_smlrg,
                 _smlrg_data[:, i+1],
                 bounds_error=False,
                 fill_value='extrapolate')(wl_target)
        for i in range(5)
    ], axis=1)

    vlambda = _f_lum(wl_target)
    Km      = 683

    SMLRG = np.tensordot(scene5nm,
                         smlrg_interp * delt_nm,
                         axes=([2], [0]))
    Lum10 = Km * np.tensordot(scene5nm,
                              vlambda * delt_nm,
                              axes=([2], [0]))

    evar = {
        'SMLRG': SMLRG,
        'Lum10': Lum10[:, :, np.newaxis]
    }

    flatS = SMLRG.reshape(-1, 5)
    for idx, name in enumerate(['S','M','L','R','Mel']):
        arr = flatS[:, idx]
        evar[f'stats{name}'] = [arr.mean(), arr.std(), skew(arr), kurtosis(arr)]
    vLum = Lum10.ravel()
    evar['statsLum10'] = [vLum.mean(), vLum.std(), skew(vLum), kurtosis(vLum)]

    denom = SMLRG[:,:,2] + SMLRG[:,:,1]
    eps   = 1e-10
    safe  = np.where(denom==0, eps, denom)

    lsrg = np.empty((Y, X, 4))
    lsrg[:,:,0] = SMLRG[:,:,2] / safe
    lsrg[:,:,1] = SMLRG[:,:,0] / safe
    lsrg[:,:,2] = SMLRG[:,:,3] / safe
    lsrg[:,:,3] = SMLRG[:,:,4] / safe
    evar['lsrg'] = lsrg

    return evar

def compute_excitations_parallel(scenes, n_workers=None):
    """
    Procesa una lista de parches con threads (no procesos),
    evitando errores de procesos demoníacos.
    """
    if n_workers is None:
        n_workers = cpu_count()
    with Pool(n_workers) as pool:
        return pool.map(compute_excitations, scenes)
