# This code was implemented with reference to sieve-microservices/scalegraph-scripts.
# Ref: https://github.com/sieve-microservices/scalegraph-scripts/blob/master/metricsnamecluster.py

import numpy as np
from scipy.cluster.hierarchy import fcluster, linkage

def jaro_distance(ying, yang):
    if isinstance(ying, bytes) or isinstance(yang, bytes):
        raise TypeError(_no_bytes_err)

    ying_len = len(ying)
    yang_len = len(yang)

    if not ying_len or not yang_len:
        return 0

    min_len = max(ying_len, yang_len)
    search_range = (min_len // 2) - 1
    if search_range < 0:
        search_range = 0

    ying_flags = [False]*ying_len
    yang_flags = [False]*yang_len

    # looking only within search range, count & flag matched pairs
    common_chars = 0
    for i, ying_ch in enumerate(ying):
        low = i - search_range if i > search_range else 0
        hi = i + search_range if i + search_range < yang_len else yang_len - 1
        for j in range(low, hi+1):
            if not yang_flags[j] and yang[j] == ying_ch:
                ying_flags[i] = yang_flags[j] = True
                common_chars += 1
                break

    # short circuit if no characters match
    if not common_chars:
        return 0

    # count transpositions
    k = trans_count = 0
    for i, ying_f in enumerate(ying_flags):
        if ying_f:
            for j in range(k, yang_len):
                if yang_flags[j]:
                    k = j + 1
                    break
            if ying[i] != yang[j]:
                trans_count += 1
    trans_count /= 2

    # adjust for similarities in nonmatched characters
    common_chars = float(common_chars)
    weight = ((common_chars/ying_len + common_chars/yang_len +
              (common_chars-trans_count) / common_chars)) / 3
    return weight

def cluster_words(words, service_name, size):
    stopwords = ["GET", "POST", "total", "http-requests", service_name, "-", "_"]
    cleaned_words = []
    for word in words:
        for stopword in stopwords:
            word = word.replace(stopword, "")
        cleaned_words.append(word)
    def distance(coord):
        i, j = coord
        return 1 - jaro_distance(cleaned_words[i], cleaned_words[j])
    indices = np.triu_indices(len(words), 1)
    distances = np.apply_along_axis(distance, 0, indices)
    z = linkage(distances)
    labels = fcluster(z, t=size, criterion='maxclust')
    return labels
