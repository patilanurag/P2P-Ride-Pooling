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
        address payable riderAddress;
        coordinates source;
        coordinates destination;
        bool allowPooling;
    }

    struct driver {
        uint idd;
        userType uType;
        address payable driverAddress;
        coordinates currentLocation;
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
        riderAddressMapping[msg.sender].riderAddress = payable(msg.sender);
        riderAddressMapping[msg.sender].source.latitude = slat;
        riderAddressMapping[msg.sender].source.longitude = slong;
        riderAddressMapping[msg.sender].destination.latitude = dlat;
        riderAddressMapping[msg.sender].destination.latitude = dlong;
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
    }

    function selectRide() public {

    }


}
