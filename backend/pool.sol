// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract RidePool{

    uint riderCounter = 0;

    uint driverCounter = 0;

    constructor () {

    }

    enum userType {RIDER, DRIVER}

    struct coordinates {
        int256 latitude;
        int256 longitude;
    }

    struct rider {
        uint idr;
        userType uType;
        address riderAddress;
        coordinates source;
        coordinates destination;
        bool pickedUp;
        bool droppedOff;
        bool allowPooling;
    }

    struct driver {
        uint idd;
        userType uType;
        address payable driverAddress;
        coordinates currentLocation;
        bool occupied;
    }
    

    mapping(address=>rider) riderAddressMapping;
    mapping(address=>driver) driverAddressMapping;
    // mapping(address=>driver) driverAddressMapping;
    address [] public driversList;
    // address [] public ridersList;

    function setRider(int256 slat, int256 slong, int256 dlat, int256 dlong) public {
        // set information related to the rider
        riderCounter++;
        riderAddressMapping[msg.sender].idr = riderCounter;
        riderAddressMapping[msg.sender].uType = userType.RIDER;
        riderAddressMapping[msg.sender].riderAddress = msg.sender;
        riderAddressMapping[msg.sender].source.latitude = slat;
        riderAddressMapping[msg.sender].source.longitude = slong;
        riderAddressMapping[msg.sender].destination.latitude = dlat;
        riderAddressMapping[msg.sender].destination.latitude = dlong;
        riderAddressMapping[msg.sender].pickedUp = false;
        riderAddressMapping[msg.sender].droppedOff = false;
        riderAddressMapping[msg.sender].allowPooling = false;
    }

    function setDriver(int256 clat, int256 clong) public {
        // set information related to the driver
        driverCounter++;
        driverAddressMapping[msg.sender].idd = driverCounter;
        driverAddressMapping[msg.sender].uType = userType.DRIVER;
        driverAddressMapping[msg.sender].driverAddress = payable(msg.sender);
        driverAddressMapping[msg.sender].currentLocation.latitude = clat;
        driverAddressMapping[msg.sender].currentLocation.longitude = clong;
        driverAddressMapping[msg.sender].occupied = false;

        driversList.push(msg.sender);
    }

    function selectRide() public {
        address closestDriver = findClosest(msg.sender);
        driverAddressMapping[closestDriver].occupied = true;
    }

    function findClosest(address riderAddressParam) view private returns (address) {
        uint256 dListLength = driversList.length;

        int256 rSLat = riderAddressMapping[riderAddressParam].source.latitude;
        int256 rSLong = riderAddressMapping[riderAddressParam].source.longitude;

        int256 compare = 99999999999999;
        address closestDriver = 0x0000000000000000000000000000000000000000;

        for (uint256 i = 0; i < dListLength; i++){
            address currDriverAddress = driversList[i];
            
            if (driverAddressMapping[currDriverAddress].occupied == false){

                int256 dCLat = driverAddressMapping[currDriverAddress].currentLocation.latitude;
                int256 dCLong =  driverAddressMapping[currDriverAddress].currentLocation.longitude;
                int256 distRD = manhattanDistance(rSLat, rSLong, dCLat, dCLong);

                if (compare > distRD){
                    compare = distRD;
                    closestDriver = currDriverAddress;
                }
            }
        }
        return closestDriver;
    }

    function manhattanDistance(int256 slat, int256 slong, int256 dlat, int256 dlong) pure private returns (int256){
        int256 latF = slat - dlat;
        int256 longF = slong - dlong;
        if (latF < 0) {latF = -latF;}
        if (longF < 0) {longF = -longF;}
        return latF+longF;
    }

}
