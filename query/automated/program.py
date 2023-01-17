import subprocess
import json
import collection
import random
def cmd(cmd):
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True, universal_newlines=True)
    
    return completed
#Run a test with the same exact duration and interval. One with no load, the other with heavy load. Then perform delta on delta metrics. Include useless metrics for now.
#What does this accomplish?
#See the direct differences between the load and no load. Didnt I already do this before the break with a load vs no load in one test?
#Better to somehow automate data generation.
#Base locust command:
#docker run -p 8089:8089 --name locustfile_complete_rev3 --mount type=bind,source=$pwd/locustfiles,target=/mnt/locust locustio/locust -f /mnt/locust/locustfile_complete.py --headless -u XXX -r XXX

#file: locustfile found in the locustfiles directory
#users: 
def buildCommand(users, spawnrate, runtime, tags, fileLocation) -> str:
    """
    Build locust command

    :param str/int users: amount of users
    :param str/int spawnrate: How fast the threads are spawned
    :param str runtime: How long it runs. Example: 30m
    :param str tags: space separated string of tags to execute
    :param str fileLocation: path to directory with the relevant locustfile
    """
    base = "docker run -p 8089:8089 --rm --name {} --mount type=bind,source={},target=/mnt/locust locustio/locust -f /mnt/locust/locustfile_complete.py --headless -u {} -r {} --run-time {} --host http://host.docker.internal --tags {}"
    #name =  str(users) + str(spawnrate) + str(runtime) + str(tags)
    name = "" + str(users) + "U_" + str(spawnrate) + "R_" + str(runtime) 
    return base.format(name, fileLocation, users, spawnrate, runtime, tags)

def main():
    """
    Have folders for every tag and combination of tags. Then run generators on
    data with the different tags.
    Do 10 minute intervals
    """
    jsonfile = open("F:/Master/Kubernetes/sockshop/microservices-demo/query/automated/tags_and_amounts.json")
    tags_and_amounts = json.load(jsonfile)

    for tag in tags_and_amounts["tags"]:
        command = buildCommand(400, 20, "60s",tag,"F:/Master/Kubernetes/sockshop/microservices-demo/locustfiles")

        result = cmd(command)
        print(result)
        collection.collection(11, 5, "./metrics.json","400U_20R_60s",tag)
       

if __name__ == "__main__":
    main()
