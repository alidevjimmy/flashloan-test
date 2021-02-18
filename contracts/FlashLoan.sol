pragma solidity >=0.5.0 <0.9.0;

import {FlashLoanReceiverBase} from "./FlashLoanReceiverBase.sol";
import {SafeMath} from "@openzeppelin/contracts/math/SafeMath.sol";
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ILendingPoolAddressesProvider} from './interfaces/ILendingPoolAddressesProvider.sol';
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {UniswapV2Router02} from "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";


contract FlashLoan is FlashLoanReceiverBase, Ownable{
    
    using SafeMath for uint256; 
    ILendingPoolAddressesProvider provider;
    address lendingPoolAddr;
    
    address kovanAave = 0xB597cd8D3217ea6477232F9217fa70837ff667Af;
    address kovanDai = 0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD;
    address kovanLink = 0xAD5ce863aE3E4E9394Ab43d4ba0D80f419F61789;
    address kovenWETH = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
    address uniFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    constructor(ILendingPoolAddressesProvider _lendingProvider) FlashLoanReceiverBase(_lendingProvider) public {
        provider = _lendingProvider;
        lendingPoolAddr = provider.getLendingPool();
    }

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
    function flashLoan(address[] memory _assets,uint256[] memory _amounts) public onlyOwner{
        _flashLoan(_assets, _amounts);
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

    function withdraw() public onlyOwner {

        msg.sender.call{value: address(this).balance}("");

        IERC20(kovanAave).transfer(msg.sender, IERC20(kovanAave).balanceOf(address(this)));
        IERC20(kovanDai).transfer(msg.sender, IERC20(kovanDai).balanceOf(address(this)));
        IERC20(kovanLink).transfer(msg.sender, IERC20(kovanLink).balanceOf(address(this)));
    }


    function uniSwapEthToToken(uint _amount) public payable{
        address[] memory path = new address[](2);
        path[0] = address(kovenWETH);
        path[1] = address(kovanDai);
        IUniswapV2Router02 router= new UniswapV2Router02(uniFactory,kovenWETH);
        router.swapETHForExactTokens(_amount, path, msg.sender, block.timestamp);
    }



}