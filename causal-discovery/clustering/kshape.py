# This code was copied from sieve-microservices/scalegraph-scripts.
# Ref: https://github.com/sieve-microservices/scalegraph-scripts/blob/master/kshape.py

import math
import numpy as np

from numpy.random import randint, seed
from numpy.linalg import norm, eigh
from numpy.linalg import norm
from numpy.fft import fft, ifft


def zscore(a, axis=0, ddof=0):
    a = np.asanyarray(a)
    mns = a.mean(axis=axis)
    sstd = a.std(axis=axis, ddof=ddof)
    if axis and mns.ndim < a.ndim:
        res = (((a - np.expand_dims(mns, axis=axis)) /
                np.expand_dims(sstd,axis=axis)))
    else:
        res = (a - mns) / sstd
    return np.nan_to_num(res)


def roll_zeropad(a, shift, axis=None):
    a = np.asanyarray(a)
    if shift == 0: return a
    if axis is None:
        n = a.size
        reshape = True
    else:
        n = a.shape[axis]
        reshape = False
    if np.abs(shift) > n:
        res = np.zeros_like(a)
    elif shift < 0:
        shift += n
        zeros = np.zeros_like(a.take(np.arange(n-shift), axis))
        res = np.concatenate((a.take(np.arange(n-shift,n), axis), zeros), axis)
    else:
        zeros = np.zeros_like(a.take(np.arange(n-shift,n), axis))
        res = np.concatenate((zeros, a.take(np.arange(n-shift), axis)), axis)
    if reshape:
        return res.reshape(a.shape)
    else:
        return res

def _ncc_c(x, y):
    """
    >>> _ncc_c([1,2,3,4], [1,2,3,4])
    array([ 0.13333333,  0.36666667,  0.66666667,  1.        ,  0.66666667,
            0.36666667,  0.13333333])
    >>> _ncc_c([1,1,1], [1,1,1])
    array([ 0.33333333,  0.66666667,  1.        ,  0.66666667,  0.33333333])
    >>> _ncc_c([1,2,3], [-1,-1,-1])
    array([-0.15430335, -0.46291005, -0.9258201 , -0.77151675, -0.46291005])
    """
    den = np.array(norm(x) * norm(y))
    den[den == 0] = np.Inf

    x_len = len(x)
    fft_size = 1<<(2*x_len-1).bit_length()
    cc = ifft(fft(x, fft_size) * np.conj(fft(y, fft_size)))
    cc = np.concatenate((cc[-(x_len-1):], cc[:x_len]))
    return np.real(cc) / den

def lag(x, y):
    return ((_ncc_c(x, y).argmax() + 1) - max(len(x), len(y))) * -1

def _sbd(x, y):
    """
    >>> _sbd([1,1,1], [1,1,1])
    (-2.2204460492503131e-16, array([1, 1, 1]))
    >>> _sbd([0,1,2], [1,2,3])
    (0.043817112532485103, array([1, 2, 3]))
    >>> _sbd([1,2,3], [0,1,2])
    (0.043817112532485103, array([0, 1, 2]))
    """
    ncc = _ncc_c(x, y)
    idx = ncc.argmax()
    dist = 1 - ncc[idx]
    yshift = roll_zeropad(y, (idx + 1) - max(len(x), len(y)))

    return dist, yshift


def _extract_shape(idx, x, j, cur_center):
    """
    >>> _extract_shape(np.array([0,1,2]), np.array([[1,2,3], [4,5,6]]), 1, np.array([0,3,4]))
    array([-1.,  0.,  1.])
    >>> _extract_shape(np.array([0,1,2]), np.array([[-1,2,3], [4,-5,6]]), 1, np.array([0,3,4]))
    array([-0.96836405,  1.02888681, -0.06052275])
    >>> _extract_shape(np.array([1,0,1,0]), np.array([[1,2,3,4], [0,1,2,3], [-1,1,-1,1], [1,2,2,3]]), 0, np.array([0,0,0,0]))
    array([-1.2089303 , -0.19618238,  0.19618238,  1.2089303 ])
    >>> _extract_shape(np.array([0,0,1,0]), np.array([[1,2,3,4],[0,1,2,3],[-1,1,-1,1],[1,2,2,3]]), 0, np.array([-1.2089303,-0.19618238,0.19618238,1.2089303]))
    array([-1.19623139, -0.26273649,  0.26273649,  1.19623139])
    """
    _a = []
    for i in range(len(idx)):
        if idx[i] == j:
            if cur_center.sum() == 0:
                opt_x = x[i]
            else:
                _, opt_x = _sbd(cur_center, x[i])
            _a.append(opt_x)
    a = np.array(_a)

    if len(a) == 0:
        return np.zeros((1, x.shape[1]))
    columns = a.shape[1]
    y = zscore(a,axis=1,ddof=1)
    s = np.dot(y.transpose(), y)

    p = np.empty((columns, columns))
    p.fill(1.0/columns)
    p = np.eye(columns) - p

    # these are the 2 most expensive operations
    m = np.dot(np.dot(p, s), p)
    _, vec = eigh(m)
    centroid = vec[:,-1]
    finddistance1 = math.sqrt(((a[0] - centroid) ** 2).sum())
    finddistance2 = math.sqrt(((a[0] + centroid) ** 2).sum())

    if finddistance1 >= finddistance2:
        centroid *= -1

    return zscore(centroid, ddof=1)


def _kshape(x, k, initial_clustering=None):
    """
    >>> from numpy.random import seed; seed(0)
    >>> _kshape(np.array([[1,2,3,4], [0,1,2,3], [-1,1,-1,1], [1,2,2,3]]), 2)
    (array([0, 0, 1, 0]), array([[-1.2244258 , -0.35015476,  0.52411628,  1.05046429],
           [-0.8660254 ,  0.8660254 , -0.8660254 ,  0.8660254 ]]))
    """
    m = x.shape[0]
    if initial_clustering is not None:
        assert len(initial_clustering) == m, "Initial assigment does not match column length"
        idx = initial_clustering
    else:
        idx = randint(0, k, size=m)
    centroids = np.zeros((k,x.shape[1]))
    distances = np.empty((m, k))

    for _ in range(100):
        old_idx = idx
        for j in range(k):
            centroids[j] = _extract_shape(idx, x, j, centroids[j])

        for i in range(m):
             for j in range(k):
                 distances[i,j] = 1 - max(_ncc_c(x[i], centroids[j]))
        idx = distances.argmin(1)
        if np.array_equal(old_idx, idx):
            break

    return idx, centroids

def kshape(x, k, initial_clustering=None):
    idx, centroids = _kshape(np.array(x), k, initial_clustering)
    clusters = []
    for i, centroid in enumerate(centroids):
        series = []
        for j, val in enumerate(idx):
            if i == val:
                series.append(j)
        clusters.append((centroid, series))
    return clusters

if __name__ == "__main__":
    import doctest
    doctest.testmod()
