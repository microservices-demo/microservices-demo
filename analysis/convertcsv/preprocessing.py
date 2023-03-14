import pandas as pd
from sklearn.preprocessing import StandardScaler


def scale_and_normalize(df:pd.DataFrame) -> pd.DataFrame:
    """
    df: DataFrame with the values needed
    """
    
    scaler = StandardScaler()
