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

import "../node_modules/@openzeppelin/upgrades/contracts/Initializable";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20";

pragma solidity ^0.5.0;

///@author DeFiZap
///@notice this contract assits in one shot Dai donation to the GitCoin Projects

contract gitcoinZap in Ownable, Initializable, ReentrancyGuard {
    using SafeMath for uint256;
    address public daiTokenAddress;
    
    /**
     * @dev the contract is an upgradable contract hence, it is a must
     * that this initialize function is run soon after the deployment of
     * the contract
    **/

    function initialize(address _daiTokenAddress) public initializer {
        daiTokenAddress = _daiTokenAddress;
    }

    /**
     * @dev this function needs to be called in by the front-end for the purpose of donating Dai to more than 1 account.
     * @dev the function presumes that appropriate amount of "allowance" is granted to this contract to use the Dai of the msg.sender
     * @param toWhom will be an array of the addresses of the grantees
     * @param amount is the amount of Dai that needs to be donated to the grantees it should be 1-to-1 matching to the toWhom addresses
     * @param totalGrants this is a minor security check wrt to the number of total number of donations in the cart
    */

    function donateDAI(address[] memory toWhom, uint[] memory amount, uint8 totalGrants) public {
        require(toWhom.length == amount.length && toWhom.length == totalGrants, "error in parameters furnished");
        uint totalAmt;
        for (uint i = 0; i < amount.length; i++) {
            totalAmt = total.add(amount[i]);
        }
        for (uint i = 0; i < toWhom.length; i++) {
            IERC20(daiTokenAddress).transferFrom(msg.sender,toWhom[i], amount[i]);
        }
    }


}