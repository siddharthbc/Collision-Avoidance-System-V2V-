//
// Copyright (C) 2008 Christoph Sommer <christoph.sommer@informatik.uni-erlangen.de>
//
// Documentation for these modules is at http://veins.car2x.org/
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//;
package org.car2x.veins.nodes;
//package carsproject.src.nodes;
//import org.car2x.veins.base.modules.*;
//import org.car2x.veins.modules.nic.Nic80211p;
import lte.corenetwork.nodes; //changed
import inet.applications.contract.ITCPApp;
import inet.applications.contract.IUDPApp;
import inet.mobility.contract.IMobility;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.contract.IRoutingTable;
import inet.networklayer.contract.INetworkLayer;
import inet.networklayer.configurator.ipv4.HostAutoConfigurator;
import inet.transportlayer.tcp.TCP;
import inet.transportlayer.udp.UDP;
import lte.stack.phy.ILteNic;
import lte.stack.phy.LteNicUe;
import lte.stack.phy.LteNicUeD2D;


module Car
{
    parameters:
     //   string applType; //type of the application layer
        //string nicType = default("Nic80211p"); // type of network interface card
        string veinsmobilityType = default("org.car2x.veins.modules.mobility.traci.TraCIMobility"); //type of the mobility module
	@networkNode();
        @display("i=car.png;bgb=400,518");

        //# Mobility
        //string mobilityType = default("VeinsInetMobility");

        //# Apps
        int numTcpApps = default(0);  // no of TCP apps
        int numUdpApps = default(0);  // no of UDP apps

        //# Node specs
        string nodeType = "UE";  // DO NOT CHANGE
        int masterId;
        int macNodeId = default(0); // TODO: this is not a real parameter
        int macCellId = default(0); // TODO: this is not a real parameter

        //# D2D capability
        bool d2dCapable = default(true); //changed
        string nicType = d2dCapable ? "LteNicUeD2D" : "LteNicUe";

        //# Network Layer specs
        string networkLayerType = default("IPv4NetworkLayer");
        string routingTableType = default("IPv4RoutingTable");
        *.interfaceTableModule = default(absPath(".interfaceTable"));
        *.routingTableModule = default(absPath(".routingTable"));

    gates:
        //input veinsradioIn; // gate for sendDirect
	input radioIn @directIn ;     // connection to master
	
    submodules:
       // appl: <applType> like org.car2x.veins.base.modules.IBaseApplLayer {
         //   parameters:
           //     @display("p=60,50");
       // }
//

//        nic: <nicType> like org.car2x.veins.modules.nic.INic80211p {
//            parameters:
 //               @display("p=60,166");
   //     }

        veinsmobility: <veinsmobilityType> like org.car2x.veins.base.modules.IMobility {
            parameters:
                @display("p=130,172;i=block/cogwheel");
        }
	 interfaceTable: InterfaceTable {
            @display("p=50,75;is=s");
        }
        // routing table
        routingTable: <routingTableType> like IRoutingTable if routingTableType != "" {
            parameters:
                @display("p=50,125;is=s");
        }
        tcpApp[numTcpApps]: <> like ITCPApp {
            @display("p=175,50,row");
        }
        tcp: TCP if numTcpApps>0 {
            @display("p=175,150");
        }
        udpApp[numUdpApps]: <> like IUDPApp {
            @display("p=325,50,row");
        }
        udp: UDP if numUdpApps>0 {
            @display("p=325,150");
        }
        // NOTE: instance must be named "lteNic"
        lteNic: <nicType> like ILteNic {
            nodeType = nodeType;
            d2dCapable = d2dCapable;
            @display("p=250,407");
        }
        // network layer
        networkLayer: <networkLayerType> like INetworkLayer {
            parameters:
                @display("p=250,258");
        }
        configurator: HostAutoConfigurator {
            @display("p=49.068,22.968");
        }
        
    connections allowunconnected:
        //nic.upperLayerOut --> appl.lowerLayerIn;
       // nic.upperLayerIn <-- appl.lowerLayerOut;
       // nic.upperControlOut --> appl.lowerControlIn;
        //nic.upperControlIn <-- appl.lowerControlOut;

    

	 for i=0..numTcpApps-1 {
            tcpApp[i].tcpOut --> tcp.appIn++;
            tcpApp[i].tcpIn <-- tcp.appOut++;
        }

        tcp.ipOut --> networkLayer.transportIn++ if numTcpApps>0;
        tcp.ipIn <-- networkLayer.transportOut++ if numTcpApps>0;

        for i=0..numUdpApps-1 {
            udpApp[i].udpOut --> udp.appIn++;
            udpApp[i].udpIn <-- udp.appOut++;
        }

        udp.ipOut --> networkLayer.transportIn++ if numUdpApps>0;
        udp.ipIn <-- networkLayer.transportOut++ if numUdpApps>0;

        lteNic.radioIn <-- radioIn;

        networkLayer.ifOut++ --> lteNic.upperLayerIn;
        networkLayer.ifIn++ <-- lteNic.upperLayerOut;
}
