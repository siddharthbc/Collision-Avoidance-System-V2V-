
import os, sys
if 'SUMO_HOME' in os.environ:
     tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
     sys.path.append(tools)
else:
     sys.exit("please declare environment variable 'SUMO_HOME'")



sumoBinary = "C:/Program Files (x86)/DLR/Sumo/bin/sumo-gui"
sumoCmd = [sumoBinary, "-c", "C:/Users/Siddharth/Desktop/Sumo_Files/hello1.sumocfg"]


import traci
traci.start(sumoCmd)



step = 0
while step < 1000:
   traci.simulationStep()
   allvehicles = traci.vehicle.getIDList()
   print(allvehicles)
   if step == 1:
       traci.vehicle.setSpeed(vehID = "veh0", speed = 2)
       traci.vehicle.setSpeedMode(vehID="veh0", sm=0)
       traci.vehicle.setSpeed(vehID = "veh1", speed = 2)
       traci.vehicle.setSpeedMode(vehID="veh1", sm=0)



   if step > 1:
       dis = traci.vehicle.getDistance(vehID= "veh0")
       if (dis <= 230 or dis > 255):
           fo = open("sumo.txt", "w")
           fo.write("0")
           fo.close()
       if (dis >230 and dis <=254):
           fo = open("sumo.txt", "w")
           fo.write("1")
           fo.close()

       fo = open("sumo.txt", "r")
       str = fo.read()
       if str == "1":
           traci.vehicle.setSpeed(vehID = "veh1", speed = 0)
       if str == "0":
           traci.vehicle.setSpeed(vehID = "veh1", speed = 2)
       fo.close()


   step += 1



traci.close()


