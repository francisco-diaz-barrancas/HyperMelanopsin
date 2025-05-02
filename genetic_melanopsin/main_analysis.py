import os
import numpy as np
import scipy.io as sio
from compute_excitations import compute_excitations
from compute_field_variables import compute_field_variables
from scipy.optimize import differential_evolution

# Si tienes tqdm, muestra progreso; si no, no falla
try:
    from tqdm import tqdm
except ImportError:
    def tqdm(x, **kwargs):
        return x

place = 'Nogueiro'
data_dir = os.path.join('data_' + place)
files = [f for f in os.listdir(data_dir) if f.endswith('.mat')]

# Parámetros fisiológicos
fsize_ipRGC = 1.37
fsize_midget = 0.07
fsize_sbistr = 0.52
fm = 0.5 * 0.333
fl = 0.5 * 0.667
k_s = -0.5
k_l = -0.3

sections = [f'Q{i}' for i in range(1, 17)]

def objective(params):
    fi_, fs_ = params
    LocalipOut = np.empty((len(sections), len(files)))
    LocalsOut  = np.empty_like(LocalipOut)
    LocallOut  = np.empty_like(LocalipOut)

    for j, fname in enumerate(files):
        data = sio.loadmat(os.path.join(data_dir, fname))
        scene = data.get('hsi', data.get('absolute'))
        msize_px = scene.shape[:2]
        msize_deg = np.array([5.3, 6.9]) * 2

        df_px_ip  = fsize_ipRGC / msize_deg[0] * msize_px[0]
        df_px_mid = round(fsize_midget / msize_deg[0] * msize_px[0])
        df_px_sb  = round(fsize_sbistr / msize_deg[0] * msize_px[0])

        h, w  = msize_px
        h4, w4 = h // 4, w // 4

        for i in range(len(sections)):
            y0 = (i // 4) * h4
            x0 = (i % 4) * w4
            patch = scene[y0:y0+h4, x0:x0+w4, :]

            excit = compute_excitations(patch)

            # ipRGC
            LMmel = fm*excit['SMLRG'][:,:,1] + fl*excit['SMLRG'][:,:,2] + fi_*excit['SMLRG'][:,:,4]
            S     = excit['SMLRG'][:,:,0]
            r_ip  = compute_field_variables(LMmel, df_px_ip)
            r_S   = compute_field_variables(S, df_px_ip)
            LocalipOut[i, j] = r_ip['localExc'] - fs_ * r_S['localExc']

            # Midget (L/(L+M))
            Lr = excit['lsrg'][:,:,0]
            r_l = compute_field_variables(Lr, df_px_mid)
            LocallOut[i, j] = r_l['localExc']

            # SBistratified (S/(L+M))
            Sr = excit['lsrg'][:,:,1]
            r_s = compute_field_variables(Sr, df_px_sb)
            LocalsOut[i, j] = r_s['localExc']

    s_ip = k_s * LocalipOut + LocalsOut
    l_ip = k_l * LocalipOut + LocallOut

    std_s = np.nanmedian(np.nanstd(s_ip, axis=1))
    std_l = np.nanmedian(np.nanstd(l_ip, axis=1))
    return std_s + std_l

# Callback para mostrar el mejor candidato al final de cada generación
gen = {'idx': 0}
def gen_callback(xk, convergence):
    gen['idx'] += 1
    fi_, fs_ = xk
    print(f"🏁 Generación {gen['idx']:2d}: fi={fi_:.4f}, fs={fs_:.4f}, conv={convergence:.2e}")
    return False  # continuar

print("\n🔍 Iniciando optimización genética (puede tardar)...")
bounds = [(0.1, 2.0), (0.1, 2.0)]  # (fi, fs)

result = differential_evolution(
    objective,
    bounds,
    strategy='best1bin',
    maxiter=10,
    popsize=6,
    tol=1e-3,
    callback=gen_callback,
    disp=False
)

opt_fi, opt_fs = result.x
print("\n✅ Mejores parámetros encontrados:")
print(f"fi = {opt_fi:.4f}")
print(f"fs = {opt_fs:.4f}")
print(f"Valor objetivo (std_s + std_l) = {result.fun:.4f}")
