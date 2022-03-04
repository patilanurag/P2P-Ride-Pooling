// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract RidePool{

    constructor () {

    }

    enum userType {RIDER, DRIVER}

    struct coordinates {
        int256 latitude;
        int256 longitude;
    }

    struct rider {
        int idr;
        address payable riderAddress;
        coordinates source;
        coordinates destination;
        bool allowPooling;
    }

    struct driver {
        int idd;
        address payable driverAddress;
        coordinates currentLocation;
    }
    

    mapping(address=>rider) riderAddressMapping;
    mapping(address=>driver) driverAddressMapping;
    // mapping(address=>driver) driverAddressMapping;
    address [] public driversList;
    address [] public ridersList;

    function requestRide() public {
        // select source and destination

    }

    function selectRide() public {

    }

}
