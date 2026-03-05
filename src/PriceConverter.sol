// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /// @notice Gets the price of Sepolia ETH/USD
    /// @dev Uses the Chainlink pricefeed to fetch the current ETH/USD price
    /// @param sPriceFeed The priceFeed interface
    /// @return The current price
    function getPrice(AggregatorV3Interface sPriceFeed) internal view returns (uint256) {
        (, /* uint80 roundID */
            int256 price,,, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
        ) = sPriceFeed.latestRoundData();

        // ETH/USD rate has 18 digits
        return uint256(price * 1e10);
    }

    ///@notice Gets the conversion rate of ETH/USD
    ///@dev Since it assumes decimals it cannot work for every aggregator
    ///@param ethAmount Amount of ETH
    ///@param sPriceFeed The Pricefeed Inetrface
    ///@return ethAmountInUsd The value of the ETH amount in USD

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface sPriceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(sPriceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;

        return ethAmountInUsd;
    }

    /// @notice Gets the current version of the AggregatorV3Interface
    /// @return version The version
    function getVersion(AggregatorV3Interface sPriceFeed) internal view returns (uint256) {
        return sPriceFeed.version();
    }
}
