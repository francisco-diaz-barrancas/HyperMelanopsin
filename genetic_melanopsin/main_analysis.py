import os
import numpy as np
import scipy.io as sio
from compute_excitations import compute_excitations
from compute_field_variables import compute_field_variables
from scipy.optimize import differential_evolution

# tqdm opcional para barras de progreso
try:
    from tqdm import tqdm
except ImportError:
    def tqdm(x, **kwargs):
        return x

# Pedir al usuario el nombre de la carpeta "place"
place = input("Introduce el nombre de 'place' (por ejemplo, Nogueiro): ").strip()
data_dir = os.path.join(f"data_{place}")
if not os.path.isdir(data_dir):
    raise FileNotFoundError(f"No existe la carpeta de datos: {data_dir}")

files = [f for f in os.listdir(data_dir) if f.endswith('.mat')]
if not files:
    raise FileNotFoundError(f"No se encontraron archivos .mat en {data_dir}")


# Parámetros fisiológicos
fsize_ipRGC = 1.37
fsize_midget = 0.07
fsize_sbistr = 0.52
fm = 0.5 * 0.333
fl = 0.5 * 0.667
k_s = -0.5
k_l = -0.3

sections = [f'Q{i}' for i in range(1, 17)]

# Parámetros de DE
popsize = 6
maxiter = 10
bounds = [(0.1, 2.0), (0.1, 2.0)]  # (fi, fs)

# Contadores
gen_idx = {'n': 0}        # generación actual (0-based)
eval_in_gen = {'n': 0}    # evaluaciones dentro de la generación

def objective(params):
    fi_, fs_ = params
    eval_in_gen['n'] += 1
    current_gen = gen_idx['n'] + 1
    print(f"\n⏳ Evaluación {eval_in_gen['n']} (Gen {current_gen}): fi={fi_:.4f}, fs={fs_:.4f}")

    n_sec = len(sections)
    n_files = len(files)
    LocalipOut = np.empty((n_sec, n_files))
    LocalsOut  = np.empty_like(LocalipOut)
    LocallOut  = np.empty_like(LocalipOut)

    for j, fname in enumerate(tqdm(files, desc="Procesando escenas", leave=False)):
        data = sio.loadmat(os.path.join(data_dir, fname))
        scene = data.get('hsi', data.get('absolute'))
        h, w = scene.shape[:2]
        msize_deg = np.array([5.3, 6.9]) * 2

        df_px_ip  = fsize_ipRGC / msize_deg[0] * h
        df_px_mid = round(fsize_midget / msize_deg[0] * h)
        df_px_sb  = round(fsize_sbistr / msize_deg[0] * h)

        h4, w4 = h // 4, w // 4

        for i in range(n_sec):
            y0 = (i // 4) * h4
            x0 = (i % 4) * w4
            patch = scene[y0:y0+h4, x0:x0+w4, :]

            excit = compute_excitations(patch)

            # ipRGC
            LMmel = fm*excit['SMLRG'][:,:,1] + fl*excit['SMLRG'][:,:,2] + fi_*excit['SMLRG'][:,:,4]
            S     = excit['SMLRG'][:,:,0]
            r_ip  = compute_field_variables(LMmel, df_px_ip)
            r_S   = compute_field_variables(S,     df_px_ip)
            LocalipOut[i, j] = r_ip['localExc'] - fs_ * r_S['localExc']

            # midget (L/(L+M))
            Lr = excit['lsrg'][:,:,0]
            r_l = compute_field_variables(Lr, df_px_mid)
            LocallOut[i, j] = r_l['localExc']

            # small bi-stratified (S/(L+M))
            Sr = excit['lsrg'][:,:,1]
            r_s = compute_field_variables(Sr, df_px_sb)
            LocalsOut[i, j] = r_s['localExc']

    s_ip = k_s * LocalipOut + LocalsOut
    l_ip = k_l * LocalipOut + LocallOut

    std_s = np.nanmedian(np.nanstd(s_ip, axis=1))
    std_l = np.nanmedian(np.nanstd(l_ip, axis=1))
    return std_s + std_l

# Callback tras cada generación
def gen_callback(xk, convergence):
    gen_idx['n']   += 1
    eval_in_gen['n'] = 0
    fi_, fs_ = xk
    print(f"🏁 Generación {gen_idx['n']:2d} completada: fi={fi_:.4f}, fs={fs_:.4f}, conv={convergence:.2e}")
    return False  # seguir iterando

print("\n🔍 Iniciando optimización genética (puede tardar)...")
result = differential_evolution(
    objective,
    bounds,
    strategy='best1bin',
    maxiter=maxiter,
    popsize=popsize,
    tol=1e-3,
    callback=gen_callback,
    disp=False
)

opt_fi, opt_fs = result.x
print("\n✅ Mejores parámetros encontrados:")
print(f"fi = {opt_fi:.4f}")
print(f"fs = {opt_fs:.4f}")
print(f"Valor objetivo (std_s + std_l) = {result.fun:.4f}")
