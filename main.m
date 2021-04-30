% close and clear everything running in the command window
clc;
clear all;
close all;
% Initialize transmission range
transRange = 250;
% Initialize number of nodes
numNodes = 100;
% Initialize minimum range of x,y,z co-ordinates of the network plot00000
min.x = 0;
min.y = 0;
min.z = 0;
% Initialize maximum range of x,y,z co-ordinates of the network plot
max.x = 1000;
max.y = 1000;
max.z = -1000;
% Initialize x,y,z co-ordinates for six sinks including two embedded sinks
% embedded sink 1
sink(1,1)=250;
sink(1,2)=250;
sink(1,3)=0;
% embedded sink 2
sink(2,1)=250;
sink(2,2)=0;
sink(2,3)=250;
% sink 3
sink(3,1)=100;
sink(3,2)=1000;
sink(3,3)=100;
% sink 4
sink(4,1)=250;
sink(4,2)=1000;
sink(4,3)=250;
% sink 5
sink(5,1)=750;
sink(5,2)=100;
sink(5,3)=500;
% sink 6
sink(6,1)=500;
sink(6,2)=500;
sink(6,3)=500;
% Plot nodes randomly using createNodes function
nodePositions = createNodes(min, max, numNodes);
plot3(nodePositions(:, 1), nodePositions(:, 2),nodePositions(:, 3), '+');
hold on
% Plot sink nodes
plot3(sink(1, 1), sink(1, 2), sink(1, 3), 'S', 'MarkerFaceColor', 'y');
plot3(sink(2, 1), sink(2, 2), sink(2, 3), 'S', 'MarkerFaceColor', 'y');
plot3(sink(3, 1), sink(3, 2), sink(3, 3), 'S', 'MarkerFaceColor', 'r');
plot3(sink(4, 1), sink(4, 2), sink(4, 3), 'S', 'MarkerFaceColor', 'r');
plot3(sink(5, 1), sink(5, 2), sink(5, 3), 'S', 'MarkerFaceColor', 'r');
plot3(sink(6, 1), sink(6, 2), sink(6, 3), 'S', 'MarkerFaceColor', 'r');
% Initialize lost packets and average time taken for one packet delivery as zero
lostPackets = 0;
avgTime = 0;
% Initialize t1 to current starting time
t1 = clock;
% loop for transmitting one packet from each node to a sink node
% for i = 1 to numNodes
for i=1:numNodes
% Initialize an empty list for visited nodes
visitedNodes = [];
% Initialize source as ith node and forwarder node as the source
source = i;
forwarder = source;
fprintf('Node %d \n', i);
% find the route of the packet from the ith node to any of the sink node using the function
% find_route function returns neighbours of the given node, delivery status (success/failure) and nearest node of the neighbors, this function takes forwarder node, sink nodes, transmission range, number of nodes, nodes positions and visited nodes list as parameters
[neighbours, success, nearestNode] = find_route (forwarder, sink, transRange, numNodes, nodePositions, visitedNodes);
% Add source to visited nodes list
visitedNodes(end+1) = source;
% if the ith node could not find a sink node in its transmission range
% while packet status is undelivered or neighbors list is empty
while (success == 0 || isempty(neighbours) == 0)
% change forwarder to the nearest node obtained previously
forwarder = nearestNode;
% if forwarder is unreachable, packet is said to be lost and break the loop
if (forwarder == Inf)
success = 0;
disp('Packet Lost')
lostPackets = lostPackets + 1;
break;
end
% Add forwarder node to visited nodes list
visitedNodes(end+1) = forwarder;
% Find the route for the ith packet from the new forwarder to any of the sinks
[neighbours, success, nearestNode] = find_route (forwarder, sink, transRange, numNodes, nodePositions, visitedNodes);
end
% display the whole route of the packet transmitted from the ith node
disp('Route in which the packet travelled:')
disp(visitedNodes)
% note the time t2 for ith packet transmission time
t2 = clock;
e = etime(t2,t1);
% calculate average delay of one packet transmission
avgTime = (avgTime + e)/ i;
end
% display average end to end delay for a packet transmission in milliseconds
fprintf("Average end to end delay = %f ms \n", avgTime*1000)
% note the ending time after all the packets transmission
t3 = clock;
totalTime = etime(t3,t1);
% calculate number of packets delivered
packetsDelivered = numNodes - lostPackets;
% initialize average packet size and convert from bytes to bits
averagePacketsize = 80*8;
% calculate throughput and display it in kbps
throughput = (packetsDelivered * averagePacketsize)/totalTime;
fprintf("Throughput = %f kbps \n", throughput/1000)
% calculate packet delivery ratio and display it
pdr = (numNodes - lostPackets)/numNodes;
fprintf('Packet Delivery Ratio = %f \n', pdr);
% function for randomly generating nodes
function [nodePositions]= createNodes(min, max,numNodes)
for i=1:numNodes
nodePositions(i,1) = (rand) * (max.x);
nodePositions(i,2) = (rand) * (max.y);
nodePositions(i,3) = (rand) * (max.z);
end
end
% function for finding route of the packet to any of the sinks, if no sink in the transmission range it returns the nearest node in its range
% find_route function returns neighbours of the given node, delivery status( success/failure) and nearest node of the neighbors, this function takes forwardernode, sink nodes, transmission range, number of nodes, nodes positions and visited nodes list as parameters
function[neighbours, success, nearestNode] = find_route(forwarder, sink, transRange, numNodes, nodePositions, visitedNodes)
% initialize packet status as undelivered (success = 0) and allocate an empty neighbors list
success = 0;
neighbours = [];
index = 1;
% Initialize nearest node and shortestDist to it as infinity
nearestNode = 1/0;
shortestDist = 1/0;
% copy x,y,z co-ordinates of forwarding node
fx = nodePositions(forwarder,1);
fy = nodePositions(forwarder,2);
fz = nodePositions(forwarder,3);
% Check whether any of the sink is in the transmission range
for i=1: 6
sink_x = sink(i,1);
sink_y = sink(i,2);
sink_z = sink(i,3);
% find the distance between forwarder and nearest sink
dst_sink = sqrt((fx- sink_x)^2 + (fy- sink_y)^2 + (fz- sink_z)^2);
if (dst_sink < shortestDist)
shortestDist = dst_sink;
end
% If sink is a neighbour, packet is sent to sink successfully
if( shortestDist <= transRange)
success = 1;
disp('Packet reached at sink node successfully')
return;
end
end
% if there is no sink in the range, find the nearest node in the transmission range
for i=1: numNodes
% if forwarder is ith node, skip the iteration and continue
if (forwarder == i)
continue;
end
% Copy x,y,z co-ordinates of neighbor
x = nodePositions(i,1);
y = nodePositions(i,2);
z = nodePositions(i,3);
% find distance between the forwarder and the ith node
distance = sqrt((fx-x)^2 + (fy-y)^2 + (fz-z)^2);
% if the distance is less than or equal to the transmission range, add the node to the neighbors list
if (distance <= transRange)
neighbours(index)=i;
index = index +1;
% among the neighbors, find the nearest and assign it to nearestNode
neighbours(ismember(neighbours,visitedNodes)) = [];
if (distance < nearestNode & neighbours(ismember(neighbours,i)))
nearestNode = i;
end
end
end
return
end
