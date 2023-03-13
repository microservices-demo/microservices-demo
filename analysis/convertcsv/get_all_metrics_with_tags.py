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
    print(get_all_metrics_with_tags(r"F:\Master\Kubernetes\sockshop\microservices-demo\query\automated\generated_csvs"))