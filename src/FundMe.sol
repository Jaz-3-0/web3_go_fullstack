// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface";

import { PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    using PriceConverter for uint256;


        uint256 public minimumUsd = 50 * 1e18;

        address[] public funders;

        mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {

        // Want to be able to set a minimum fund amount in USD
        require(msg.value.getConversionRate() > minimumUsd, "Didn't send enough funds");     
        funders.push(msg.sender);   
        addressToAmountFunded[msg.sender] = msg.value;
    }
    function withdraw() public {
        /** starting index, ending index, step amount */
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // reset array
        funders = new address[](0); 

        // Actually withdraw funds

        // transfer
        payable(msg.sender).transfer(address(this).balance);
        // send
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Send Failed");
        // call
        (bool callSuccess, bytes dataReturned) = payable(msg.sender).call{value: address(this).balance}("")
        


    }
}