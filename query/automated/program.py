import subprocess
import json
import collection
import random
import time
from datetime import datetime
RUN_TIME = 10
DEFAULT_SPAWNRATE = 50
DEFAULT_STEP = 5
LOCUSTFILE_COMPLETE_LOCATION = "F:/Master/Kubernetes/sockshop/microservices-demo/locustfiles"
TAGS_AND_AMOUNTS_LOCATION = "F:/Master/Kubernetes/sockshop/microservices-demo/query/automated/tags_and_amounts.json"
def cmd(cmd):
    completed = subprocess.run(["powershell", "-Command", cmd], capture_output=True, encoding='utf-8')
    
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
    :param int runtime: How long it runs, in minutes
    :param str tags: space separated string of tags to execute
    :param str fileLocation: path to directory with the relevant locustfile
    """
    base = "docker run -p 8089:8089 --rm --name {} --mount type=bind,source={},target=/mnt/locust locustio/locust -f /mnt/locust/locustfile_complete.py --headless -u {} -r {} --run-time {}m --host http://host.docker.internal --tags {}"
    #name =  str(users) + str(spawnrate) + str(runtime) + str(tags)
    name = buildName(users,spawnrate, runtime)
    return base.format(name, fileLocation, users, spawnrate, str(runtime), tags)

def buildName(users, spawnrate, runtime):
    return  "" + str(users) + "U_" + str(spawnrate) + "R_" + str(runtime) 

def main(runtime=RUN_TIME):
    """
    Have folders for every tag and combination of tags. Then run generators on
    data with the different tags.
    Do 10 minute intervals
    """
    jsonfile = open(TAGS_AND_AMOUNTS_LOCATION)
    tags_and_amounts = json.load(jsonfile)

    runs = int(input("Amount of runs: integer only"))

    for x in range(runs):
        setLoop(tags_and_amounts, runtime)

    # for tag in tags_and_amounts["tags"]:

    #     command = buildCommand(400, 20, "10m",tag,LOCUSTFILE_COMPLETE_LOCATION)

    #     result = cmd(command)
    #     print(result)
    #     time.sleep(15)
    #     collection.collection(11, 5, "./metrics.json","400U_20R_10m",tag)



def setLoop(tags_and_amounts, runtime):

    now = datetime.now()
    now_unix = time.mktime(now.timetuple())

    for tag in tags_and_amounts["tags"]:
        for amount in tags_and_amounts["amount_list"]:
            command = buildCommand(amount, DEFAULT_SPAWNRATE, runtime, tag, LOCUSTFILE_COMPLETE_LOCATION)
            print("Running Locust with tag " + tag + " with " + str(amount) + " users")
            print("command: ", command)
            result = cmd(command)
            if result.stderr:
                with open("Print_output.txt","a") as outputfile:
                    outputfile.write(str(result.stderr))
                    outputfile.close()
            
            time.sleep(15)
            collection.collection(RUN_TIME+1, DEFAULT_STEP, "./metrics.json", now_unix,tag, now_unix)

def setloop_random(tags_and_amounts, runtime):
    now = datetime.now()
    now_unix = time.mktime(now.timetuple())

    for tag in tags_and_amounts["tags"]:
        amount = random.randint(tags_and_amounts["lower_bound_users"],tags_and_amounts["upper_bound_users"])
        
        command = buildCommand(amount, DEFAULT_SPAWNRATE, runtime, tag, LOCUSTFILE_COMPLETE_LOCATION)
        print("Running Locust with tag " + tag + " with " + str(amount) + " users")
        print("command: ", command)
        result = cmd(command)
        if result.stderr:
            with open("Print_output.txt","a") as outputfile:
                outputfile.write(str(result.stderr))
                outputfile.close()
        
        time.sleep(15)
        collection.collection(RUN_TIME+1, DEFAULT_STEP, "./metrics.json", "rand " + now_unix + "_" + amount,tag, now_unix)


if __name__ == "__main__":
    main()