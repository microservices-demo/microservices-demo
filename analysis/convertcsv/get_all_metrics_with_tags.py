import os

def get_all_metrics_with_tags(directory:str) -> list:
    """
    Directory should be absolute path
    """
    output = []
    for tag_dir in os.listdir(directory):
        d = os.path.join(directory, tag_dir)
        if os.path.isdir(d):
            for file in os.listdir(d):
                if file.split(".")[-1] == "csv":
                    ospath = os.path.abspath(file)
                    fixed = ospath.replace("\\", "/")
                    output.append((fixed, tag_dir))
                    
    return output
    

if __name__ == "__main__":
    filepath = input("Provide the file path to a directory containing directories with tagged csvs. File structure: One directory, with each subdirectory being named after the csv tag it contains. This program does not care about the individual file names, only folder names. Alternatively leave empty for default location.")
    if filepath == "":
        filepath = r"F:\Master\Kubernetes\sockshop\microservices-demo\query\automated\generated_csvs"
    print(get_all_metrics_with_tags(filepath))
