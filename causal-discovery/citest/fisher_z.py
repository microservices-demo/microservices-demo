import numpy as np
from scipy.stats import norm

def ci_test_fisher_z(data_matrix, x, y, s, **kwargs):
    assert 'corr_matrix' in kwargs
    cm = kwargs['corr_matrix']
    n = data_matrix.shape[0]
    z = zstat(x, y, list(s), cm, n)
    p_val = 2.0 * norm.sf(np.absolute(z))
    return p_val

def zstat(x, y, s, cm, n):
    r = pcor_order(x, y, s, cm)
    zv = np.sqrt(n - len(s) - 3) * 0.5 * log_q1pm(r)
    if np.isnan(zv):
        return 0
    else:
        return zv

def log_q1pm(r):
    if r == 1:
        r = 1 - 1e-10
    return np.log1p(2 * r / (1 - r))

def pcor_order(x, y, s, cm):
    if len(s) == 0:
        return cm[x, y]
    else:
        pim = np.linalg.pinv(cm[[x, y] + s, :][:, [x, y] + s])
        return -pim[0, 1] / np.sqrt(pim[0, 0] * pim[1, 1])


