pragma solidity ^0.5.0;

import "../node_modules/@openzeppelin/upgrades/contracts/Initializable.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts-ethereum-package/contracts/token/ERC20/SafeERC20.sol";

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

contract OneInchContract {
    address public oneSplitAddress = 0x64D04c6dA4B0bC0109D7fC29c9D09c802C061898;

    function whatIsThePrice(address _fromToken, address _toToken, uint _value) public view returns (uint priceAns) {
        (uint returnAmount, ) = oneSplit(oneSplitAddress).getExpectedReturn(IERC20(_fromToken),IERC20(_toToken),_value, 10, 0);
        return returnAmount;
    }
    
    function convertTokens(address _fromToken, address _toToken, uint _value) public payable returns (uint balance){
        oneSplit(oneSplitAddress).goodSwap.value(msg.value)(IERC20(_fromToken),IERC20(_toToken),_value, 1, 10, 0);
        uint balanceGot = IERC20(_toToken).balanceOf(address(this));
        IERC20(_toToken).transfer(msg.sender, balanceGot);
        return balanceGot;
    }
}