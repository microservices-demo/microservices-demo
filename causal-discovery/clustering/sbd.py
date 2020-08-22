import numpy as np
from numpy.linalg import norm
from numpy.fft import fft, ifft
from sklearn.metrics import silhouette_score as _silhouette_score

def sbd(x, y):
    ncc = _ncc_c(x, y)
    idx = ncc.argmax()
    dist = 1 - ncc[idx]
    if dist < 0:
        return 0
    else:
        return dist

def _ncc_c(x, y):
    den = np.array(norm(x) * norm(y))
    den[den == 0] = np.Inf
    x_len = len(x)
    fft_size = 1<<(2*x_len-1).bit_length()
    cc = ifft(fft(x, fft_size) * np.conj(fft(y, fft_size)))
    cc = np.concatenate((cc[-(x_len-1):], cc[:x_len]))
    return np.real(cc) / den

def silhouette_score(data, labels):
    distances = np.zeros((data.shape[0], data.shape[0]))
    for idx_a, data_a in enumerate(data):
        for idx_b, data_b in enumerate(data):
            if idx_a == idx_b:
                distances[idx_a, idx_b] = 0
                continue
            distances[idx_a, idx_b] = sbd(data_a, data_b)
    return _silhouette_score(distances, labels, metric='precomputed')
