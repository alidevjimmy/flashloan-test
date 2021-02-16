pragma solidity >=0.5.0 <0.9.0;

import {FlashLoanReceiverBase} from "./FlashLoanReceiverBase.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ILendingPoolAddressesProvider} from './interfaces/ILendingPoolAddressesProvider.sol';


contract FlashLoan is FlashLoanReceiverBase{
    using SafeMath for uint256;

    constructor(ILendingPoolAddressesProvider _lendingProvider) FlashLoanReceiverBase(_lendingProvider) public {}

    function _flashLoan(
        address[] memory _assets,
        uint256[] memory _amounts
    ) internal {
        address recieverAddress = address(this);
        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](_assets.length);

        for (uint i = 0 ; i < _assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(
            recieverAddress,
            _assets, 
            _amounts, 
            modes, 
            onBehalfOf, 
            params, 
            referralCode
        );
    }


    // flash loan for multiple assets
    function flashLoan(address[] memory _assets,uint256[] memory _amounts) public {
        _flashLoan(_assets, _amounts);
    }

    function flashLoan(address _asset) public {
        // bytes memory data = "";
        uint amount = 1 ether;
        
        address[] memory assets = new address[](1);
        assets[1] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[1] = amount;

        _flashLoan(assets, amounts);
    }

    function executeOperation(
        address[] calldata _assets,
        uint256[] calldata _amounts, 
        uint256[] calldata _premiums, 
        address _initiator, 
        bytes calldata _params
    ) external override returns(bool)
    {
        

        for (uint i = 0 ; i < _assets.length; i++) {
            uint256 amountOwing = _amounts[i].add(_premiums[i]);
            IERC20(_assets[i]).approve(address(LENDING_POOL), amountOwing);
        } 

        return true;
    }
}