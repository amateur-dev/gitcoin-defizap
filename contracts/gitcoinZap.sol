pragma solidity ^0.5.0;

// Copyright (C) 2019, 2020 dipeshsukhani, nodarjonashia, suhailg

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// Visit <https://www.gnu.org/licenses/>for a copy of the GNU Affero General Public License

/**
 * WARNING: This is an upgradable contract. Be careful not to disrupt
 * the existing storage layout when making upgrades to the contract. In particular,
 * existing fields should not be removed and should not have their types changed.
 * The order of field declarations must not be changed, and new fields must be added
 * below all existing declarations.
 *
 * The base contracts and the order in which they are declared must not be changed.
 * New fields must not be added to base contracts (unless the base contract has
 * reserved placeholder fields for this purpose).
 *
 * See https://docs.zeppelinos.org/docs/writing_contracts.html for more info.
*/

interface oneSplit {
    function getExpectedReturn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 parts,
        uint256 disableFlags // 1 - Uniswap, 2 - Kyber, 4 - Bancor, 8 - Oasis, 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken
    )
        external
        view
        returns(
            uint256 returnAmount,
            uint256[] memory distribution // [Uniswap, Kyber, Bancor, Oasis]
        );

    function goodSwap(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amount,
        uint256 minReturn,
        uint256 parts,
        uint256 disableFlags // 1 - Uniswap, 2 - Kyber, 4 - Bancor, 8 - Oasis, 16 - Compound, 32 - Fulcrum, 64 - Chai, 128 - Aave, 256 - SmartToken
    ) external payable;
    
}

import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";

///@author DeFiZap
///@notice this contract assits in one shot Dai donation to the GitCoin Projects

contract gitcoinZap is Initializable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // state variables
    address public daiTokenAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public oneSplitAddress = 0x64D04c6dA4B0bC0109D7fC29c9D09c802C061898;
    uint256 public constant FLAG_DISABLE_UNISWAP = 0x01;
      uint256 public constant FLAG_DISABLE_KYBER = 0x02;
      uint256 public constant FLAG_ENABLE_KYBER_UNISWAP_RESERVE = 0x100000000; // Turned off by default
      uint256 public constant FLAG_ENABLE_KYBER_OASIS_RESERVE = 0x200000000; // Turned off by default
      uint256 public constant FLAG_ENABLE_KYBER_BANCOR_RESERVE = 0x400000000; // Turned off by default
      uint256 public constant FLAG_DISABLE_BANCOR = 0x04;
      uint256 public constant FLAG_DISABLE_OASIS = 0x08;
      uint256 public constant FLAG_DISABLE_COMPOUND = 0x10;
      uint256 public constant FLAG_DISABLE_FULCRUM = 0x20;
      uint256 public constant FLAG_DISABLE_CHAI = 0x40;
      uint256 public constant FLAG_DISABLE_AAVE = 0x80;
      uint256 public constant FLAG_DISABLE_SMART_TOKEN = 0x100;
      uint256 public constant FLAG_ENABLE_MULTI_PATH_ETH = 0x200; // Turned off by default
      uint256 public constant FLAG_DISABLE_BDAI = 0x400;
      uint256 public constant FLAG_DISABLE_IEARN = 0x800;
      uint256 public constant FLAG_DISABLE_CURVE_COMPOUND = 0x1000;
      uint256 public constant FLAG_DISABLE_CURVE_USDT = 0x2000;
      uint256 public constant FLAG_DISABLE_CURVE_Y = 0x4000;
      uint256 public constant FLAG_DISABLE_CURVE_BINANCE = 0x8000;
    
      uint256 public constant DISABLED = FLAG_DISABLE_UNISWAP
      +FLAG_DISABLE_KYBER
      +FLAG_DISABLE_BANCOR
      +FLAG_DISABLE_OASIS
      +FLAG_DISABLE_COMPOUND
      +FLAG_DISABLE_FULCRUM
      +FLAG_DISABLE_CHAI
      +FLAG_DISABLE_AAVE
      +FLAG_DISABLE_SMART_TOKEN
      +FLAG_DISABLE_BDAI
      +FLAG_DISABLE_CURVE_COMPOUND
      +FLAG_DISABLE_CURVE_USDT
      +FLAG_DISABLE_IEARN;

    /**
     * @dev this function needs to be called in by the front-end for the purpose of donating Dai to more than 1 account.
     * @dev the function presumes that appropriate amount of "allowance" is granted to this contract to use the Dai of the msg.sender
     * @param toWhom will be an array of the addresses of the grantees
     * @param amount is the amount of Dai that needs to be donated to the grantees it should be 1-to-1 matching to the toWhom addresses
     * @param totalGrants this is a minor security check wrt to the number of total number of donations in the cart
    */

    function zapDonate_myERC(
                address[] memory toWhom,
                uint[] memory amount,
                uint8 totalGrants,
                address incomingTokenAddress
                ) public {
        require(toWhom.length == amount.length && toWhom.length == totalGrants, "error in parameters furnished");
        for (uint i = 0; i < toWhom.length; i++) {
            IERC20(incomingTokenAddress).transferFrom(msg.sender,toWhom[i], amount[i]);
        }
    }

    function zapDonateInDAI(
                address[] memory toWhom,
                uint[] memory amount,
                uint8 totalGrants,
                address incomingTokenAddress
                ) public {
        require(toWhom.length == amount.length &&
                toWhom.length == totalGrants,
                "error in parameters furnished");
        uint _totalERC;
        for (uint i = 0; i < amount.length; i++){
            _totalERC = _totalERC.add(amount[i]);
        }
        require(
                (IERC20(incomingTokenAddress).allowance(
                                                    msg.sender,
                                                    address(this)
                                                    )
                ) >= _totalERC, "allowance not sufficient"
        );
        require(IERC20(incomingTokenAddress).transferFrom(msg.sender,address(this), _totalERC),
                "error in transferring the incoming ERC");
        IERC20(incomingTokenAddress).safeApprove(oneSplitAddress, uint(-1));
        for (uint i = 0; i < toWhom.length; i++) {
            // uint expctedTokenQty = minTokens(incomingTokenAddress, daiTokenAddress, amount[i]);
            oneSplit(oneSplitAddress).goodSwap(IERC20(incomingTokenAddress),
                                                IERC20(daiTokenAddress),
                                                amount[i],
                                                1,
                                                2,
                                                DISABLED);
            uint DaiBalance = IERC20(daiTokenAddress).balanceOf(address(this));
            IERC20(DaiBalance).transfer(toWhom[i],DaiBalance);
        }
    }

    function minTokens(address _incomingTokenAddress, address _outgoingTokenAddress, uint _incomingQty) internal view returns (uint) {
        (uint _outgoingTokenQty,) = oneSplit(oneSplitAddress).getExpectedReturn(
                                                                IERC20(_incomingTokenAddress),
                                                                IERC20(_outgoingTokenAddress),
                                                                _incomingQty,
                                                                10,
                                                                0);
        return _outgoingTokenQty;
    }


}