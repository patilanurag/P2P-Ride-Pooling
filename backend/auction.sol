// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

contract Auction {
    address payable public beneficiary;

    // Current state of the auction. You can create more variables if needed
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    constructor () {
        beneficiary = payable(msg.sender);
    }

    function bid() public payable {
        require(msg.value > highestBid);
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint returningBid = pendingReturns[msg.sender];
        if (returningBid > 0) {
            pendingReturns[msg.sender] = 0; // Re-entrancy is handled.
            if (!(payable(msg.sender).send(returningBid))) {
                pendingReturns[msg.sender] = returningBid;
                return false;
            }
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
        require(beneficiary == msg.sender);

        beneficiary.transfer(highestBid);
    }
}
