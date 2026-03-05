// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error FundMe__NotOwner();
error FundMe__CallFailed();

/**
 * @title A demo crowd-funding contract
 * @author Sushobhan Pathare
 * @notice This contract creates a simple crowd funding mechanism
 * @dev This implements Pricefeeds as our library
 */
contract FundMe {
    using PriceConverter for uint256; // We attach the PriceConverter library to all the uint256's.

    uint256 private constant MINIMUM_USD = 5 * 1e18;
    address[] private sFunders;
    mapping(address funder => uint256 amountFunded) private sAddressToAmountFunded;
    address private immutable I_OWNER;
    AggregatorV3Interface private sPriceFeed;

    modifier onlyOwner() {
        //require (msg.sender == I_OWNER , "Sender is not owner!");
        if (msg.sender != I_OWNER) {
            revert FundMe__NotOwner();
        }
        _;
    }

    // Functions Order:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    /// @notice Sets the values for I_OWNER and sPriceFeed on deployment
    /// @param priceFeed address of the Price Feed being used
    constructor(address priceFeed) {
        I_OWNER = msg.sender;
        sPriceFeed = AggregatorV3Interface(priceFeed);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /// @notice Funds our contract based on ETH/USD price
    function fund() public payable {
        require(msg.value.getConversionRate(sPriceFeed) >= MINIMUM_USD, "Didn't send enough ETH");
        sFunders.push(msg.sender);
        sAddressToAmountFunded[msg.sender] += msg.value;
    }

    /// @notice Withdraws funds from the contract
    /// @dev Only the owner of the contract can withdraw successfully
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < sFunders.length; funderIndex++) {
            address funder = sFunders[funderIndex];
            sAddressToAmountFunded[funder] = 0;
        }

        sFunders = new address[](0); //Resetting an array

        //Withdraw the money
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    /// @notice Withdraws funds from the contract in a cheaper way
    /// @dev Explain to a developer any extra details
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = sFunders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = sFunders[funderIndex];
            sAddressToAmountFunded[funder] = 0;
        }

        sFunders = new address[](0);

        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");

        if (!callSuccess) {
            revert FundMe__CallFailed();
        }
    }

    // Getter functions (View and Pure functions)

    /// @notice Gets the current version of the PriceFeed contract
    /// @return version The version
    function getVersion() public view returns (uint256) {
        return sPriceFeed.version();
    }

    /// @notice Gets the funder address
    /// @param index The index of the funder in the sFunders array
    /// @return The funder address
    function getFunders(uint256 index) external view returns (address) {
        return sFunders[index];
    }

    /// @notice Gets the minimum USD value
    /// @return The MINIMUM_USD value
    function getMinimumUsd() external pure returns (uint256) {
        return MINIMUM_USD;
    }

    /// @notice Gets the funded amount by the respective address
    /// @param funder Address of the funder
    /// @return The total funded amount
    function getAddressToAmountFunded(address funder) external view returns (uint256) {
        return sAddressToAmountFunded[funder];
    }

    /// @notice Gets the owner of the contract
    /// @return address Address of the owner
    function getOwner() external view returns (address) {
        return I_OWNER;
    }

    /// @notice Gets the pricefeed contract's interface
    /// @return The AggregatorV3Interface
    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return sPriceFeed;
    }
}

//the address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
