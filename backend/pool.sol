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
        address payable driverAssigned;
        coordinates source;
        coordinates destination;
        bool pickedUp;
        bool droppedOff;
        bool allowPooling;
        uint256 toPay;
        bool paidToDriver;
    }

    struct driver {
        uint idd;
        userType uType;
        address payable driverAddress;
        coordinates currentLocation;
        bool occupied;
        uint fare;
        bool receivedFromRider;
        bool allowPooling;
        uint poolingLimit;
    }
    

    mapping(address=>rider) riderAddressMapping;
    mapping(address=>driver) driverAddressMapping;
    mapping(string=>mapping(string=>string[])) SDAccomodatingLocations; // All locations available from a source to a destination
    mapping(string=>mapping(string=>address)) OccupiedCarpoolDrivers;
    address [] driversList;
    address [] ridersList;
    
    // mapping(driver=>uint256) prices; // Error: Only elementary types, user defined value types, contract types or enums are allowed as mapping keys.

    function setRider(int256 slat, int256 slong, int256 dlat, int256 dlong) public {
        // set information related to the rider
        require(!checkDriverinList(msg.sender)); // Rider's address should not be in driver's list
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
        riderAddressMapping[msg.sender].paidToDriver = false;

        ridersList.push(msg.sender);
    }

    function setDriver(int256 clat, int256 clong) public {
        // set information related to the driver
        require(!checkRiderinList(msg.sender)); // Driver's address should not be in riders list
        driverCounter++;
        driverAddressMapping[msg.sender].idd = driverCounter;
        driverAddressMapping[msg.sender].uType = userType.DRIVER;
        driverAddressMapping[msg.sender].driverAddress = payable(msg.sender);
        driverAddressMapping[msg.sender].currentLocation.latitude = clat;
        driverAddressMapping[msg.sender].currentLocation.longitude = clong;
        // driverAddressMapping[msg.sender].occupied = false;
        driverAddressMapping[msg.sender].poolingLimit = 2;
        // driverAddressMapping[msg.sender].receivedFromRider = false;

        driversList.push(msg.sender);
    }

    // Set Pooling attribute for riders

    function checkRiderinList(address rAddr) view private returns (bool) {
        for (uint i = 0; i<ridersList.length; i++){
            if (ridersList[i] == rAddr) return true;
        }
        return false;
    }

    function setRiderPooling(bool tf) public {
        // require(riderAddressMapping[msg.sender].pickedUp == true);
        require(checkRiderinList(msg.sender));
        riderAddressMapping[msg.sender].allowPooling = tf;
    }

    // Set Pooling attribute for drivers

    function checkDriverinList(address dAddr) view private returns (bool) {
        for (uint i = 0; i<driversList.length; i++){
            if (driversList[i] == dAddr) return true;
        }
        return false;
    }

    function setDriverPooling(bool tf) public {
        require(checkDriverinList(msg.sender));
        driverAddressMapping[msg.sender].allowPooling = tf;
    }

    function selectRide() public payable{
        require(msg.value > 0);
        address closestDriver;
        uint256 dist;
        
        (closestDriver, dist) = assignExistingRide(msg.sender);

        // if ( ) {

        // }
        // else {
        //     (closestDriver, dist) = assignNewRide(msg.sender);
        // }


        // set rider and attributes when s/he is picked up by the driver
        riderAddressMapping[msg.sender].driverAssigned = payable(closestDriver);
        riderAddressMapping[msg.sender].pickedUp = true;
        driverAddressMapping[closestDriver].occupied = true;
        
        // set trip fare for driver and rider
        driverAddressMapping[riderAddressMapping[msg.sender].driverAssigned].fare = msg.value;
        riderAddressMapping[msg.sender].toPay = msg.value;
    }

    function assignExistingRide(address riderAddressParam) private returns (address, uint256){
        uint256 dListLength = driversList.length;

        int256 rSLat = riderAddressMapping[riderAddressParam].source.latitude;
        int256 rSLong = riderAddressMapping[riderAddressParam].source.longitude;

        uint256 compare = 99999999999999;
        address closestDriver = 0x0000000000000000000000000000000000000000;

        /* A. If a ride exists in SDAccomodatingLocations
                1. if rider allows pooling but the driver does not, or if driver allows pooling but the driver does not or both do not allow pooling
                => assign a new rider from a list of available riders (i.e. occupied == false)
                2. else if both rider and driver allow pooling
            B. Else, assign a new driver
        */

        for (uint256 i = 0; i < dListLength; i++){
            address currDriverAddress = driversList[i];
            
            // if (driverAddressMapping[currDriverAddress].occupied == false){
            if(driverAddressMapping[currDriverAddress].poolingLimit > 0){  // Pooling should be availabe in terms of count
                int256 dCLat = driverAddressMapping[currDriverAddress].currentLocation.latitude;
                int256 dCLong =  driverAddressMapping[currDriverAddress].currentLocation.longitude;
                uint256 distRD = manhattanDistance(rSLat, rSLong, dCLat, dCLong);

                if (compare > distRD){
                    compare = distRD;
                    closestDriver = currDriverAddress;
                }
            }
        }
        driverAddressMapping[closestDriver].poolingLimit -= 1;
        return (closestDriver, compare);
    }

    function assignNewRide(address riderAddressParam) private returns (address, uint256) {
        uint256 dListLength = driversList.length;

        int256 rSLat = riderAddressMapping[riderAddressParam].source.latitude;
        int256 rSLong = riderAddressMapping[riderAddressParam].source.longitude;

        uint256 compare = 99999999999999;
        address closestDriver = 0x0000000000000000000000000000000000000000;

        for (uint256 i = 0; i < dListLength; i++){
            address currDriverAddress = driversList[i];
            
            if (driverAddressMapping[currDriverAddress].occupied == false){
                int256 dCLat = driverAddressMapping[currDriverAddress].currentLocation.latitude;
                int256 dCLong =  driverAddressMapping[currDriverAddress].currentLocation.longitude;
                uint256 distRD = manhattanDistance(rSLat, rSLong, dCLat, dCLong);

                if (compare > distRD){
                    compare = distRD;
                    closestDriver = currDriverAddress;
                }
            }
        }
        driverAddressMapping[closestDriver].poolingLimit -= 1;
        return (closestDriver, compare);
    }

    function manhattanDistance(int256 slat, int256 slong, int256 dlat, int256 dlong) pure private returns (uint256){
        uint256 latF = uint256 (slat - dlat >= 0 ? slat - dlat : dlat - slat);
        uint256 longF = uint256 (slong - dlong >= 0 ? slong - dlong : dlong - slong);
        return latF+longF;
    }

    function calculateFare() private {

    }

    function startRide() public {
        riderAddressMapping[msg.sender].pickedUp = true;
        driverAddressMapping[riderAddressMapping[msg.sender].driverAssigned].occupied = true;
    }

    function droppedAtDest() public {
        riderAddressMapping[msg.sender].droppedOff = true;
        riderAddressMapping[msg.sender].pickedUp = false;
        driverAddressMapping[riderAddressMapping[msg.sender].driverAssigned].occupied = false;

        payTheDriver();
    }

    function payTheDriver() private {
        riderAddressMapping[msg.sender].driverAssigned.transfer(riderAddressMapping[msg.sender].toPay);
    }
}
