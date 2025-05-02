import os
import numpy as np
import scipy.io as sio
from multiprocessing import current_process
from compute_excitations import compute_excitations_parallel
from compute_field_variables import compute_field_variables
from scipy.optimize import differential_evolution

# tqdm opcional
try:
    from tqdm import tqdm
except ImportError:
    def tqdm(x, **kwargs): return x

# Constantes fisiológicas
fsize_ipRGC = 1.37
fsize_midget = 0.07
fsize_sbistr = 0.52
fm = 0.5 * 0.333
fl = 0.5 * 0.667
k_s = -0.5
k_l = -0.3
sections = [f"Q{i}" for i in range(1,17)]

# Configuración DE
popsize = 6
maxiter = 10
bounds = [(0.1,2.0),(0.1,2.0)]

# Contadores
call_counter       = 0
calls_at_gen_start = 0
calls_in_last_gen  = 2 * popsize
gen_idx            = 0

# Ruta del log file (se asigna en main)
log_file = None

def append_log(msg: str):
    """Añade una línea al fichero de log."""
    with open(log_file, 'a') as f:
        f.write(msg + '\n')

def objective(params):
    global call_counter
    call_counter += 1

    # Solo en MainProcess
    if current_process().name == "MainProcess":
        eval_num    = call_counter - calls_at_gen_start
        current_gen = gen_idx + 1
        fi_, fs_    = params
        msg = f"Evaluación {eval_num} (Gen {current_gen}): fi={fi_:.4f}, fs={fs_:.4f}"
        print("\n⏳ " + msg)
        append_log(msg)

    # Cálculo de la función objetivo
    n_sec, n_files = len(sections), len(files)
    LocalipOut = np.empty((n_sec, n_files))
    LocalsOut  = np.empty_like(LocalipOut)
    LocallOut  = np.empty_like(LocalipOut)

    for j, fname in enumerate(tqdm(files, desc="Procesando escenas", leave=False)):
        data  = sio.loadmat(os.path.join(data_dir, fname))
        scene = data.get('hsi', data.get('absolute'))
        h, _  = scene.shape[:2]
        mdeg  = np.array([5.3,6.9]) * 2

        df_ip  = fsize_ipRGC / mdeg[0] * h
        df_mid = round(fsize_midget / mdeg[0] * h)
        df_sb  = round(fsize_sbistr / mdeg[0] * h)

        h4, w4 = h//4, _//4

        patches = [
            scene[(i//4)*h4:(i//4)*h4 + h4,
                  (i%4)*w4:(i%4)*w4 + w4, :]
            for i in range(n_sec)
        ]
        evars = compute_excitations_parallel(patches)

        for i, excit in enumerate(evars):
            LMmel = fm*excit['SMLRG'][:,:,1] + fl*excit['SMLRG'][:,:,2] + params[0]*excit['SMLRG'][:,:,4]
            S     = excit['SMLRG'][:,:,0]
            r_ip  = compute_field_variables(LMmel, df_ip)
            r_S   = compute_field_variables(S,     df_ip)
            LocalipOut[i,j] = r_ip['localExc'] - params[1]*r_S['localExc']

            Lr = excit['lsrg'][:,:,0]
            r_l = compute_field_variables(Lr, df_mid)
            LocallOut[i,j] = r_l['localExc']

            Sr = excit['lsrg'][:,:,1]
            r_s = compute_field_variables(Sr, df_sb)
            LocalsOut[i,j] = r_s['localExc']

    s_ip = k_s * LocalipOut + LocalsOut
    l_ip = k_l * LocalipOut + LocallOut

    std_s = np.nanmedian(np.nanstd(s_ip, axis=1))
    std_l = np.nanmedian(np.nanstd(l_ip, axis=1))
    return std_s + std_l

def gen_callback(xk, convergence):
    global gen_idx, calls_at_gen_start, calls_in_last_gen
    calls_in_last_gen   = call_counter - calls_at_gen_start
    calls_at_gen_start  = call_counter
    gen_idx            += 1

    if current_process().name == "MainProcess":
        fi_, fs_ = xk
        msg = (f"Generación {gen_idx:2d} completada: "
               f"fi={fi_:.4f}, fs={fs_:.4f}, conv={convergence:.2e}")
        print("🏁 " + msg)
        append_log(msg)
    return False

if __name__ == "__main__":
    # Entrada de usuario
    place = input("Introduce el nombre de 'place' (p.ej. Nogueiro): ").strip()
    data_dir = f"data_{place}"
    if not os.path.isdir(data_dir):
        raise FileNotFoundError(f"No existe la carpeta: {data_dir}")

    files = [f for f in os.listdir(data_dir) if f.endswith('.mat')]
    if not files:
        raise FileNotFoundError(f"No hay .mat en {data_dir}")

    # Prepara el log file
    log_file = os.path.join(data_dir, "optimization_log.txt")
    # Limpia contenido previo
    open(log_file, 'w').close()
    append_log(f"Inicio de optimización para place = {place}")

    print("\n🔍 Iniciando optimización genética (puede tardar)...")
    append_log("Iniciando optimización genética")

    result = differential_evolution(
        objective, bounds,
        strategy='best1bin',
        maxiter=maxiter,
        popsize=popsize,
        tol=1e-3,
        callback=gen_callback,
        disp=False
    )

    opt_fi, opt_fs = result.x
    final_msg = (f"Mejores parámetros encontrados: fi={opt_fi:.4f}, "
                 f"fs={opt_fs:.4f}, valor objetivo={result.fun:.4f}")
    print("\n✅ " + final_msg)
    append_log(final_msg)
